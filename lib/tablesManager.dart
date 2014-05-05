library tablesManager;
import 'dart:html';
import 'dart:convert';

class TablesManager {
  WebSocket webSocket;
  var client;
  TablesManager(this.webSocket,this.client);
  
  void getTables() {
  
      client.setStatus('Reading Tables...');
      List<String> tables = ['outgoings', 'incomings'];
      tables.forEach((e){
        var request = {
                       'request': "getTable",
                       'collection':e,
                       'date' : client.monthElement.valueAsDate.toString()
        };
        webSocket.send(JSON.encode(request));
      });
      
    
  }
  printTable(List lista, String recordType){

    lista.sort((x,y) {
      var a = DateTime.parse(x['Date'].toString()); 
      var b = DateTime.parse(y['Date'].toString());
      return a.compareTo(b);
    });
    Iterator listIterator = lista.iterator;
    var rows =  '';
    while (listIterator.moveNext()){
      var tableRow = listIterator.current;
      
      var cat = tableRow["Cathegory"].toString();
      var subcat = tableRow["Subcathegory"].toString();
      DateTime date =DateTime.parse(tableRow["Date"].toString());
      String year = date.year.toString();
      String month = date.month.toString();
      String day = date.day.toString();
      
      var cost = tableRow["Cost"].toString();
      rows+= ("<tr><td>" +cat + "</td><td>" + subcat + "</td><td>" + cost + "</td><td>" + day +"</td></tr>");

    }
    _setTable('<table>' + rows + '<table>',recordType);
  }
  void _setTable(String table, String action) {
    DivElement div = querySelector('#' + action);
    div.innerHtml = table;
  }
}