FROM ubuntu:18.04
FROM elixir:1.7.4 as builder

ADD . /messages_gateway_api
RUN chmod 0777 /messages_gateway_api
WORKDIR /messages_gateway_api

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
COPY apps apps

RUN apt-get update
RUN apt-get install -y \
      make \
      git \
      libncurses5-dev libncursesw5-dev \
      zlib1g \
      ca-certificates \
      openssl \
      cmake \
      gperf \
      bash \
      g++ \
      build-essential


WORKDIR /messages_gateway_api

RUN mix do \
      local.hex --force, \
      local.rebar --force,\
      deps.get, \
      deps.compile

WORKDIR /messages_gateway_api
COPY rel rel
RUN mix release --name=messages_gateway_api --env=prod --verbose

FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y openssl
    # we need bash and openssl for Phoenix


ENV PORT=4000 \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/bash

WORKDIR /messages_gateway_api

COPY --from=builder  /messages_gateway_api/_build/prod/rel/messages_gateway_api/releases/0.1.0/messages_gateway_api.tar.gz .

RUN tar -xzf messages_gateway_api.tar.gz; rm messages_gateway_api.tar.gz

RUN chown -R root ./releases

USER root

CMD ./bin/messages_gateway_api foreground