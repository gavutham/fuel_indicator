class UserData {
  String uid;
  String name;
  String email;
  List<dynamic> vehicles;

  UserData({
    required this.uid,
    required this.name,
    required this.email,
    required this.vehicles
  });
}

class User {
  String uid;

  User({required this.uid});
}