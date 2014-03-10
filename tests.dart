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
      Record record = new Record.setter("",0.0,null);
      Map recordReady = record.toMap();
      expect(recordReady.isEmpty,isTrue);
    });
    test('Set Cathegory and Date return Map',(){
      Record record = new Record.setter("cat",1.0,new DateTime(1990,12,12));
      Map recordReady = record.toMap();
      expect(recordReady.isEmpty,isFalse);
      expect(recordReady["Cathegory"], "cat");
      expect(recordReady["Cost"],1.0);
      DateTime d = recordReady["Date"];
      expect(d.compareTo(new DateTime(1990,12,12)),0);
    });
    test('Set Sub Cathegory return Map',(){
      Record record = new Record.setter("cat",0.0,new DateTime(1990,12,12),"sub");
      Map recordReady = record.toMap();
      expect(recordReady.isEmpty,isFalse);
      expect(recordReady["Subcathegory"], "sub");

    });
  });
  group('dbInteface Tests', () {
    setUp(() {db = new DbInterface("127.0.0.1","test1");});

    test('Save One Entry', () {
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert([new Record.setter("Alimentari", 30.3, new DateTime(1912, 12, 12))]))
        .then((_) => db.countCollection())
        .then(expectAsync((value) => expect(value, equals(1))))        
        .then((_) => db.close());
    });
    skip_test('No Saves Equals Zero', () {
      db.open()
        .then((_) => db.drop())
        .then((_) => db.countCollection())
        .then(expectAsync((value) => expect(value, equals(0))))        
        .then((_) => db.close());
    });
    test('Reads All Cathegories', () {
      List inserimenti = [
        new Record.setter("Alimentari",2.2,new DateTime(1912, 12, 12)),
        new Record.setter("Alimentari",30.1,new DateTime(1912, 12, 12)),
        new Record.setter("Regali",30.1,new DateTime(1912, 12, 12)),
        new Record.setter("Auto",30.1,new DateTime(1912, 12, 12))
      ];
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
    test('Reads All SubCathegories', () {
      List inserimenti = [
        new Record.setter("Alimentari",2.2,new DateTime(1912, 12, 12),"Coop"),
        new Record.setter("Alimentari",30.1,new DateTime(1912, 12, 12)),
        new Record.setter("Regali",30.1,new DateTime(1912, 12, 12),"Regalo Paola"),
        new Record.setter("Auto",30.1,new DateTime(1912, 12, 12),"GPL"),
        new Record.setter("Auto",30.1,new DateTime(1912, 12, 12),"Gas"),
        new Record.setter("Auto",30.1,new DateTime(1912, 12, 12),"Gas")
      ];
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert(inserimenti))
        .then((_) => db.getAllSubCathegoires())
        .then(expectAsync((value){
          
          List val =value["values"];
          print(val);
          expect(val.length, equals(5)); 
          expect(val[0],"Coop");
          expect(val[1],"");
          expect(val[2],"Regalo Paola");
          expect(val[3],"GPL");
          expect(val[4],"Gas");
        }))        
        .then((_) => db.close());
      
      
    });
    test('Retreive a specific date', (){
      List inserimenti = [
                          new Record.setter("cat",0.0,new DateTime(1912, 12, 12))
                          ];
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert(inserimenti))
        .then((_) => db.getByDate(new DateTime(1912, 12, 12)))
        .then(expectAsync((value){
          List<Map> valList = value;
          
          expect(valList.length,1);
          
          Iterator<Map> it = valList.iterator;
          
          while(it.moveNext()){
            
            Map val = it.current;
            expect(val["Date"], new DateTime(1912, 12, 12));
          }
        }))        
        .then((_) => db.close());
    });
    test('Retreive a range date one day', (){
      List inserimenti = [
                          new Record.setter("1",0.0,new DateTime(1912, 12, 12)),
                          new Record.setter("2",0.0,new DateTime(1912, 12, 10)),
                          new Record.setter("3",0.0,new DateTime(1912, 12, 15))
                          ];
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert(inserimenti))
        .then((_) => db.getByDateRange(new DateTime(1912, 12, 12),new DateTime(1912, 12, 12)))
        .then(expectAsync((value){
          List<Map> valList = value;
          
          expect(valList.length,1);
          
          Iterator<Map> it = valList.iterator;
          expect(valList.length, 1);
          while(it.moveNext()){
            
            Map val = it.current;
            expect(val["Cathegory"], "1");
          }
        }))        
        .then((_) => db.close());
    });
    test('Retreive a range date 3 days different years', (){
      List inserimenti = [
                          new Record.setter("1",0.0,new DateTime(1911, 12, 11)),
                          new Record.setter("21",0.0,new DateTime(1912, 12, 11)),
                          new Record.setter("22",0.0,new DateTime(1912, 12, 12)),
                          new Record.setter("23",0.0,new DateTime(1912, 12, 13)),
                          new Record.setter("3",0.0,new DateTime(1913, 12, 11))
                          ];
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert(inserimenti))
        .then((_) => db.getByDateRange(new DateTime(1911, 12, 11),new DateTime(1911, 12, 13)))
        .then(expectAsync((value){
          List<Map> valList = value;          
          expect(valList.length,1);                   
        }))        
        .then((_) => db.close());
    });
    test('Retreive all days in one month', (){
      List inserimenti = [
                          new Record.setter("1",0.0,new DateTime(1911, 12, 11)),
                          new Record.setter("21",0.0,new DateTime(1912, 12, 1)),
                          new Record.setter("22",0.0,new DateTime(1912, 12, 12)),
                          new Record.setter("23",0.0,new DateTime(1912, 12, 31)),
                          new Record.setter("3",0.0,new DateTime(1913, 1, 1))
                          ];
      db.open()
        .then((_) => db.drop())
        .then((_) => db.insert(inserimenti))
        .then((_) => db.getByDate(new DateTime(1912, 12),true))
        .then(expectAsync((value){
          List<Map> valList = value;          
          expect(valList.length,3);                   
        }))        
        .then((_) => db.close());
    });
  });
}