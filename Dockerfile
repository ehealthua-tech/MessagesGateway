FROM ubuntu:16.04
FROM elixir:1.7.4

#ARG APP_NAME=mga

ADD . /app

WORKDIR /app

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
      bash

RUN apt-get install g++
RUN apt-get install build-essential

RUN which cmake
RUN cmake --version
#RUN ls -ls /usr/local/Cellar/cmake/

RUN mix do \
      local.hex --force, \
      local.rebar --force,\
      deps.get, \
      deps.compile, \
       release --name="mga"


COPY --from=builder /app/_build/prod/rel/mga/releases/0.1.0/mga.tar.gz /app

RUN tar -xzf mga.tar.gz; rm mga.tar.gz

ENV REPLACE_OS_VARS=true \
      APP=mga

CMD ./bin/mga foreground