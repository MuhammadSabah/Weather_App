import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:weather_app/Screens/location_error_screen.dart';
import 'package:weather_app/Services/get_weather.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final _locationDuration = const Duration(seconds: 1);
  final _locationTransition = Transition.native;
  final _transition = Transition.leftToRight;
  final _duration = const Duration(milliseconds: 300);
  final WeatherModel _weatherModel = WeatherModel();

  Future<dynamic> getLocationData() async {
    var weatherData = await _weatherModel.getLocationAndWeatherData();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (weatherData != null && serviceEnabled) {
      Get.to(
        () => HomeScreen(weatherDataJson: weatherData),
        transition: _transition,
        duration: _duration,
      );
    } else if (!serviceEnabled) {
      Get.to(() => const LocationError());
    }
  }

  // Request Permission from the user.
  Future<dynamic> permissionRequest() async {
    await Geolocator.requestPermission();
    var permissionStatus = await permissionCheck();
    if (permissionStatus) {
      getLocationData();
    } else {
      showDenialDialog();
    }
  }

  // //Check the permission status
  Future<bool> permissionCheck() async {
    var permissionResult = await Geolocator.checkPermission();
    if (permissionResult == LocationPermission.always ||
        permissionResult == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  void showDenialDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Location is disabled!, if you want to enable it click on the button below and re open the app.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Enable",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                permissionRequest();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    permissionRequest();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
