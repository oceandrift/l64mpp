/++
	Little-endian 64-bit Message Passing Protocol
 +/
module l64mpp.socket;

import socketplate.connection;
import std.conv : to;
import std.socket : SocketException;

private alias int64 = long;

@safe unittest {
	assert(int64.sizeof == 8, "`int64` is not 64 bit (= 8 byte) long.");
	assert(int64.min < 0, "`int64` is not signed.");
}

/++
	Exception type indicating a L64MPP error.
 +/
class L64MPPException : SocketException {

@safe pure nothrow @nogc:
	private this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

/++
	Exception type indicating the tried recipience of a message
	that would exceed the requested length limit.
 +/
final class MessageTooLongException : L64MPPException {
	private {
		int64 _messageLength;
		int64 _maxLength;
	}

@safe pure nothrow @nogc:

	/++
		Received length specification
	 +/
	public int64 messageLength() const => _messageLength;

	/++
		Requested length limit (that would have been exceeded)
	 +/
	public int64 maxLength() const => _maxLength;

	private this(int64 messageLength, int64 maxLength, string file = __FILE__, size_t line = __LINE__) {
		_messageLength = messageLength;
		_maxLength = maxLength;
		super("Message length exceeds the requested length limit.", file, line);
	}
}

/++
	Exception type indicating that the connection was shutdown
	and there are no further messages to receive.
 +/
final class NoFurtherMessagesException : L64MPPException {
	private this(string file = __FILE__, size_t line = __LINE__) @safe pure nothrow @nogc {
		super("End of stream; no more messages.", file, line);
	}
}

/++ 
	Message to send/receive
 +/
struct Message {

	/++
		Message content data
	 +/
	const(ubyte)[] data;

	///
	alias data this;

@safe pure nothrow @nogc:

	/++
		Returns: Message content data as `string`.

		$(WARNING
			Does not perform UTF-8 validation.
		)
	 +/
	const(char)[] toString() const => cast(const(char)[]) data;

	///
	this(const(ubyte)[] data) {
		this.data = data;
	}

	///
	this(const(char)[] data) {
		this(cast(const(ubyte)[]) data);
	}
}

/++
	Sends a message to the connected peer
 +/
void sendMessage(ref SocketConnection connection, Message message) @safe {
	import std.bitmanip : nativeToLittleEndian;

	const length = message.data.length.to!int64;
	const ubyte[int64.sizeof] lengthData = nativeToLittleEndian(length);
	connection.sendAll(lengthData);
	connection.sendAll(message.data);
}

private int64 receiveLength(ref SocketConnection connection, int64 maxLength) @safe {
	import std.bitmanip : littleEndianToNative;

	if (connection.empty) {
		throw new NoFurtherMessagesException();
	}

	ubyte[int64.sizeof] lengthData;
	connection.receiveAll(lengthData);
	const length = littleEndianToNative!int64(lengthData);

	if (length < 0) {
		throw new L64MPPException("Invalid message length received.");
	}

	if (length > maxLength) {
		throw new MessageTooLongException(length, maxLength);
	}

	return length;
}

/++
	Receives a message from the connected peer
 +/
Message receiveMessage(ref SocketConnection connection, int64 maxLength = int64.max) @safe {
	int64 length = connection.receiveLength(maxLength);
	auto buffer = new ubyte[](length);
	auto data = connection.receiveAll(buffer);
	return Message(data);
}

/// ditto
Message receiveMessage(ref SocketConnection connection, ubyte[] buffer) @safe {
	int64 length = connection.receiveLength(buffer.length);
	auto data = connection.receiveAll(buffer[0 .. length]);
	return Message(data);
}
