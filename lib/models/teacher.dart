class Teacher {
  int id;
  String name;
  String? prefix;
  String? suffix;
  String? subject;

  String? token;
  String? email;

  Teacher(this.id, this.name, {this.prefix, this.suffix, this.subject, this.token, this.email});
}
