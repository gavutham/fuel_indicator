import "package:firebase_auth/firebase_auth.dart";
import "package:petrol_indicator/models/user.dart" as usermodel;
import "package:petrol_indicator/models/vehicle.dart";
import "package:petrol_indicator/services/database.dart";

class AuthService {
  final _auth = FirebaseAuth.instance;

  usermodel.User? _appUserFromFirebase(User? user) {
    return user != null ? usermodel.User(uid: user.uid) : null;
  }

  Stream<usermodel.User?> get user {
    return _auth.authStateChanges().map(_appUserFromFirebase);
  }


  // sign in email/password
  Future signIn(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _appUserFromFirebase(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }


  //register in email/password
  Future signUp(String email, String password, String name, VehicleData vehicle) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      final db = DatabaseService(uid: user!.uid);



      await db.setVehicleDetails(vehicle);

      await db.setUserData(
          usermodel.UserData(uid: user.uid, name: name, email: email, vehicles: [vehicle.vid])
      );

      return _appUserFromFirebase(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch (err){
      print(err.toString());
      return null;
    }
  }
}

