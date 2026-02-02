import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng selectedLocation = LatLng(11.5564, 104.9282); // Phnom Penh
  String address = "Tap on map to select location";

  // 🔁 Convert lat/lng → real address
  Future<void> getAddress(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      Placemark place = placemarks.first;

      setState(() {
        address =
            "${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
      });
    } catch (e) {
      address = "Address not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick Location"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: {
                "address": address,
                "lat": selectedLocation.latitude,
                "lng": selectedLocation.longitude,
              });
            },
            child: Text("DONE", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          // 🗺️ MAP
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: selectedLocation,
                initialZoom: 15,
                onTap: (tapPosition, point) {
                  selectedLocation = point;
                  getAddress(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 📍 ADDRESS DISPLAY
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: Text(
              address,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
