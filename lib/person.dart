class Person {
  int stt;
  String name;
  String address;
  String phoneNumber;
  Person({
    required this.stt,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });
  factory Person.init() {
    return Person(name: "", address: "", phoneNumber: "", stt: 0);
  }
}
