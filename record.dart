class Record{
  String cathegory;
  String subCathegory;
  double cost;
  String date;
  DateTime date2;
  Record(){
    this.cathegory = "";
    this.date = "";
    this.cost = 0.0;
  }

  Record.setter(this.cathegory, this.cost, this.date2, [this.subCathegory=""]);
 
  Map toMap(){
    if(this.cathegory.isEmpty || this.date2 == null){
      return {};
    }
    return {
      "Cathegory": this.cathegory, 
      "Cost":this.cost,
      "Date": this.date2,
      "Subcathegory": this.subCathegory
    };
  }
}