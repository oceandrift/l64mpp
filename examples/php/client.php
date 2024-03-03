#!/usr/bin/env php
<?php

declare(strict_types=1);

use Oceandrift\L64mpp\L64mpp;
use Oceandrift\L64mpp\SocketHelper;

require __DIR__ . '/vendor/autoload.php';

echo 'Startup', PHP_EOL;
$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
if ($socket === false) {
    echo SocketHelper::lastErrorString(null), PHP_EOL;
    exit(1);
}

$connected = @socket_connect($socket, '127.0.0.1', 23456);
if (!$connected) {
    echo SocketHelper::lastErrorString(null), PHP_EOL;
    exit(1);
}

echo 'Connected', PHP_EOL;

$connection = new L64mpp($socket);

while(true) {
    $line = readline('Message> ');
    if ($line === false) {
        break;
    }

    $connection->sendMessage($line);

    if ($line === 'exit') {
        @socket_shutdown($socket);
        @socket_close($socket);
        break;
    }
}