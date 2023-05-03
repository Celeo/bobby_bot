import {
  Bot,
  createBot,
  GatewayIntents,
  Message,
  sendMessage,
  startBot,
} from "https://deno.land/x/discordeno@17.0.1/mod.ts";
import "https://deno.land/std@0.185.0/dotenv/load.ts";
import { RESPONSES } from "./messages.ts";

const DISCORD_BOT_TOKEN = "DISCORD_BOT_TOKEN";
const COOLDOWN_RESET_VALUE = 1000;

async function mentionHandler(
  bot: Bot,
  message: Message,
): Promise<void> {
  if (!message.mentionedUserIds.includes(bot.id)) {
    return;
  }
  const content = RESPONSES[Math.floor(Math.random() * RESPONSES.length)];
  await sendMessage(bot, message.channelId, {
    content,
    messageReference: {
      messageId: message.id,
      channelId: message.channelId,
      failIfNotExists: true,
    },
  });
}

async function calloutHandler(
  bot: Bot,
  calloutCooldown: Record<string, number>,
  message: Message,
) {
  if (message.guildId === undefined) {
    return;
  }
  const guildId = `${message.guildId}`;
  if (guildId in calloutCooldown) {
    if (calloutCooldown[guildId] <= 0) {
      if (Math.floor(Math.random() * 400) === 0) {
        await sendMessage(bot, message.channelId, {
          content: "Bitch",
          messageReference: {
            messageId: message.id,
            channelId: message.channelId,
            failIfNotExists: true,
          },
        });
        calloutCooldown[guildId] = COOLDOWN_RESET_VALUE;
      }
    } else {
      calloutCooldown[guildId]--;
    }
  } else {
    calloutCooldown[guildId] = COOLDOWN_RESET_VALUE;
  }
}

async function messageCreateHandler(
  bot: Bot,
  calloutCooldown: Record<string, number>,
  message: Message,
): Promise<void> {
  if (message.isFromBot) {
    return;
  }
  try {
    await mentionHandler(bot, message);
    await calloutHandler(bot, calloutCooldown, message);
  } catch (e) {
    console.error(`Error processing message: ${e}`);
  }
}

async function main(token: string | undefined): Promise<void> {
  if (!token) {
    console.log(
      `No token supplied; set the ${DISCORD_BOT_TOKEN} environment variable and run again`,
    );
    return;
  }
  const cooldownMap = {};
  const bot = createBot({
    token,
    intents: GatewayIntents.GuildMessages | GatewayIntents.MessageContent,
    botId: BigInt(atob(token.split(".")[0])),
    events: {
      ready() {
        console.log("Successfully connected to gateway");
      },
      async messageCreate(bot, message) {
        await messageCreateHandler(bot, cooldownMap, message);
      },
    },
  });
  console.log("Starting bot ...");
  await startBot(bot);
}

if (import.meta.main) {
  await main(Deno.env.get(DISCORD_BOT_TOKEN));
}
