#!/usr/bin/env php
<?php

declare(strict_types=1);

use Oceandrift\L64mpp\L64mpp;
use Oceandrift\L64mpp\SocketHelper;

require __DIR__ . '/vendor/autoload.php';

echo 'Startup.', PHP_EOL;
$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
if ($socket === false) {
    echo socket_last_error_string(null), PHP_EOL;
    exit(1);
}

socket_set_option($socket, SOL_SOCKET, SO_REUSEADDR, 1);
$bound = @socket_bind($socket, '127.0.0.1', 23456);
if (!$bound) {
    echo SocketHelper::lastErrorString(null), PHP_EOL;
    exit(1);
}
echo 'Bound.', PHP_EOL;

$listening = @socket_listen($socket, 0);
if (!$bound) {
    echo SocketHelper::lastErrorString(null), PHP_EOL;
    exit(1);
}
echo 'Listening.', PHP_EOL;

echo 'Waiting for an incoming connection.', PHP_EOL;
$accepted = @socket_accept($socket);
$connection = new L64mpp($accepted);

echo 'Client connected.', PHP_EOL;

while(true) {
    $msg = $connection->receiveMessage(255);
    echo 'Received a message (', strlen($msg), ' bytes):', PHP_EOL,
        ': "', $msg, '"', PHP_EOL;

    if ($msg === 'exit') {
        @socket_shutdown($accepted);
        @socket_close($accepted);
        @socket_shutdown($socket);
        @socket_close($socket);
        break;
    }
}
