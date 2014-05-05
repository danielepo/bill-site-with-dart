library serverConnector;
import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'tablesManager.dart';

class ServerConnector{
  var client;
  
  static const Duration RECONNECT_DELAY = const Duration(milliseconds: 500);
  
  WebSocket webSocket;
  bool connectPending = false;
  TablesManager tm;
  
  ServerConnector(this.client);
  
  WebSocket connect() {
    connectPending = false;
    print('ws://${Uri.base.host}:${Uri.base.port}/ws');
    webSocket = new WebSocket('ws://${Uri.base.host}:${Uri.base.port}/ws');
    webSocket.onOpen.first.then((_) {
      onConnected();
      webSocket.onClose.first.then((_) {
        print("Connection disconnected to ${webSocket.url}");
        onDisconnected();
      });
    });
    webSocket.onError.first.then((_) {
      print("Failed to connect to ${webSocket.url}. "
            "Please run bin/server.dart and try again.");
      onDisconnected();
    });
    return webSocket;
  }
  void onConnected() {
    client.setStatus('');
    client.submit.disabled = false;
    client.cathegoryElement.focus();
    tm = new TablesManager(webSocket, client);
    tm.getTables();
    webSocket.onMessage.listen((e) {
      onMessage(e.data);
    });
  }

  void onDisconnected() {
    if (connectPending){
      return; 
    }
    connectPending = true;
    client.setStatus('Disconnected - start \'bin/server.dart\' to continue');
    client.submit.disabled = true;
    new Timer(RECONNECT_DELAY, connect);
  }
  
  void onMessage(data) {
    var json = JSON.decode(data);
    var response = json['response'];
    print("response: '$response'");
    switch (response) {
      case 'itemAdded':
        client.setStatus("Item Added");
        client.cleanInputs();
      break;
      case 'getTable':
        tm.printTable(json['value'],json['recordType']);
        break;
      case 'done':
        client.setStatus("Done");
        break;
      default:
        print("Invalid response: '$response'");
    }
  }
}