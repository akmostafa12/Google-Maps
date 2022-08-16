import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GMaps(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GMaps extends StatefulWidget {
  const GMaps({Key? key}) : super(key: key);


  @override
  State<GMaps> createState() => _GMapsState();
}

class _GMapsState extends State<GMaps> {
  Future<Position> getPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
  Future<void> getCurrentLocation()async{
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl!.latitude;
    long = cl!.longitude;
    _kGooglePlex = CameraPosition(
        target: LatLng(lat!, long!),
        zoom: 12.4746);
    origin = Marker(markerId: const MarkerId('Origin'),
        draggable: true,
        infoWindow:const InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: LatLng(lat!, long!),);
    setState(() {

    }
    );
  }

  GoogleMapController ? gmc;
  CameraPosition ? _kGooglePlex;
  MapType  _mapType = MapType.normal;
  bool isType = true;
  Position ? cl;
  double ? lat;
  double ? long;
  Marker ? origin;
  Marker ? destination;

  final la = TextEditingController();
  final lo = TextEditingController();
  @override
  void initState() {
    getPermission();
    getCurrentLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خرائط جوجل'),
        elevation: 0,
        backgroundColor: Colors.green,
        actions: [
          TextButton(onPressed: (){
            gmc!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: origin!.position,tilt: 50,zoom:14.5)));
          }, child: const Text('Origin',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20),)),
          if(destination!=null)
          TextButton(onPressed: (){
            gmc!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: destination!.position,tilt: 50,zoom:14.5)));
          }, child: const Text('Destination',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 20),)),
          TextButton(onPressed: (){
            setState(() {

            });
            if(isType){
              _mapType = MapType.normal;
              isType = false;
            }
            else{
              _mapType = MapType.hybrid;
              isType = true;

            }
          },child: const Text('Map Mode',style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold,fontSize: 20),),)


        ],
      ),
      body: Column(
          children: [
            _kGooglePlex == null ?  const Padding(
              padding: EdgeInsets.only(top: 500),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ) : Expanded(
              child:GoogleMap(
                onLongPress: (LatLng pos){
                  if(destination == null){
                    setState(() {

                    });
                    destination = Marker(markerId: const MarkerId('Destination'),
                        draggable: true,
                        infoWindow:const InfoWindow(title: 'Destination'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      position: pos
                    );

                  }
                },
                markers: {
                  if(origin != null) origin!,
                  if (destination != null) destination!

                },
                mapType: _mapType, initialCameraPosition: _kGooglePlex!,onMapCreated: (GoogleMapController controller) {
                gmc = controller;
              },
              ),

            ),
          ],
      ),
    );
  }
}


