import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async' show Future;
class DbInterface{
  Db _dbHandler;
  DbCollection _database;
  String _serverAddress;
  String _dbName;
  
  DbInterface(this._serverAddress,this._dbName);
  
  Future open(){
    _dbHandler = new Db('mongodb://$_serverAddress/$_dbName');
    
    return _dbHandler.open().then((_){
      _database = _dbHandler.collection("testCollection2");
      
    });
  }
  Future drop(){
    return _database.drop();
  }
  Future insert(var data){
  
          return Future.forEach(data, (elm)  {
              _database.insert(elm, writeConcern: WriteConcern.ACKNOWLEDGED);
          });
        }
  Future getAllCathegoires(){
    return _database.distinct("Cathegory");
  }
  Future close(){
         return _dbHandler.close();
  }
  Future countCollection(){
    return _database.count();
  }
  

}
