import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({Key? key}) : super(key: key);

  @override
  _GoogleMapsWidgetState createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  late GoogleMapController mapController;

  final LatLng _startingPoint = const LatLng(37.4645862, 126.6803935);

  LatLng? _currentPosition;
  String? _currentAddress;
  String? _distanceToLocation;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addtMarker(
        _startingPoint, "출발지", "RedMarker", BitmapDescriptor.defaultMarker);
    _getCurrentLocation();
  }

  // 출발지 마커
  void _addtMarker(
      LatLng Point, String infoText, String markerName, BitmapDescriptor icon) {
    _markers.add(Marker(
      markerId: MarkerId(markerName),
      position: Point,
      icon: icon,
      infoWindow: InfoWindow(title: infoText),
    ));
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showLocationPermissionSnackBar();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _addtMarker(_currentPosition!, "내 위치", "BlueMarker",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));
      _getAddressFromLatLng();

      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _startingPoint.latitude,
        _startingPoint.longitude,
      );

      _distanceToLocation = (distanceInMeters / 1000).toStringAsFixed(2);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 2,
          child: GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _startingPoint,
              zoom: 16.0,
            ),
            markers: _markers,
          ),
        ),

        //---------------지도 end ---------------------
        _currentAddress != null ? _currentAddress!.text.make() : SizedBox(),
        _distanceToLocation != null
            ? "출발지와의 거리: $_distanceToLocation km".text.make()
            : SizedBox(),
        "현재인원 2/4명".text.make(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          onPressed: () => _moveCameraTo(_currentPosition!),
          child: Text('내 위치로 이동'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => _moveCameraTo(_startingPoint),
          child: Text('출발지로 이동'),
        ),
      ],
    );
  }

  void _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "출발지 주소: ${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  void _showLocationPermissionSnackBar() {
    SnackBar snackBar = SnackBar(
      content: Text("위치 권한이 필요한 서비스입니다."),
      action: SnackBarAction(
        label: "설정으로 이동",
        onPressed: () {
          AppSettings.openAppSettings();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _moveCameraTo(LatLng target) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16.0),
    ));
  }
}
