// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';

void main() {
  var client = new Client();
}
class Client {
  static const Duration RECONNECT_DELAY = const Duration(milliseconds: 500);

  bool connectPending = false;
  WebSocket webSocket;
  
  final DivElement log = new DivElement();
  
  TextInputElement cathegoryElement = querySelector('#cat');
  TextInputElement subCathegoryElement = querySelector('#subcat');
  DateInputElement dateElement = querySelector('#date');
  TextInputElement costElement = querySelector('#cost');
  ButtonElement submit = querySelector('#submit');
  MonthInputElement monthElement = querySelector("#selectedMonth");
  SelectElement direction = querySelector('#dir');
  
  DivElement statusElement = querySelector('#status');
  DivElement resultsElement = querySelector('#results');

  Client() {
    submit.onClick.listen((e) {
      insertTransaction();
      //searchElement.value = '';
    });
    dateElement.valueAsDate = new DateTime.now();
    monthElement.valueAsDate = new DateTime.now();
    connect();
  }
  void insertTransaction() {
    if (cathegoryElement.value.isEmpty){
      return; 
    }
    setStatus('Adding...');
    resultsElement.children.clear();
 //   print(direction.selectedOptions.first);
    var request = {
      'request': direction.selectedOptions.first.value,
      'value':{      
        'cathegory': cathegoryElement.value,
        'subcathegory': subCathegoryElement.value,
        'date': dateElement.value,
        'cost': costElement.value
        }
    };
    webSocket.send(JSON.encode(request));
  }
  void setStatus(String status) {
    statusElement.innerHtml = status;
  }
  void connect() {
    connectPending = false;
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
  }

  void onConnected() {
    setStatus('');
    submit.disabled = false;
    cathegoryElement.focus();
    webSocket.onMessage.listen((e) {
      onMessage(e.data);
    });
  }

  void onDisconnected() {
    if (connectPending){
      return; 
    }
    connectPending = true;
    setStatus('Disconnected - start \'bin/server.dart\' to continue');
    submit.disabled = true;
    new Timer(RECONNECT_DELAY, connect);
  }
  
  void onMessage(data) {
    var json = JSON.decode(data);
    var response = json['response'];
    print("response: '$response'");
    switch (response) {
      case 'itemAdded':
        setStatus("Item Added");
        var lista = json['value'];
          print(lista[0]["Cathegory"]);
        
        break;

      default:
        print("Invalid response: '$response'");
    }
  }

  
}



