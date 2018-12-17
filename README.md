# MessagesGateway

###Rest API
```

HOST: http://192.168.100.165
PORT: 4011

```


####Requests from web.admin


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
            "name": "sms"
        },
        {
            "active": true,
            "id": "616c7928-f9d7-472c-b994-87a0e3bc36b3",
            "last_update": "2018-12-14T13:51:38.685603",
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

*request:*
```
Method: POST 

url: HOST:PORT/operator_type
```
body:
```json
    {"resource": {"operator_type_name":"viber1"}}

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
*request:*
```
Method: POST 

url: HOST:PORT/operators
```
*body:
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
**operator_edit**
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
                "last_update": "2018-12-17T13:59:48.016885",
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