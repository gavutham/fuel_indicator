import "package:cloud_firestore/cloud_firestore.dart";
import "package:petrol_indicator/models/user.dart";
import "package:petrol_indicator/models/vehicle.dart";

class DatabaseService {
  
  String? uid;
  String? vid;
  
  DatabaseService({required this.uid, this.vid});

  final CollectionReference vehicleCollection = FirebaseFirestore.instance.collection("vehicles");
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");

  Future setUserData(UserData user) async {
    final ref = userCollection.doc(user.uid);

    final data = {
      "uid": user.uid,
      "name": user.name,
      "vehicles": user.vehicles,
      "email": user.email,
    };

    return await ref.set(data);
  }

  Future setVehicleDetails(VehicleData vehicle) async {

    final ref = vehicleCollection.doc(vehicle.vid);
    Map<String, dynamic> data;

    if (vehicle.fuelTankShape == "Cuboid") {
      data = {
        "vid": vehicle.vid,
        "name": vehicle.name,
        "fueltank_shape": vehicle.fuelTankShape,
        "length": vehicle.length!,
        "breadth": vehicle.breadth!,
        "height": vehicle.height!,
      };
    }else{
      data = {
        "vid": vehicle.vid,
        "name": vehicle.name,
        "fueltank_shape": vehicle.fuelTankShape,
        "diameter": vehicle.diameter!,
        "height": vehicle.height!,
      };
    }


    return await ref.set(data);
  }

  _vehicleDataFromFirebase(Map data) {
    final fuelTankShape = data["fueltank_shape"];

    var vehicle;

    if (fuelTankShape == "Cuboid") {
      vehicle = VehicleData(
        vid: data["vid"],
        name: data["name"],
        fuelTankShape: data["fueltank_shape"],
        length: data["length"],
        breadth: data["breadth"],
        height: data["height"]
      );
    }else {
      vehicle = VehicleData(
          vid: data["vid"],
          name: data["name"],
          fuelTankShape: data["fueltank_shape"],
          height: data["height"],
          diameter: data["diameter"],
      );
    }
    return vehicle;
  }

  Future getVehicleData(String vid) async {
    final ref = vehicleCollection.doc(vid);

    final snapshot = await ref.get();
    return _vehicleDataFromFirebase(snapshot.data()! as Map<String, dynamic>);
  }

  _userDataFromFirebase(Map data) {
    return UserData(
      uid: data["uid"],
      name: data["name"],
      vehicles: data["vehicles"],
      email: data["email"]
    );
  }

  Stream<UserData?> get userData {
    return userCollection.doc(uid).snapshots().map((snap) => _userDataFromFirebase(snap.data()! as Map<String, dynamic>));
  }

  Stream<VehicleData?> get vehicleData {
    return vehicleCollection.doc(vid).snapshots().map((snap) {
      try{
        return _vehicleDataFromFirebase(snap.data() as Map<String, dynamic>);
      }catch(err){
        return null;
      }
    });
  }
}