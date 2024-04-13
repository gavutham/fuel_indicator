import 'package:flutter/material.dart';
import 'package:petrol_indicator/models/vehicle.dart';
import 'package:petrol_indicator/services/auth.dart';
import 'package:petrol_indicator/services/database.dart';
import 'package:petrol_indicator/shared/loading.dart';
import 'package:uuid/uuid.dart';



const List<String> fuelTankTypes = ["Cuboid", "Cylindrical"];


class SignUp extends StatefulWidget {
  final void Function() toggleView;

  const SignUp({Key? key, required this.toggleView}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey =GlobalKey<FormState>();
  final _auth = AuthService();


  //form values
  String name = "";
  String email = "";
  String password = "";
  String vName = "";
  String? fuelTankType;
  String? height;
  String? breadth;
  String? length;
  String? diameter;

  String error = "";
  bool loading = false;

  buildDimensionsWidget() {
    if (fuelTankType == "Cuboid") {
      return [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(hintText: "Length"),
            onChanged: (value) {
              setState(() {
                length = value;
              });
            },
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(hintText: "Breadth"),
            onChanged: (value) {
              setState(() {
                breadth = value;
              });
            },
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(hintText: "Height"),
            onChanged: (value) {
              setState(() {
                height = value;
              });
            },
          ),
        ),
      ];
    }else if(fuelTankType == "Cylindrical") {
      return [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(hintText: "Diameter"),
            onChanged: (value) {
              setState(() {
                diameter = value;
              });
            },
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(hintText: "Height"),
            onChanged: (value) {
              setState(() {
                height = value;
              });
            },
          ),
        ),
      ];
    }
  }


  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        actions: [
          ElevatedButton(
            onPressed: widget.toggleView,
            child: const Text("Sign In"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 75),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: "Name"),
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Email"),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Password"),
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Vehicle Name"),
                  onChanged: (value) {
                    setState(() {
                      vName = value;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                DropdownButton<String>(
                  value: fuelTankType,
                  hint: const Text("Tank Type"),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Colors.grey,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      fuelTankType = value!;
                    });
                  },
                  items: fuelTankTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20,),
                Row(
                  children: fuelTankType != null ? buildDimensionsWidget() : [],
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                      error = "";
                    });
                    VehicleData vehicle;

                    if (fuelTankType == "Cuboid") {
                      vehicle = VehicleData(
                          vid: const Uuid().v4(),
                          name: vName,
                          fuelTankShape: fuelTankType!,
                          length: length,
                          breadth: breadth,
                          height: height
                      );
                    }else{
                      vehicle = VehicleData(
                        vid: const Uuid().v4(),
                        name: vName,
                        fuelTankShape: fuelTankType!,
                        diameter: diameter,
                        height: height
                      );
                    }

                    dynamic user = await _auth.signUp(email, password, name, vehicle);


                    if (user == null) {
                      if(mounted) {
                        setState(() {
                          loading = false;
                          error = "Can't sign in with given Credentials";
                        });
                      }
                    }
                  },
                  child: const Text("Sign In"),
                ),
                Text(
                    error,
                    style: const TextStyle(
                        color: Colors.red
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
