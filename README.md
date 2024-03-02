# Little-endian 64-bit Message Passing Protocol

A super-simple message passing protocol.

It builds upon TCP and is as straightforward as *length* + *data*.

The length is a 64-bit signed integer
in [little-endian](https://en.wikipedia.org/wiki/Little-endian) format.
Given that most machines are LE today, this means no conversion is necessary on them.
