
extension FixFirstHour on String {
  // because DateTime.now() on 00:00 AM gives the hour value
  // that equal to 24 which suppose to be 00
  modifyFirstHour(){
    if(this.contains(' 24:')) {
      print("YAY");
      return this.replaceFirst(RegExp(r' 24:'), ' 00:');
    }
    return this;
  }
}