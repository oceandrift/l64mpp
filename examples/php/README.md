# L64MPP example app

This example app implements a client/server model.
The server prints each message it receives from its client.

## Check it out

First, setup dependencies and generate autoload files for the example app:

```sh
composer install -o
```

Start the server.

```sh
./server.php
```

Then start a client that connects to it.

```sh
./client.php
```
