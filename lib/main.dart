import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chool Check',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  LatLng _currentPosition = const LatLng(37.4979, 127.0276);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
      return;
    }

    try {
      // Geolocator를 사용하여 현재 위치를 가져옵니다.
      Position position = await Geolocator.getCurrentPosition(
        // 위치 설정을 구성합니다. 여기서는 높은 정확도를 요청합니다.
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      // 상태를 업데이트합니다.
      setState(() {
        // 현재 위치를 LatLng 객체로 변환하여 저장합니다.
        _currentPosition = LatLng(position.latitude, position.longitude);
        // 지도 컨트롤러를 사용하여 카메라를 새로운 위치로 애니메이션합니다.
        mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
      });
    } catch (e) {
      print('현재 위치를 가져오는 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 18.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentPosition,
          ),
        },
        circles: {
          Circle(
            circleId: const CircleId('currentLocationCircle'),
            center: _currentPosition,
            radius: 100,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        },
      ),
    );
  }
}
