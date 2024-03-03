<?php

declare(strict_types=1);

namespace Oceandrift\L64mpp;

use \Exception;
use \Socket;

final class SocketHelper
{
    public static function lastErrorString(?Socket $socket): ?string
    {
        $e = socket_last_error($socket);
        if ($e === 0) {
            return null;
        }

        return socket_strerror($e);
    }

    public static function sendAll(Socket $socket, string $data): void
    {
        while (($length = strlen($data)) > 0) {
            $written = @socket_write($socket, $data, $length);

            if ($written === false) {
                throw new Exception(self::lastErrorString($socket));
            }
            
            if ($written >= $length) {
                return;
            }

            $data = substr($data, $written);
        }
    }

    public static function receiveAll(Socket $socket, int $length): ?string
    {
        if ($length === 0) {
            return '';
        }

        $data = null;
        $read = @socket_recv($socket, $data, $length, MSG_WAITALL);

        if ($read === false) {
            throw new Exception(self::lastErrorString($socket));
        }

        if ($read === 0) {
            return null;
        }

        if ($read < $length) {
            throw new Exception(
                'Connection was closed or interrupted before the requested number of bytes has been received.'
            );
        }

        return $data;
    }
}