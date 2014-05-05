library transactionManager;
import 'dart:html';
import 'dart:convert';

class TransactionManager{
  WebSocket webSocket;
  var client;
  TransactionManager(this.webSocket,this.client);
  void insertTransaction() {
    if (client.cathegoryElement.value.isEmpty){
      return; 
    }
    client.setStatus('Adding...');

    var request = {
      'request': client.direction.selectedOptions.first.value,
      'value':{      
        'cathegory': client.cathegoryElement.value,
        'subcathegory': client.subCathegoryElement.value,
        'date': client.dateElement.value,
        'cost': client.costElement.value
        }
    };
    webSocket.send(JSON.encode(request));
  }
}