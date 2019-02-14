## MessagesGateway.API

MessagesGateway.API is a part of the software package which is responsible for sending messages to users on different communication channels.

MessagesGateway consists of two main parts:

- [REST API back-end](https://github.com/),
- [Admin UI](https://github.com/).

## Specification
The project consist two different API ( for sending messages and for admin part)
 - [API for sending messages](docs/apiaryGeneral.apib)
 - [API for admin part](docs/apiary.apib)

## Installation
Official Docker containers can be found on Docker Hub:
* [Docker Hub](https://hub.docker.com/r/)

Also you can use [docker-compose](docker/)

## Dependencies
- PostgreSQL 9.6 is used as storage back-end
- RabbitMQ is used for messages queue
- Redis is used for cashing messages and configurations
- Elasticsearch is used for storage logs

## Configuration
See [ENVIRONMENT.md](docs/ENVIRONMENT.md).

## License
See [LICENSE.md](docs/LICENSE.md).