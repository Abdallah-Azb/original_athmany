class Profile {
  String value;
  String description;

  Profile({this.value, this.description});

  Profile.fromServer(Map<String, dynamic> json) {
    this.value = json['value'];
    this.description = json['description'];
  }
}
