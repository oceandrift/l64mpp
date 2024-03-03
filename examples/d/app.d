module app;

import std.stdio;

immutable string host = "127.0.0.1";
immutable ushort port = 23456;

int main(string[] args) @safe {
	if (args.length != 2) {
		writeln("Error: No mode selected or too many args.");
		writeUsage(args[0]);
		return 1;
	}

	switch (args[1]) {

	default:
		writeln("Error: Unknown mode \"", args[1], "\".");
		writeUsage(args[0]);
		return 1;

	case "server":
		runServer();
		return 0;

	case "client":
		runClient();
		return 0;
	}

	assert(false, "unreachable");
}

private:

void writeUsage(const string args0) @safe {
	writeln("Usage:\n\t", args0, " server\n\t\tor\n\t", args0, " client");
}

void runServer() @safe {
	import l64mpp;
	import std.socket;
	import socketplate.connection;

	auto socket = new TcpSocket(AddressFamily.INET);
	socket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
	socket.blocking = true;
	socket.bind(new InternetAddress(host, port));
	socket.listen(0);

	writeln("Waiting for an incoming connection.");
	auto connectionSocket = socket.accept();
	writeln("Incoming connection accepted.");
	auto connection = SocketConnection(connectionSocket);

	// ↓ Server example
	while (connection.isAlive) {
		Message msg = connection.receiveMessage();
		writeln("Message received (", msg.length, " bytes):\n: \"", msg.toString(), '"');

		if (msg.data == "exit") {
			connection.close();
			break;
		}
	}
	// ↑

	writeln("Connection has been closed.");
}

void runClient() @safe {
	import l64mpp;
	import socketplate.connection;
	import std.socket;
	import std.string : chomp;

	auto socket = new TcpSocket(new InternetAddress(host, port));
	auto connection = SocketConnection(socket);

	// ↓ Client example
	while (connection.isAlive) {
		write("Message> ");
		auto data = readLine().chomp();
		connection.sendMessage(Message(data));

		if (data == "exit") {
			connection.close();
			break;
		}
	}
	// ↑

	writeln("Connection has been closed.");
}

// faux trusted
string readLine() @trusted {
	if (stdin.eof) {
		throw new Exception("Error: stdin has been finalized.");
	}

	return readln();
}
