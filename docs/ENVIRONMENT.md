## Environment Variables

This environment variables can be used to configure released docker container at start time. 
Also sample .env can be used as payload for docker run cli.

### General


| VAR_NAME              | Default Value               | Description |
| --------------------- | --------------------------- | ----------- |
| ERLANG_COOKIE         | `mFd1nWJ1KUxj`..            | Erlang [distribution cookie](http://erlang.org/doc/reference_manual/distributed.html). **Make sure that default value is changed in production.** |


### Database

| VAR_NAME      | Default Value | Description        |
| ------------- | ------------- | ------------------ |
| DB_NAME       | `messages_gateway` | Database name |
| DB_USER       | `postgres`    | Database user      |
| DB_PASSWORD   | `postgres`    | Database password  |
| DB_HOST       | `postgres`      | Database host    |
| DB_PORT       | `5432`        | Database port      |
| DB_POOL_SIZE  | `10`        | Database pool size   |

### Phoenix HTTP Endpoint

| VAR_NAME      | Default Value | Description |
| ------------- | ------------- | ----------- |
| PORT          | `4011`        | HTTP host for web app to listen on |
| HOST          | `localhost`   | HTTP port for web app to listen on |

### Redis

| VAR_NAME        | Default Value    | Description    |
| --------------- | ---------------- | -------------- |
| REDIS_NAME      | `1`              | Redis name     |
| REDIS_PASSWORD  | `1`              | Redis password |
| REDIS_HOST      | `redis`          | Redis host     |
| REDIS_PORT      | `6379`           | Redis port     |
| REDIS_POOL_SIZE | `5`              | Redis pool size|

### RabbiMQ

| VAR_NAME          | Default Value      | Description          |
| ----------------- | ------------------ | -------------------- |
| MQ_HOST           | `rabbitmq`         | RabbiMQ host         |
| MQ_PORT           | `5672`             | RabbiMQ port         |
| MQ_QUEUE          | `message_queue`    | RabbiMQ queue name   |
| MQ_EXCHANGE       | `message_exchange` | RabbiMQ exchange name|


### Lifecell 

| VAR_NAME               | Default Value      | Description  |
| ---------------------- | ------------------ | ------------ |
| LIFECELL_CALLBACK_PORT | `6012`             | Listener`s port for requests from lifecell |

### Viber

| VAR_NAME            | Default Value  | Description  |
| ------------------- | -------------- | ------------ |
| VIBER_CALLBACK_PORT | `6016`         | Listener`s port for requests from Viber |


### SMTP

| VAR_NAME       | Default Value        | Description   |
| -------------- | -------------------- | ------------- |
| SMTP_USERNAME  | `test@test.com`      | SMTP user     |
| SMTP_PASSWORD  | `test`               | SMTP password |
| SMTP_SERVER    | `smtp.office365.com` | SMTP server   |
| SMTP_HOSTNAME  | `test.com`           | SMTP hostname |

### ASTERISK

| VAR_NAME          | Default Value  | Description     |
| ----------------- | -------------- | --------------- |
| ASTERISK_HOST     | `127.0.01`     | Asterisk host   |
| ASTERISK_PORT     | `5038`         | Asterisk port   |
| ASTERISK_USERNAME | `test`         | Asterisk server |
| ASTERISK_PASSWORD | `test`         | Asterisk user   |
