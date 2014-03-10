import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async' show Future;
import 'record.dart';

class DbInterface{
  Db _dbHandler;
  DbCollection _database;
  String _serverAddress;
  String _dbName;
  String _collection;
  
  DbInterface(this._serverAddress,this._dbName,[this._collection = "testCollection2"]);
  
  Future open(){
    _dbHandler = new Db('mongodb://$_serverAddress/$_dbName');
    
    return _dbHandler.open().then((_){
      _database = _dbHandler.collection(this._collection);
    });
  }
  Future drop(){
    return _database.drop();
  }
  Future insert(List<Record> data){
          return Future.forEach(data, (elm)  {
            _database.insert(elm.toMap(), writeConcern: WriteConcern.ACKNOWLEDGED);
          });
        }
  Future getAllCathegoires(){
    return _database.distinct("Cathegory");
  }
  Future getAllSubCathegoires(){
    return _database.distinct("Subcathegory");
  }
  Future getByDate(DateTime date,[var wholeMonth = false]){
    Future returnedList = null;
    if(wholeMonth){
      var start = new DateTime(date.year, date.month);
      var newYear = date.month==12?date.year + 1: date.year;
      var newMonth = date.month==12? 1: date.month +1;
      var end = new DateTime(newYear, newMonth);
      returnedList = _database.find({"Date":{"\$gte": start, "\$lt": end}}).toList();
    }
    else{
      var start = date;
      returnedList = _database.find({"Date": date }).toList();
    }
    return returnedList;
  }
  Future getByDateRange(DateTime dateLower, DateTime dateHigher){
    return _database.find({"Date":{"\$gte": dateLower, "\$lte": dateHigher}}).toList();
  }
  Future close(){
         return _dbHandler.close();
  }
  Future countCollection(){
    return _database.count();
  }
  

}
