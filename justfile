set dotenv-load := false

defualt: run

run:
    @deno run --allow-read=.env,.env.defaults --allow-net=discord.com,gateway.discord.gg main.ts

compile:
    @deno compile --allow-read=.env,.env.defaults --allow-net=discord.com,gateway.discord.gg main.ts

deploy: compile
    @scp bobby_bot do:/srv/bobby_bot.new
