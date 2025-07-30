import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? socket;
  String latestMessage = "";
  String updateStoreStatus = "";
  String statusOrderUpdated = "";
  String withdrawUpdate = "";
  String refundUpdate = "";
  String giveUpdate = "";

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

    socket!.on('order/statusOrderUpdated', (data) {
      statusOrderUpdated = data['updatedCount'].toString();
      notifyListeners();
    });

    socket!.on('store/updateStoreStatus', (data) {
      updateStoreStatus = data['data'].toString();
      notifyListeners();
    });

    socket!.on('distribution/approveWithdraw', (data) {
      withdrawUpdate = data['data'].toString();
      notifyListeners();
    });

    socket!.on('give/approve', (data) {
      giveUpdate = data['data'].toString();
      notifyListeners();
    });

    socket!.on('refund/updateStatus', (data) {
      refundUpdate = data['data'].toString();
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
