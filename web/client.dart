// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import '../lib/serverConnector.dart';
import '../lib/tablesManager.dart';
import '../lib/transactionManager.dart' as tM;

void main() {
  var client = new Client();
}
class Client {
  

  
  WebSocket webSocket;
  List<String> cathegories;
  
  final DivElement log = new DivElement();
  
  TextInputElement catFilterElement = querySelector('#cat_filter');
  SelectElement cathegoryElement = querySelector('#cat');
  TextInputElement subCathegoryElement = querySelector('#subcat');
  DateInputElement dateElement = querySelector('#date');
  TextInputElement costElement = querySelector('#cost');
  ButtonElement submit = querySelector('#submit');
  ButtonElement updateTables = querySelector("#update_tables");
  
  MonthInputElement monthElement = querySelector("#selectedMonth");
  SelectElement direction = querySelector('#dir');
  
  DivElement statusElement = querySelector('#status');

  tM.TransactionManager transact ;
  TablesManager tabelsMan;
  Client() {
    submit.disabled = true;
    ServerConnector c = new ServerConnector(this);
    webSocket = c.connect();
    transact = new tM.TransactionManager(webSocket,this);
    tabelsMan = new TablesManager(webSocket,this);
    
    submit.onClick.listen((e) {
      transact.insertTransaction();
      getCathegories();
    });
    
    updateTables.onClick.listen((e) => tabelsMan.getTables());
    dateElement.valueAsDate = new DateTime.now();
    monthElement.valueAsDate = new DateTime.now();
  
    cathegoryElement
    ..onKeyUp.listen((e) => areValid())
    ..onChange.listen((e) => areValid());
    
    subCathegoryElement
    ..onKeyUp.listen((e) => areValid())
    ..onChange.listen((e) => areValid());
    
    costElement
      ..onKeyUp.listen((e) => areValid())
      ..onChange.listen((e) => areValid());
    
    catFilterElement
        ..onKeyUp.listen((e) => updateCathegories())
        ..onChange.listen((e) => updateCathegories());
  }
  void updateCathegories(){
    SelectElement sel = cathegoryElement;
    String catFilter = catFilterElement.value;
     Iterator cathegoriesIt = cathegories.iterator;
     
     while(cathegoriesIt.moveNext()){
       var cathegory = cathegoriesIt.current;
       if(catFilter.isEmpty){
         sel.nodes.add(new OptionElement(data:cathegory, value: cathegory));
       }else{
         if(cathegory.indexOf(catFilter) != -1){
            sel.nodes.add(new OptionElement(data:cathegory, value: cathegory));
         }
       }
     }
  }
  void areValid(){
    if(cathegoryElement.value.isEmpty || 
        subCathegoryElement.value.isEmpty || costElement.value.isEmpty){
      submit.disabled = true;
    }
    else{
      submit.disabled = false;
    }
  }
  void setStatus(String status) {
    statusElement.innerHtml = status;
  }
    
  void cleanInputs(){
    cathegoryElement.value='';
    subCathegoryElement.value='';
    costElement.value='';
  }
  void setTable(TableElement table, String action) {
    DivElement div = querySelector('#' + action);
    div.nodes.add(table);
  }
  void getCathegories(){
    var request = {
                   'request': "getCathegories",
                   "collection": direction.selectedOptions.first.value
                   
    };
    webSocket.send(JSON.encode(request));
  }
}



