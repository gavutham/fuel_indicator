import "dart:convert";

import "package:flutter/material.dart";
import "package:petrol_indicator/models/user.dart";
import "package:petrol_indicator/models/vehicle.dart";
import "package:petrol_indicator/services/auth.dart";
import "package:petrol_indicator/services/database.dart";
import "package:provider/provider.dart";
import "dart:async";
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final baseUrl = "http://172.16.72.194:3247";
  final _auth = AuthService();
  VehicleData? vehicle;
  double? volume;
  double? distance;
  String? latitude;
  String? longitude;


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData?>(context);

    //for vehicle data
    getVehicle() async {
      final _db = DatabaseService(uid: user!.uid);
      dynamic res = await _db.getVehicleData(user.vehicles[0]);
      setState(() {
        vehicle = res;
      });
    }
    if (user != null && vehicle == null) {
      getVehicle();
    }

    //refill optimization
    getLocation() async {
      if(vehicle != null){
        final response = await http.get(Uri.parse("$baseUrl/efficient?vid=${vehicle?.vid}"));
        if (response.statusCode == 200) {
          dynamic data = jsonDecode(response.body);
          setState(() {
            latitude = data["lat"];
            longitude = data["long"];
          });
        }
      }
    }
    if(user != null && latitude == null) {
      getLocation();
    }

    //prediction with ml
    predictKm() async {
      if(vehicle != null){
        final response = await http.get(Uri.parse("$baseUrl/predict?vid=${vehicle?.vid}"));
        if (response.statusCode == 200) {
          print(response.body);
          dynamic data = jsonDecode(response.body);
          setState(() {
            distance = data["km"];
          });
        }
      }
    }

    // fuel level
    getLevel() async {
        if(vehicle != null){
          final response = await http.get(Uri.parse("$baseUrl/fuelvolume?vid=${vehicle?.vid}"));
          if (response.statusCode == 200) {
            setState(() {
              volume = jsonDecode(response.body)["volume"];
            });
          }
        }
    }
    Timer.periodic(
        const Duration(seconds: 5), (timer) {
          getLevel();
        }
    );

    buildVolumeWidget() {
      var fullVolume;
      if (vehicle!.fuelTankShape == "Cuboid") {
        fullVolume = double.parse(vehicle!.length!) * double.parse(vehicle!.breadth!) * double.parse(vehicle!.height!) / 1000;
      }else{
        fullVolume = 3.14 * double.parse(vehicle!.diameter!) * double.parse(vehicle!.diameter!) * double.parse(vehicle!.height!) / 4000;
      }
      return Column(
        children: [

          Container(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Fuel Level: $volume Litres",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
          ),
          const SizedBox(height: 50,),

          Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: volume!/fullVolume,
                    strokeWidth: 10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    backgroundColor: Colors.grey,
                  ),
                  Center(
                    child: Text(
                      '${(volume! *100/fullVolume).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fuel Indicator"),
        actions: [
          ElevatedButton(
            onPressed: () {
              _auth.signOut();
            },
            child: const Text("Logout"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi ${user?.name}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700
              ),
            ),
            const SizedBox(height: 20,),
            Text(
              "Vehicle name: ${vehicle?.name}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              )
            ),
            SizedBox(height: 20,),
            if(volume!=null) buildVolumeWidget(),
            SizedBox(height: 20,),
            if(distance == null) ElevatedButton(
              onPressed: predictKm,
              child: const Text("Predict KM")
            ),
            if(distance != null) Text("Distance that can be covered: $distance KM"),
            SizedBox(height: 20,),
            Text(
              "Your refill at latitude: $latitude longitude: $longitude gave best mileage in last few days",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
