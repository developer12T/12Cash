import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? socket;
  String latestMessage = "";

  SocketService._internal() {
    connect();
  }

  void connect() {
    if (socket?.connected ?? false) return;
    socket = IO.io('${ApiService.apiHost}', {
      'transports': ['websocket'],
      'autoConnect': false,
      'path': '/socket.io',
    });

    socket!.connect();
    socket!.onConnect((_) {
      print('✅ Socket connected');
    });

    socket!.on('sale_getSummarybyArea', (data) {
      latestMessage = data['data'].toString();
      notifyListeners();
    });

    socket!.onDisconnect((_) => print('❌ Disconnected from socket'));
  }

  void emitEvent(String event, dynamic data) {
    if (socket?.connected ?? false) {
      socket!.emit(event, data);
      print('📤 Socket emit: $event');
    } else {
      print('⚠️ Socket not connected, cannot emit');
    }
  }

  void disconnect() {
    socket?.disconnect();
  }
}
