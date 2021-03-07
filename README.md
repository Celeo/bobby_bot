# bobby_discord_bot

A joke Discord bot.

## Installing

1. Install [Elixir](https://elixir-lang.org/)
1. Clone the repo
1. Run `mix deps.get` and `mix compile`

## Using

1. Copy `./config/config.exs.example` or `./config/config.exs` and supply a Discord bot token
1. You can run the supervisor through iex with `iex -S mix` and `BotSupervisor.start_link()`

## Deploying

1. Run `MIX_ENV=prod mix release --overwrite`
1. Then use `./_build/prod/rel/bobby_discord_bot` to send to your server
1. Once there, run `./bobby_discord_bot/bin/bobby_discord_bot daemon` to start the run daemon
1. Connect to the daemon with `./bobby_discord_bot/bin/bobby_discord_bot remote` and run `BotSupervisor.start_link()`

## License

Licensed under MIT ([LICENSE](LICENSE)).

## Contributing

Note: preceding my normal "contributions welcome" message is a disclaimer that this bot is specifically made for a Discord guild I'm in. If you want to contribute a bit, you're welcome to, but the intent of this bot won't really grow.

Please feel free to contribute. Please open an issue first (or comment on an existing one) so that I know that you want to add/change something.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you shall be licensed as above, without any additional terms or conditions.
