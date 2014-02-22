class Record{
  String cathegory;
  String subCathegory;
  double cost;
  String date;
  Record(){
    this.cathegory = "";
    this.date = "";
    this.cost = 0.0;
  }
  Record.setter(this.cathegory, this.cost, this.date, [this.subCathegory=""]){
    var matcher = new RegExp('/./');
    if(this.date != "" && matcher.hasMatch(this.date)){
      throw new Exception();
    }
  }
  Map toMap(){
    if(this.cathegory.isNotEmpty && this.date.isNotEmpty){
      return {
        "Cathegory": this.cathegory, 
        "Cost":this.cost,
        "Date": this.date,
        "Subcathegory": this.subCathegory
        };
    }
    return {};
  }
}