import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  String latestMessage = ""; // Store the latest message

  SocketService() {
    connect();
  }

  void connect() {
    socket = IO.io('http://192.168.44.187:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    // Prevent duplicate listeners
    socket.off('sale_response'); // Remove previous listener

    // Connection event
    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('message', 'Hello from Flutter!');
    });

    // Listen for server messages
    socket.on('sale_response', (data) {
      print('Message from server: $data');
      // print('Message from server: ${data.saleCode}');
      latestMessage = data['saleCode'].toString();
      notifyListeners(); // Notify UI about the change
    });

    // Handle disconnection
    socket.onDisconnect((_) => print('Disconnected from server'));
  }

  void disconnect() {
    socket.disconnect();
  }
}
