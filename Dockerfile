FROM denoland/deno:latest AS build

WORKDIR /opt
COPY main.ts messages.ts deps.ts deno.jsonc /opt/
RUN ["deno", "task", "compile"]

FROM denoland/deno:alpine AS run

WORKDIR /opt
COPY --from=build /opt/bobby_bot .

CMD ["/opt/bobby_bot"]
