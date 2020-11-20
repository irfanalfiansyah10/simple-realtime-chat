import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart';

class SocketChatRepository{

  static const EVENT_CONNECT = "connect";
  static const EVENT_SOMEONE_SEND_MESSAGE = "someone send message";

  static const ACTION_SEND_MESSAGE = "i'm sending message";

  static final SocketChatRepository instance = SocketChatRepository._internal();

  Socket _socket;
  String baseUrl = "http://192.168.43.63:3000";

  SocketChatRepository._internal();

  Map<String, dynamic Function(dynamic)> _onEvent = Map<String, Function(dynamic)>();

  bool get isConnected => _socket != null ? _socket.connected : false;

  Future<void> connect({Map<String, dynamic> header}) async {
    if(_socket != null) return;

    Map<String, dynamic> config = {
      "transports": ["websocket"],
      "autoConnect": true,
    };

    if(header != null){
      config["extraHeaders"] = header;
    }

    _socket = io("$baseUrl", config);
    _onEvent.forEach((key, value) => _socket.on(key, value));
  }

  void disconnect(){
    _socket?.disconnect();
    _socket = null;
  }

  void addEventListener(String eventName, Function(dynamic) action){
    _onEvent[eventName] = action;
  }

  void emit(String actionName, [Map<String, dynamic> data]){
    print("Socket action : $actionName");
    _socket?.emit(actionName, jsonEncode(data));
  }

}