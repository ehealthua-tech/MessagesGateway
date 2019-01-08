# MessagesGateway

### Rest API
```

HOST: http://192.168.100.165
PORT: 4011

```


#### Requests from web.admin


**get_operator_types**

*request:*
```
Method: GET 
url: HOST:PORT/operator_type
```

*response:*
```json
{
    "data": [
        {
            "active": true,
            "id": "d9ca99a2-f5a9-4c9b-aa70-133fa9b9a9b1",
            "last_update": "2018-12-14T13:51:31.181995",
            "priority": 1,
            "name": "sms"
        },
        {
            "active": true,
            "id": "616c7928-f9d7-472c-b994-87a0e3bc36b3",
            "last_update": "2018-12-14T13:51:38.685603",
            "priority": 1,
            "name": "viber"
        }
    ],
    "meta": {
        "code": 200,
        "request_id": "2loi61rj3955jeltk800011h",
        "type": "list",
        "url": "http://192.168.100.165:4011/operator_type"
    }
}
```

**add_operator_type**

|fields|types|required|
|-----|----|--------|
| operator_type_name|String|required|
| priority|Integer|required|

*request:*
```
Method: POST 

url: HOST:PORT/operator_type
```
body:
```json
    {"resource": {"operator_type_name":"viber1", "priority":  1}}

```

*response:*
```json
{
    "data": {
        "status": "success"
    },
    "meta": {
        "code": 200,
        "request_id": "2loi661afgnl4uf0hs000121",
        "type": "object",
        "url": "http://192.168.100.165:4011/operator_type"
    }
}
```

**update priority**

|fields|types|required|
|-----|----|--------|
|id|String|required|
|name|String|required|
|priority|Integer|required|
|active|Bool|required|


*request:*

```
Method: POST 

url: HOST:PORT/api/operator_type/update_priority
```
body:
```json

    {"resource": [
            {
                "active": true,
                "id": "0825f627-9772-4107-aa99-11d6c18249b8",
                "name": "viber",
                "priority": 2
            }
        ]}

```

*response:*
```json
{
    "data": {
        "status": "success"
    },
    "meta": {
        "code": 200,
        "request_id": "2loi661afgnl4uf0hs000121",
        "type": "object",
        "url": "http://192.168.100.165:4011/operator_type"
    }
}
```

**delete_operator_type**

|fields|types|required|
|-----|----|--------|
|operator_type_id|String|required|
|active|Bool|required|

*request:*
```
Method: POST 

url: HOST:PORT/operator_type/deactivate
```
body:
```json
    {"resource": {"operator_type_id": "4d7ae33b-0542-4381-bfd1-dca84d90df9e", "active": true}}

```

*response:*
```json
{
    "data": {
        "status": "success"
    },
    "meta": {
        "code": 200,
        "request_id": "2loi6j7jt06quj6vqc000131",
        "type": "object",
        "url": "http://192.168.100.165:4011/operator_type/deactivate"
    }
}
```

**get_all_operators**

*request:*
```
Method: GET 

url: HOST:PORT//operators
```

*response:*
```json
{
    "data": [
        {
            "active": false,
            "config": {
                "host": "blabal"
            },
            "id": "421f2284-2a8b-466e-8530-410ade1b14b4",
            "last_update": "2018-12-17T13:59:48.016885",
            "limit": 1000,
            "name": "sms4",
            "operator_type": {
                "active": true,
                "id": "616c7928-f9d7-472c-b994-87a0e3bc36b3",
                "name": "viber"
            },
            "price": 18,
            "priority": 1
        }
    ],
    "meta": {
        "code": 200,
        "request_id": "2loi72amu293c364i400017h",
        "type": "list",
        "url": "http://192.168.100.165:4011/operators"
    }
}
```

**add_operator**

|fields|types|required|
|-----|----|--------|
|name|String|required|
|operator_type_id|String|required|
|protocol_name|String|required|
|config|Json|required|
|priority|Integer|required|
|price|Integer|required|
|limit|Integer|required|
|active|Bool|required|

*request:*
```
Method: POST 

url: HOST:PORT/operators
```
body:
```json
    {"resource": {
    "name":"sms4", 
    "operator_type_id": "616c7928-f9d7-472c-b994-87a0e3bc36b3",
    "config": {"host": "blabal"}, 
    "priority": 1, 
    "price": 18, 
    "limit":1000, 
    "active": false
    }}

```

*response:*
```json
{
    "data": {
        "status": "success"
    },
    "meta": {
        "code": 200,
        "request_id": "2loi70f8251gep7a5k000171",
        "type": "object",
        "url": "http://192.168.100.165:4011/operators"
    }
}
```
**update priority**

|fields|types|required|
|-----|----|--------|
|id|String|required|
|name|String|required|
|operator_type|OperatorType obj|required|
|config|Json|required|
|priority|Integer|required|
|price|Integer|required|
|limit|Integer|required|
|active|Bool|required|

*OperatorType obj:*

|fields|types|required|
|-----|----|--------|
|id|String|required|
|name|String|required|
|active|Bool|required|

*request:*

```
Method: POST 

url: HOST:PORT/operators/update_priority
```
body:
```json

    {"resource": [
       {
                "active": true,
                "config": {
                    "host": "blabal"
                },
                "id": "421f2284-2a8b-466e-8530-410ade1b14b4",
                "limit": 1000,
                "name": "sms4",
                "operator_type": {
                    "active": true,
                    "id": "616c7928-f9d7-472c-b994-87a0e3bc36b3",
                    "name": "viber"
                },
                "price": 18,
                "priority": 2
            }
    ]}

```

**change operator**

|fields|types|required|
|-----|----|--------|
|id|String|required|
|name|String|required|
|config|Json|required|
|priority|Integer|required|
|price|Integer|required|
|limit|Integer|required|
|active|Bool|required|

*request:*
```
Method: POST

url: HOST:PORT/operators/change
```
body:
```json

{"resource": {
            "active": true,
            "config": {
                "host": "blabal"
            },
            "id": "4e250374-0cb5-46fe-acf8-fcd07b1d9105",
            "limit": 1000,
            "protocol_name": "viber_protocol",
            "name": "viber",
            "price": 18,
            "priority": 1
        }}

```

*response:*
```json
{
    "data": {
        "status": "success"
    },
    "meta": {
        "code": 200,
        "request_id": "2loi78dhm9vvlvceoc000181",
        "type": "object",
        "url": "http://192.168.100.165:4011/operators/update_priority"
    }
}
```
**operator_delete**

*request:*
```
Method: DELETE 

url: HOST:PORT/operator_type/id
```

*response:*
```json
{
    "data": {
        "status": "success"
    },
    "meta": {
        "code": 200,
        "request_id": "2loi7fu73i0d62nobc000191",
        "type": "object",
        "url": "http://192.168.100.165:4011/operators/update_priority"
    }
}
```