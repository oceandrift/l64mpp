<?php

declare(strict_types=1);

namespace Oceandrift\L64mpp;

use \Exception;
use \Socket;

final class L64mpp
{
    private Socket $socket;

    public function __construct(Socket $socket)
    {
        $this->socket = $socket;
    }

    public function sendMessage(string $message): void
    {
        $length = strlen($message);
        $lengthData = pack('P', $length);
        SocketHelper::sendAll($this->socket, $lengthData);
        SocketHelper::sendAll($this->socket, $message);
    }

    public function receiveMessage(int $maxLength = PHP_INT_MAX): string
    {
        $lengthData = SocketHelper::receiveAll($this->socket, 8);
        if ($lengthData === null) {
            throw new NoFurtherMessagesException();
        }

        $length = unpack('P_', $lengthData)['_'];

        if ($length < 0) {
            throw new Exception('Invalid message length received.');
        }

        if ($length > $maxLength) {
            throw new Exception(
                'Received message length specification is longer than the requested limit.'
            );
        }

        return SocketHelper::receiveAll($this->socket, $length);
    }
}
