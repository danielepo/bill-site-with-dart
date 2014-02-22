import 'package:unittest/unittest.dart';
import "dbinterface.dart";
import "record.dart";
void main(){
  DbInterface db;
  group('Data Collector Tests', () {
    test('Empty returns Empty Map',(){
      Record record = new Record();
      Map recordReady = record.toMap();
      expect(recordReady.isEmpty,isTrue);
    });
    test('Empty returns Empty Map',(){
      Record record = new Record.setter("",0.0,"");
      Map recordReady = record.toMap();
      expect(recordReady.isEmpty,isTrue);
    });
    test('Set Cathegory and Date return Map',(){
      Record record = new Record.setter("cat",1.0,"01-01-1990");
      Map recordReady = record.toMap();
      expect(recordReady.isEmpty,isFalse);
      expect(recordReady["Cathegory"], "cat");
      expect(recordReady["Cost"],1.0);
      expect(recordReady["Date"],"01-01-1990");
    });
    test('Set Sub Cathegory return Map',(){
      Record record = new Record.setter("cat",0.0,"01-01-1990","sub");
      Map recordReady = record.toMap();
      expect(recordReady.isEmpty,isFalse);
      expect(recordReady["Subcathegory"], "sub");

    });
    test('Wrong Date should throw',(){
      expect(() => new Record.setter("cat",0.0,"awrongdate","sub"), throws);
    });
  });
  group('dbInteface Tests', () {
    setUp(() {db = new DbInterface("127.0.0.1","test1");});

    test('Save One Entry', () {
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert([{"Cathegory":"Alimentari","Costo":"30"}]))
        .then((_) => db.countCollection())
        .then(expectAsync((value) => expect(value, equals(1))))        
        .then((_) => db.close());
      
      
    });
    test('No Saves Equals Zero', () {
      db.open()
        .then((_) => db.drop())
        .then((_) => db.countCollection())
        .then(expectAsync((value) => expect(value, equals(0))))        
        .then((_) => db.close());
      
      
    });
    test('Reads All Cathegories', () {
      List inserimenti = [{"Cathegory":"Alimentari","Costo":"30"},
                          {"Cathegory":"Alimentari","Costo":"30"},
                          {"Cathegory":"Regali","Costo":"30"},
                          {"Cathegory":"Auto","Costo":"30"}];
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert(inserimenti))
        .then((_) => db.getAllCathegoires())
        .then(expectAsync((value){
          List val =value["values"]; 
          expect(val.length, equals(3)); 
          expect(val.contains("Alimentari"),isTrue);
          expect(val.contains("Regali"),isTrue);
          expect(val.contains("Auto"),isTrue);
        }))        
        .then((_) => db.close());
      
      
    });
  });
}