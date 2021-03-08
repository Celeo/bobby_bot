FROM bitwalker/alpine-elixir:latest AS release_stage

ARG DISCORD_TOKEN
ENV DISCORD_TOKEN=${DISCORD_TOKEN}
ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile
COPY config/config.exs ./
COPY lib ./

RUN mix release

FROM bitwalker/alpine-elixir:latest AS run_stage
COPY --from=release_stage $HOME/_build/prod/rel/bobby_discord_bot .
CMD ["./bin/bobby_discord_bot", "start"]
