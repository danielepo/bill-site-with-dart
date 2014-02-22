import "dbinterface.dart";
import 'dart:async' show Future;
void main(){
  //points to the default port of the local mongodb server 
  DbInterface intef = new DbInterface("127.0.0.1","test");
  
  intef.open()
    .then((_) => intef.countCollection())
    .then((_) => intef.insert([{"class":"value"},{"cas":"vals"}]))
    .then((_) => intef.getAllCathegoires())
      .then((cat){
        print(cat["values"]);
      })
    .then((_) => intef.countCollection())
    .then((_) => intef.close()); 
 }