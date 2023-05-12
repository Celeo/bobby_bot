#![deny(clippy::all, clippy::pedantic)]

use anyhow::Result;
use base64::{engine::general_purpose, Engine as _};
use dotenv::dotenv;
use log::{error, info, warn};
use rand::{seq::SliceRandom, Rng};
use std::{
    collections::HashMap,
    env,
    sync::{Arc, Mutex},
};
use twilight_gateway::{Event, Intents, Shard, ShardId};
use twilight_http::Client as HttpClient;
use twilight_model::id::Id;

mod messages;
use messages::MESSAGES;

const MESSAGE_RESPONSE_THRESHOLD: u64 = 1_000;

/// Parse a bot ID from the token.
///
/// This function panics instead of returning a Result, as the token
/// must confirm to this layout in order to be valid for Discord.
fn bot_id_from_token(token: &str) -> u64 {
    std::str::from_utf8(
        &general_purpose::STANDARD_NO_PAD
            .decode(token.split('.').next().unwrap())
            .unwrap(),
    )
    .unwrap()
    .parse()
    .unwrap()
}

/// Entrypoint.
#[tokio::main]
async fn main() {
    dotenv().ok();
    if env::var("RUST_LOG").is_err() {
        env::set_var("RUST_LOG", "info");
    }
    pretty_env_logger::init();

    let token = env::var("DISCORD_BOT_TOKEN").expect("Missing 'DISCORD_BOT_TOKEN' env var");
    let bot_id = bot_id_from_token(&token);
    let intents = Intents::GUILD_MESSAGES | Intents::MESSAGE_CONTENT;
    let mut shard = Shard::new(ShardId::ONE, token.clone(), intents);
    let http = Arc::new(HttpClient::new(token));
    let message_count: Arc<Mutex<HashMap<u64, u64>>> = Arc::new(Mutex::new(HashMap::new()));

    info!("Waiting for events");
    loop {
        let event = match shard.next_event().await {
            Ok(event) => event,
            Err(source) => {
                warn!("Error receiving event: {:?}", source);
                if source.is_fatal() {
                    break;
                }
                continue;
            }
        };
        let last_seen = Arc::clone(&message_count);
        let http = Arc::clone(&http);
        tokio::spawn(async move {
            if let Err(e) = handle_event(event, http, bot_id, last_seen).await {
                error!("Error in future: {e}");
            }
        });
    }
}

/// Handle a single Event from the Discord Gateway.
async fn handle_event(
    event: Event,
    http: Arc<HttpClient>,
    bot_id: u64,
    message_count: Arc<Mutex<HashMap<u64, u64>>>,
) -> Result<()> {
    if let Event::MessageCreate(msg) = event {
        // never process bot messages
        if msg.author.bot {
            return Ok(());
        }

        // respond to being mentioned
        let mentioned_self = msg
            .mentions
            .iter()
            .any(|mention| mention.id == Id::new(bot_id));
        if mentioned_self && !msg.mention_everyone {
            let response = MESSAGES.choose(&mut rand::thread_rng()).unwrap();
            http.create_message(msg.channel_id)
                .reply(msg.id)
                .content(response)?
                .await?;
            info!("Responded to {} in {}", msg.author.name, msg.channel_id);
            return Ok(());
        }

        // rare, random rude response
        let guild_id = msg.0.guild_id.unwrap().get();
        let mut val = 0;
        message_count
            .lock()
            .unwrap()
            .entry(guild_id)
            .and_modify(|count| {
                *count += 1;
                val = *count;
            })
            .or_insert(0);
        // There must have been a certain amount of messages in the server and a rare
        // random chance for this response to trigger, after which the messages count
        // is reset.
        if val >= MESSAGE_RESPONSE_THRESHOLD && rand::thread_rng().gen_range(0..400) == 1 {
            http.create_message(msg.channel_id)
                .reply(msg.id)
                .content("Bitch")?
                .await?;
            let _ = message_count.lock().unwrap().remove(&guild_id);
            info!(
                "Random call-out triggered for {} in {}",
                msg.author.name, msg.channel_id
            );
        }
    }
    Ok(())
}
