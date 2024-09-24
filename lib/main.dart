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
      title: '오늘도 출근',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '오늘도 출근'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
      });
    } catch (e) {
      print('현재 위치를 가져오는 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 17.0,
            ),
            mapType: MapType.normal,
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: _currentPosition,
              ),
            },
            zoomControlsEnabled: false,
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _checkIn(context);
        },
        label: const Text('출근하기'),
        icon: const Icon(Icons.work),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _checkIn(BuildContext context) async {
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      Position currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      LatLng companyLocation = const LatLng(37.4979, 127.0276);

      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        companyLocation.latitude,
        companyLocation.longitude,
      );

      if (distanceInMeters >= 100) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('출근 완료'),
                content: const Text('출근이 완료되었습니다!'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('출근 실패'),
                content: const Text('회사 근처에서만 출근할 수 있습니다.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('오류'),
              content: Text('출근 처리 중 오류 발생: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
