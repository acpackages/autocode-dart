# Multi-stage build for ac_patches_server
FROM dart:stable AS build

WORKDIR /app
COPY . .

WORKDIR /app/ac_patches/server/ac_patches_server
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/ac_patches/server/ac_patches_server/bin/server /app/server

EXPOSE 8080
ENV PORT=8080

ENTRYPOINT ["/app/server"]
