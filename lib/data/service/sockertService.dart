import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  String latestMessage = ""; // Store the latest message

  SocketService() {
    connect();
  }

  void connect() {
    socket = IO.io('https://apps.onetwotrading.co.th', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'path': '/socket.io',
    });

    socket.connect();

    // Prevent duplicate listeners
    socket.off('sale_getSummarybyArea'); // Remove previous listener

    // Connection event
    socket.onConnect((_) {
      print('Connected to server socket');
      socket.emit('message', 'Hello from Flutter!');
    });

    // Listen for server messages
    socket.on('sale_getSummarybyArea', (data) {
      print('Message from server: $data');
      // print('Message from server: ${data.saleCode}');
      // latestMessage = data['saleCode'].toString();
      latestMessage = data['data'].toString();
      print(latestMessage);
      notifyListeners(); // Notify UI about the change
    });

    // Handle disconnection
    socket.onDisconnect((_) => print('Disconnected from server'));
  }

  void disconnect() {
    socket.disconnect();
  }
}
