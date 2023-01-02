class Company {
  String value;
  String description;

  Company({this.value, this.description});

  Company.fromServer(Map<String, dynamic> json) {
    this.value = json['value'];
    this.description = json['description'];
  }
}
