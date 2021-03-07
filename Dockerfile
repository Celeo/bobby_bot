FROM bitwalker/alpine-elixir:latest AS release_stage

COPY mix.exs .
COPY mix.lock .
RUN mix deps.get
RUN mix deps.compile
COPY config .
COPY lib .

ENV MIX_ENV=prod
RUN mix release

FROM bitwalker/alpine-elixir:latest AS run_stage
COPY --from=release_stage $HOME/_build .
RUN chown -R default: ./prod
USER default
CMD ["./prod/rel/bobby_discord_bot/bin/bobby_discord_bot", "start"]
