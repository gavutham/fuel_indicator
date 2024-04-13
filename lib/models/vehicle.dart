class VehicleData {
  String vid;
  String name;
  String fuelTankShape;
  String? height;
  String? length;
  String? breadth;
  String? diameter;

  VehicleData({
    required this.vid,
    required this.name,
    required this.fuelTankShape,
    this.height,
    this.breadth,
    this.length,
    this.diameter,
  });
}