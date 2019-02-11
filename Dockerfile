FROM elixir:1.7.4-alpine as builder

ADD . /app

WORKDIR /app

ENV MIX_ENV=prod

RUN apk update && apk add git

RUN mix do \
      local.hex --force, \
      local.rebar --force, \
      deps.get

RUN cp apps/telegram_protocol/priv/tdlib-json-cli /app/deps/tdlib/priv/
RUN cp apps/telegram_protocol/priv/types.json /app/deps/tdlib/priv/

RUN mix do \
      deps.compile, \
      release --name=messages_gateway_api --env=prod --verbose

FROM alpine:3.8

ARG messages_gateway_api

RUN apk add --no-cache \
      ncurses-libs \
      zlib \
      ca-certificates \
      openssl \
      bash


WORKDIR /app

ENV PORT=4011 \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/bash

COPY --from=builder /app/_build/prod/rel/messages_gateway_api/releases/0.1.0/messages_gateway_api.tar.gz /app
#COPY --from=builder ./app/commits.txt /app

RUN tar -xzf messages_gateway_api.tar.gz; rm messages_gateway_api.tar.gz

RUN chown -R root ./releases

EXPOSE 4011
USER root

CMD ./bin/messages_gateway_api foreground