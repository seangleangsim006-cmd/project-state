import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:project_state/model/payment_method.dart';
import 'package:project_state/service/qr_services.dart';
import 'package:project_state/service/telegram_service.dart';
import 'package:project_state/view/payment_method_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';



/* =========================
   SHOP MODEL
========================= */
class Shop {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final String type;
  final String image;
  final double rating;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.type,
    required this.image,
    required this.rating,
  });
}

/* =========================
   CONTROLLER
========================= */
class SelectPaymentControllerr extends GetxController {
  RxString selectedAddress = "".obs;
  Rx<LatLng?> selectedLatLng = Rx<LatLng?>(null);
  Rx<Shop?> selectedShop = Rx<Shop?>(null);
  RxDouble distanceToShop = 0.0.obs;
  RxInt deliveryTime = 0.obs;

  // Sample shops data - In real app, fetch from API
  final List<Shop> shops = [
    Shop(
      id: '1',
      name: 'Central Market Store',
      address: 'St 130, Phnom Penh',
      location: LatLng(11.5614, 104.9224),
      type: 'Supermarket',
      image: '🏪',
      rating: 4.5,
    ),
    Shop(
      id: '2',
      name: 'Royal Plaza Shop',
      address: 'St 154, Phnom Penh',
      location: LatLng(11.5534, 104.9312),
      type: 'Mall',
      image: '🏬',
      rating: 4.7,
    ),
    Shop(
      id: '3',
      name: 'Riverside Market',
      address: 'Sisowath Quay, Phnom Penh',
      location: LatLng(11.5689, 104.9289),
      type: 'Market',
      image: '🛒',
      rating: 4.3,
    ),
    Shop(
      id: '4',
      name: 'Downtown Store',
      address: 'St 63, Phnom Penh',
      location: LatLng(11.5498, 104.9201),
      type: 'Store',
      image: '🏪',
      rating: 4.6,
    ),
  ];

  // Calculate distance between two points (Haversine formula)
  double calculateDistance(LatLng from, LatLng to) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((to.latitude - from.latitude) * p) / 2 +
        c(from.latitude * p) *
            c(to.latitude * p) *
            (1 - c((to.longitude - from.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Find nearest shop
  Shop? findNearestShop(LatLng userLocation) {
    if (shops.isEmpty) return null;

    Shop? nearest;
    double minDistance = double.infinity;

    for (var shop in shops) {
      double distance = calculateDistance(userLocation, shop.location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = shop;
      }
    }

    distanceToShop.value = minDistance;
    return nearest;
  }

  // Get shops sorted by distance
  List<Map<String, dynamic>> getShopsWithDistance(LatLng userLocation) {
    List<Map<String, dynamic>> shopsWithDistance = shops.map((shop) {
      double distance = calculateDistance(userLocation, shop.location);
      return {
        'shop': shop,
        'distance': distance,
      };
    }).toList();
    
    shopsWithDistance.sort((a, b) {
      double distA = a['distance'] as double;
      double distB = b['distance'] as double;
      return distA.compareTo(distB);
    });
    
    return shopsWithDistance;
  }
}

/* =========================
   CONFIRM ORDER PAGE
========================= */
class ConfirmOrder extends StatelessWidget {
  final int productId; // ✅ Add this parameter
  ConfirmOrder({super.key, required this.productId,});

  final SelectPaymentControllerr paymentController =
      Get.put(SelectPaymentControllerr());
  QrServices qrServices = QrServices();
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Confirm Order",
            style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.location_on,
                            color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Address",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Select your delivery location",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Address Selection Card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      var result = await Get.to(
                        () => LocationPicker(),
                        transition: Transition.rightToLeft,
                        duration: Duration(milliseconds: 300),
                      );
                      if (result != null) {
                        paymentController.selectedAddress.value =
                            result["address"];
                        paymentController.selectedLatLng.value =
                            LatLng(result["lat"], result["lng"]);
                        paymentController.selectedShop.value =
                            result["shop"];
                        paymentController.distanceToShop.value =
                            result["distance"] ?? 0.0;
                        paymentController.deliveryTime.value =
                            result["duration"] ?? 0;
                      }
                    },
                    child: Obx(() {
                      bool hasAddress =
                          paymentController.selectedAddress.value.isNotEmpty;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasAddress
                                ? Colors.blue[700]!
                                : Colors.grey[300]!,
                            width: hasAddress ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: hasAddress ? 12 : 8,
                              spreadRadius: 0,
                              offset: Offset(0, 4),
                              color: Colors.black
                                  .withOpacity(hasAddress ? 0.15 : 0.08),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: hasAddress
                                        ? Colors.blue[50]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    hasAddress
                                        ? Icons.check_circle
                                        : Icons.add_location,
                                    color: hasAddress
                                        ? Colors.blue[700]
                                        : Colors.grey[600],
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hasAddress
                                            ? "Delivery Location"
                                            : "Add Address",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        hasAddress
                                            ? paymentController
                                                .selectedAddress.value
                                            : "Tap to select your delivery address",
                                        style: TextStyle(
                                          fontSize: hasAddress ? 15 : 16,
                                          fontWeight: hasAddress
                                              ? FontWeight.w500
                                              : FontWeight.w400,
                                          color: hasAddress
                                              ? Colors.black87
                                              : Colors.grey[500],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  // Nearest Shop Info
                  Obx(() {
                    if (paymentController.selectedShop.value != null) {
                      Shop shop = paymentController.selectedShop.value!;
                      double distance = paymentController.distanceToShop.value;
                      int deliveryTime = paymentController.deliveryTime.value > 0
                          ? paymentController.deliveryTime.value
                          : (distance * 5).ceil();

                      return Container(
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green[200]!),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              offset: Offset(0, 2),
                              color: Colors.black.withOpacity(0.05),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    shop.image,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              size: 16,
                                              color: Colors.amber),
                                          SizedBox(width: 4),
                                          Text(
                                            '${shop.rating}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              shop.type,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.route,
                                          size: 20, color: Colors.blue[700]),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Distance',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '${distance.toStringAsFixed(1)} km',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey[300],
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.schedule,
                                          size: 20, color: Colors.green[700]),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Est. Time',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '$deliveryTime min',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),

                  // Mini Map Preview with Real Route
                  Obx(() {
                    if (paymentController.selectedLatLng.value != null) {
                      return Container(
                        margin: EdgeInsets.only(top: 16),
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: paymentController.selectedLatLng.value!,
                            zoom: 13,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId("selected"),
                              position:
                                  paymentController.selectedLatLng.value!,
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueBlue),
                            ),
                            if (paymentController.selectedShop.value != null)
                              Marker(
                                markerId: MarkerId("shop"),
                                position: paymentController
                                    .selectedShop.value!.location,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen),
                              ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        bool hasAddress =
            paymentController.selectedAddress.value.isNotEmpty;
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, -4),
                color: Colors.black.withOpacity(0.05),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: hasAddress
                ? () {
                   Get.to(() => PaymentMethodd(productId:2 ));
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              disabledBackgroundColor: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "Continue to Payment",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: hasAddress ? Colors.white : Colors.grey[500],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/* =========================
   LOCATION PICKER PAGE
========================= */
class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController mapController;
  LatLng selectedPoint = LatLng(11.5564, 104.9282); // Phnom Penh
  String address = "Loading location...";
  bool isLoading = false;
  bool isLoadingCurrentLocation = false;
  bool isLoadingRoute = false;
  bool showNearbyShops = false;
  TextEditingController searchController = TextEditingController();
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Shop? nearestShop;
  List<Map<String, dynamic>> nearbyShops = [];
  List<LatLng> routeCoordinates = [];
  double routeDistance = 0.0;
  int routeDuration = 0;

  // ⚠️ SECURITY WARNING: Replace with your actual API key
  // DO NOT commit this to public repositories!
  // Use environment variables or secure storage in production
  final String googleApiKey = "AIzaSyBTzZVtm0j7PyCGPy7xKlHG0R5W_4dHAX0";

   SelectPaymentControllerr paymentController = Get.put(SelectPaymentControllerr());

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _updateLocation(selectedPoint);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Main location update - triggers route fetching
  Future<void> _updateLocation(LatLng position) async {
    setState(() {
      selectedPoint = position;
      isLoadingRoute = true;
    });
    
    // Update address
    await _getAddress(position);
    
    // Find nearby shops
    _findNearbyShops(position);
    
    // Fetch real route to nearest shop
    if (nearestShop != null) {
      await _getDirections(position, nearestShop!.location);
    } else {
      _updateMarkers();
    }
    
    setState(() => isLoadingRoute = false);
  }

  /// Fetch real street directions from Google Directions API
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    print('🚗 Fetching route from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');
    
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          // Extract encoded polyline
          String encodedPolyline =
              data['routes'][0]['overview_polyline']['points'];

          // Decode to get actual street coordinates
          List<PointLatLng> result =
              PolylinePoints.decodePolyline(encodedPolyline);

          // Convert to LatLng
          routeCoordinates = result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          // Get accurate distance and duration from API
          routeDistance = data['routes'][0]['legs'][0]['distance']['value'] / 1000; // km
          routeDuration = data['routes'][0]['legs'][0]['duration']['value'] ~/ 60; // minutes

          print('✅ Route loaded: ${routeCoordinates.length} points, ${routeDistance.toStringAsFixed(1)}km, ${routeDuration}min');
          
          _updateMarkersWithRoute();
          _fitBoundsToRoute();
        } else if (data['status'] == 'REQUEST_DENIED') {
          print('❌ API Error: ${data['error_message']}');
          _showApiError();
          _fallbackToStraightLine(origin, destination);
        } else {
          print('⚠️ API returned status: ${data['status']}');
          _fallbackToStraightLine(origin, destination);
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        _fallbackToStraightLine(origin, destination);
      }
    } catch (e) {
      print('❌ Error fetching directions: $e');
      _fallbackToStraightLine(origin, destination);
    }
  }

  /// Fallback to straight line if API fails
  void _fallbackToStraightLine(LatLng origin, LatLng destination) {
    routeCoordinates = [origin, destination];
    routeDistance = paymentController.calculateDistance(origin, destination);
    routeDuration = (routeDistance * 5).ceil();
    _updateMarkersWithRoute();
  }

  /// Show API error message
  void _showApiError() {
    Get.snackbar(
      'API Configuration',
      'Please enable Directions API in Google Cloud Console',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      icon: Icon(Icons.warning, color: Colors.white),
    );
  }

  /// Update markers with route polyline
  void _updateMarkersWithRoute() {
    Set<Marker> newMarkers = {
      // User location
      Marker(
        markerId: MarkerId("selected"),
        position: selectedPoint,
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: "Your Location"),
        onDragEnd: (newPosition) {
          _updateLocation(newPosition);
        },
      ),
    };

    // Add shop markers
    for (var shop in paymentController.shops) {
      bool isNearest = shop == nearestShop;
      newMarkers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: shop.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isNearest ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: isNearest ? '⭐ Nearest Shop' : shop.type,
          ),
          onTap: () => _showShopDetails(shop),
        ),
      );
    }

    // Create professional route polyline
    if (nearestShop != null && routeCoordinates.length >= 2) {
      polylines = {
        // White border (outer line)
        Polyline(
          polylineId: PolylineId("route_border"),
          points: routeCoordinates,
          color: Colors.white,
          width: 8,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
        // Blue route (inner line)
        Polyline(
          polylineId: PolylineId("route"),
          points: routeCoordinates,
          color: Color(0xFF4285F4), // Google Maps blue
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          patterns: routeCoordinates.length == 2 
            ? [PatternItem.dash(10), PatternItem.gap(5)] // Dashed for straight line
            : [], // Solid for real route
        ),
      };
    }

    setState(() {
      markers = newMarkers;
    });
  }

  /// Fit camera to show entire route
  void _fitBoundsToRoute() {
    if (routeCoordinates.length < 2) return;

    LatLngBounds bounds = _createBounds(routeCoordinates);
    Future.delayed(Duration(milliseconds: 300), () {
      try {
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80),
        );
      } catch (e) {
        print('Error fitting bounds: $e');
      }
    });
  }

  /// Create bounds from coordinates
  LatLngBounds _createBounds(List<LatLng> positions) {
    double south = positions.first.latitude;
    double west = positions.first.longitude;
    double north = positions.first.latitude;
    double east = positions.first.longitude;

    for (LatLng pos in positions) {
      if (pos.latitude < south) south = pos.latitude;
      if (pos.longitude < west) west = pos.longitude;
      if (pos.latitude > north) north = pos.latitude;
      if (pos.longitude > east) east = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  /// Update basic markers without route
  void _updateMarkers() {
    Set<Marker> newMarkers = {
      Marker(
        markerId: MarkerId("selected"),
        position: selectedPoint,
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "Your Location"),
        onDragEnd: (newPosition) {
          _updateLocation(newPosition);
        },
      ),
    };

    // Add shop markers
    for (var shop in paymentController.shops) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: shop.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: shop.type,
          ),
          onTap: () => _showShopDetails(shop),
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

  /// Find nearby shops sorted by distance
  void _findNearbyShops(LatLng userLocation) {
    nearbyShops = paymentController.getShopsWithDistance(userLocation);
    if (nearbyShops.isNotEmpty) {
      nearestShop = nearbyShops.first['shop'];
      paymentController.distanceToShop.value = nearbyShops.first['distance'];
    }
  }

  /// Show shop details bottom sheet
  void _showShopDetails(Shop shop) {
    double distance;
    int deliveryTime;
    
    if (shop == nearestShop && routeDistance > 0) {
      distance = routeDistance;
      deliveryTime = routeDuration;
    } else {
      distance = paymentController.calculateDistance(selectedPoint, shop.location);
      deliveryTime = (distance * 5).ceil();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(shop.image, style: TextStyle(fontSize: 32)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('${shop.rating}'),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              shop.type,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shop.address,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.route, color: Colors.blue[700]),
                        SizedBox(height: 4),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'Distance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.schedule, color: Colors.green[700]),
                        SizedBox(height: 4),
                        Text(
                          '$deliveryTime min',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Est. Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingCurrentLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        LatLng currentLocation = LatLng(position.latitude, position.longitude);

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 15),
        );
        await _updateLocation(currentLocation);
      } else {
        Get.snackbar(
          "Permission Denied",
          "Please enable location permission",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not get current location",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoadingCurrentLocation = false);
    }
  }

  /// Search location
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => isLoading = true);

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPoint = LatLng(location.latitude, location.longitude);

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(newPoint, 15),
        );
        await _updateLocation(newPoint);
      }
    } catch (e) {
      Get.snackbar(
        "Not Found",
        "Could not find the location",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Get address from coordinates
  Future<void> _getAddress(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          point.latitude, point.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          address = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(", ");

          if (address.isEmpty) {
            address = "Location: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
          }
        });
      }
    } catch (e) {
      setState(() {
        address = "Address not available";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location",
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(showNearbyShops ? Icons.map : Icons.list),
            onPressed: () {
              setState(() => showNearbyShops = !showNearbyShops);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: selectedPoint,
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            onTap: (position) {
              _updateLocation(position);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            mapType: MapType.normal,
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.15),
                  )
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => setState(() {}),
                onSubmitted: _searchLocation,
              ),
            ),
          ),

          // Nearby Shops List
          if (showNearbyShops && nearbyShops.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                constraints: BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.15),
                    )
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8),
                  itemCount: nearbyShops.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    Shop shop = nearbyShops[index]['shop'];
                    double distance = nearbyShops[index]['distance'];
                    int time = (distance * 5).ceil();
                    bool isNearest = index == 0;

                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isNearest ? Colors.green[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(shop.image, style: TextStyle(fontSize: 24)),
                      ),
                      title: Row(
                        children: [
                          Text(shop.name,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          if (isNearest) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NEAREST',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text('${distance.toStringAsFixed(1)} km • $time min'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(shop.location, 15),
                        );
                        _showShopDetails(shop);
                      },
                    );
                  },
                ),
              ),
            ),

          // Route Loading Indicator
          if (isLoadingRoute)
            Positioned(
              top: showNearbyShops && nearbyShops.isNotEmpty ? 400 : 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Finding best route...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Current Location Button
          Positioned(
            right: 16,
            bottom: 180,
            child: FloatingActionButton(
              heroTag: "current_location",
              onPressed: isLoadingCurrentLocation ? null : _getCurrentLocation,
              backgroundColor: Colors.white,
              elevation: 4,
              child: isLoadingCurrentLocation
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.my_location, color: Colors.blue[700]),
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 16,
            bottom: 260,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(Icons.add, color: Colors.blue[700]),
                ),
                SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(Icons.remove, color: Colors.blue[700]),
                ),
              ],
            ),
          ),

          // Address Display Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, -4),
                    color: Colors.black.withOpacity(0.1),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on,
                            color: Colors.blue[700], size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Location",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              address,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (nearestShop != null) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Text(nearestShop!.image, style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nearest: ${nearestShop!.name}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (routeCoordinates.length > 2)
                                  Text(
                                    'Via street route',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                routeDistance > 0
                                    ? '${routeDistance.toStringAsFixed(1)} km'
                                    : '${paymentController.distanceToShop.value.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              if (routeDuration > 0)
                                Text(
                                  '$routeDuration min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close),
                          label: Text("Cancel"),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back(result: {
                              "lat": selectedPoint.latitude,
                              "lng": selectedPoint.longitude,
                              "address": address,
                              "shop": nearestShop,
                              "distance": routeDistance > 0 
                                  ? routeDistance 
                                  : paymentController.distanceToShop.value,
                              "duration": routeDuration,
                            });
                          },
                          icon: Icon(Icons.check),
                          label: Text("Confirm Location"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Searching location...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}