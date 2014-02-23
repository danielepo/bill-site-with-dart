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
    var matcher = new RegExp(r'^(0[1-9]|[1-2]\d{1}|3[0-1])-(0[1-9]|1[0-2])-(19|20)\d{2}$');
    if(this.date != "" && !this.date.contains(matcher)){
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