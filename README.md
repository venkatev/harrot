# Harrot
A lightweight HTTP stub using rack.

##### Starting the stub server
Harrot.start(6789) # Starts the stub listening to the port 6789

##### Adding a stub
  * Using HTTP: POST to '/stubs/add' with the stub in the format below.
  * Using ruby API: HarrotClient.add_stub(stub_config)

##### Stub format
```javascript
{
  url: '/api/path1/path2'
  response: {
    status: 200 (default),
    body: "Hello",
    content_type: 'application/json' (default),
    headers: (HTTP headers),
    wait: 0 (Artificial delay in response. Useful to simulating real-world response times)
  }
}
```

##### Getting all stubs
  GET /stubs

##### Health check
  /ping

