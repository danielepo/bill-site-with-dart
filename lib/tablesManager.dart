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
  
  void printTable(List lista, String recordType){

    lista.sort((x,y) => _sortByDate(x, y));
    
    TableElement table = new TableElement();
    
    Iterator listIterator = lista.iterator;
    TableRowElement head = table.createTHead().addRow();
    head.addCell().text = "Day";
    head.addCell().text = "Cathegory";
    head.addCell().text = "Sub Cathegory";
    head.addCell().text = "Cost";

    TableSectionElement body = table.createTBody();
    var rows =  '';
    while (listIterator.moveNext()){
      var tableRow = listIterator.current;
      
      String cat = tableRow["Cathegory"].toString();
      String subcat = tableRow["Subcathegory"].toString();     
      String day = DateTime.parse(tableRow["Date"].toString()).day.toString();
      String cost = tableRow["Cost"].toString();
      TableRowElement row = body.addRow();
      row.addCell().text = day;
      row.addCell().text = cat;
      row.addCell().text = subcat;
      row.addCell().text = cost;

    }
    client.setTable(table,recordType);
  }
  
  
  int _sortByDate(x,y){
    var a = DateTime.parse(x['Date'].toString()); 
    var b = DateTime.parse(y['Date'].toString());
    return a.compareTo(b);
  }
}