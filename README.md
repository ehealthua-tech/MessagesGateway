## MessagesGateway.API

MessagesGateway.API is a part of the software package which is responsible for sending messages to users on different communication channels.

MessagesGateway consists of two main parts:

- [REST API back-end](https://github.com/ehealthua-tech/MessagesGateway)
- [Admin UI](https://github.com/ehealthua-tech/MessagesGatewayWeb)

## Specification
The project consists two different API (for sending messages and for admin part)
 - [API for sending messages](docs/apiaryGeneral.apib)
 - [API for admin part](docs/apiary.apib)
 - [All rests](docs/rest_api.md)

## Installation
Official Docker containers can be found on Docker Hub:
* [Docker Hub](https://hub.docker.com/r/)

Also you can use [docker-compose](docker/)

## Dependencies
- PostgreSQL 9.6 is using as storage back-end
- RabbitMQ is using for messages queue
- Redis is using for cashing messages and configurations
- Elasticsearch is using for storage logs

## Configuration
See [ENVIRONMENT.md](docs/ENVIRONMENT.md)

## License
See [LICENSE.md](docs/LICENSE.md)