
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:petrol_indicator/models/user.dart';
import 'package:petrol_indicator/models/vehicle.dart';
import 'package:petrol_indicator/screens/wrapper.dart';
import 'package:petrol_indicator/services/auth.dart';
import 'package:petrol_indicator/services/database.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          final user = snapshot.hasData ? snapshot.data : null;
          return StreamBuilder<UserData?>(
            stream: DatabaseService(uid: user?.uid).userData,
            builder: (context, snapshot) {
              final userdata = snapshot.hasData ? snapshot.data : null;
              return MultiProvider(
                providers: [
                  StreamProvider<User?>.value(
                    initialData: null,
                    value: AuthService().user,
                  ),
                  StreamProvider<UserData?>.value(
                    initialData: null,
                    value: DatabaseService(uid: user?.uid).userData,
                  ),
                  // StreamProvider<VehicleData?>.value(
                  //   initialData: null,
                  //   value: DatabaseService(uid: user?.uid, vid:userdata?.vehicles[0]).vehicleData,
                  // )
                ],
                child: const MaterialApp(
                  home: Wrapper(),
                  debugShowCheckedModeBanner: false,
                ),
              );
            },
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

