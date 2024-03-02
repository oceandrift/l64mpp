# L64MPP example app

This example app implements a client/server model.
The server prints each message it receives from its client.

## Check it out

First start the server.

```sh
dub -- server
```

Then start a client that connects to it.

```sh
dub -- client
```

In case you receive an error message that port `23456` is already in use,
simply try a different one by replacing the value of `port` in `app.d`.
