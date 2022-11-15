// ignore_for_file: curly_braces_in_flow_control_structures, avoid_unnecessary_containers, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'package:event_app/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class LocationPermissonScreen extends StatefulWidget {
  @override
  _LocationPermissonScreenState createState() => _LocationPermissonScreenState();
}

class _LocationPermissonScreenState extends State<LocationPermissonScreen> {

  bool showLoading = true;
  //******* LOCATION *******\\
  Location location = Location();
  late bool serviceEnabled;
  late PermissionStatus permissionGranted;
  late LocationData locationData;
  bool isPermissionGiven = false;
  bool isGPSOpen = false;
  Timer? timer;
  
  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid)
      switchOnLocationAndroid();
    else
      switchOnLocationIOS();
  }

  @override
  void dispose() {
    if(timer != null)
      timer!.cancel();
    super.dispose();
  }

  //****************************** LOCATION RELATED ********************************/
  void switchOnLocationAndroid()async{
    //Permission Check
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      
      if (permissionGranted == PermissionStatus.deniedForever) {
        showAlertDialog('Location Disabled', 'You have disabled location use for the app so please go to application settings and allow location use to continue');
        setState(() {
          showLoading = false;
        });
        return;
      }
      if (permissionGranted == PermissionStatus.denied) {
        setState(() {
          showLoading = false;
        });
        return;
      }
      if (permissionGranted != PermissionStatus.granted) {
         setState(() {
          showLoading = true;
        });
        return;
      }
    }

    if (permissionGranted == PermissionStatus.granted)
      isPermissionGiven = true;
    

    //Service Check
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled)
    {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        startTimer();
        setState(() {
          showLoading = false;
        });
        return;
      }
      else
      {
        isGPSOpen = true;
        setState(() {
          showLoading = true;
        });
      }
    }
    else
    {
      isGPSOpen = true;
    }


    if(isGPSOpen && isPermissionGiven)
    {
      if(timer != null)
        timer!.cancel();
  
      locationData = await location.getLocation();
      print(locationData.latitude);
      print(locationData.longitude);
      setUpUserLocation(locationData.latitude!, locationData.longitude!);
    }

    setState(() { });
  }

  void switchOnLocationIOS()async{
    //Permission Check
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      
      if (permissionGranted == PermissionStatus.deniedForever) {
        showAlertDialog('Location Disabled', 'You have disabled location use for the app so please go to application settings and allow location use to continue');
        setState(() {
          showLoading = false;
        });
        return;
      }
      if (permissionGranted == PermissionStatus.denied) {
        setState(() {
          showLoading = false;
        });
        return;
      }
      if (permissionGranted != PermissionStatus.granted) {
         setState(() {
          showLoading = true;
        });
        return;
      }
    }

    if (permissionGranted == PermissionStatus.granted)
      isPermissionGiven = true;
    

    isGPSOpen = true;

    if(isGPSOpen && isPermissionGiven)
    {
      if(timer != null)
        timer!.cancel();
  
      locationData = await location.getLocation();
      print(locationData.latitude);
      print(locationData.longitude);
      setUpUserLocation(locationData.latitude!, locationData.longitude!);
    }

    setState(() { });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          checkForGPS();
        },
      ),
    );  
  }

  void checkForGPS()async{
     serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled)
    {
      isGPSOpen = true;
      switchOnLocationAndroid();
    }
  }

  Future<void> notNowSelected() async {
    LatLng result  = await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) => 
      MapViewScreen()));

    //Returned wth lat lon    
    if(result != null)
    {
      setState(() {
        showLoading = true;
      });
    }
    setUpUserLocation(result.latitude, result.longitude);
  }

  Future<void> setUpUserLocation(double latitude , double longitude) async {
    //Save lat lon and move to home From coordinates
    Constants.latitude  = latitude;
    Constants.longitude  = longitude;
    // late GeoData data;
    // try{
    //   data = await Geocoder2.getDataFromCoordinates(latitude: latitude, longitude: longitude, googleMapApiKey: "AIzaSyCDJrAl-UkLdqgVIbw7weRpmID_uzXhIp4");
    //   Constants.areaName = data.address;
    // }
    // catch(e){
    //   Constants.areaName = "Unknown Road";
    // }
    Constants.areaName = "Unknown Road";
    Get.offAll(HomeScreen());
  }
  
  //****************************** UTIL ********************************\\
  void showAlertDialog(String title , String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child : Scaffold(
        backgroundColor: Colors.white,
        body: (showLoading) ? Container(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Constants.appThemeColor)
            ),
          ),
        ) : Container(
          child: Column(
            children: [
              Container(
                height: SizeConfig.blockSizeVertical *80,
                width: SizeConfig.blockSizeHorizontal *100,
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Location Disabled", style: TextStyle(fontSize: 2.2 * unitHeightValue, color: Colors.black, fontWeight: FontWeight.bold),),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical *5,
                    ),
                    Text(
                      "Events app works better when we\ncan detect your location", 
                      style: TextStyle(fontSize: 2 * unitHeightValue, color: Colors.black54, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical *5,
                    ),
                    Icon(Icons.location_on, size: SizeConfig.blockSizeVertical *20, color: Constants.appThemeColor,)
                  ],
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical *17,
                width: SizeConfig.blockSizeHorizontal *100,
                margin: EdgeInsets.symmetric(horizontal: 20),
               // color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: (){
                        if(Platform.isAndroid)
                          switchOnLocationAndroid();
                        else
                          switchOnLocationIOS();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Constants.appThemeColor,
                          borderRadius: new BorderRadius.circular(30.0)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text("ENABLE", style: TextStyle(fontSize: 1.8 * unitHeightValue, color: Colors.white),),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: notNowSelected,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            width: 1.0,
                            color: Colors.blue,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text("NOT NOW", style: TextStyle(fontSize: 1.8 * unitHeightValue, color: Constants.appThemeColor),),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MapViewScreen extends StatefulWidget{
  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition defaultPos = CameraPosition(
    target: LatLng(31.5106, 74.3445),
    zoom: 15,
  );
  late double unitHeightValue;
  LatLng markerPos  = const LatLng(31.5106, 74.3445);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      showInSnackBar('Press and hold the marker to set it to your location');
    });

  }
  
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Constants.appThemeColor,
        content: new Text(value, style: TextStyle(color : Colors.white, fontSize: 1.8 * unitHeightValue),)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    unitHeightValue = MediaQuery.of(context).size.height * 0.01;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Stack(
          children: [
        
            GoogleMap(
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              initialCameraPosition: defaultPos,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: <Marker>{
                  Marker(
                    position: LatLng(31.5106, 74.3445),
                    draggable: true,
                    markerId: MarkerId("1"),
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: const InfoWindow(
                      title: 'My Location',
                    ),
                    onDragEnd: (val){
                      print(val.latitude);
                      print(val.longitude);
                      markerPos = val;
                    }
                  )
                },
            ),
            
            Container(
              margin: EdgeInsets.all(20),
              //color: Colors.red,
              child: IconButton(
                icon: Icon(Icons.arrow_back_outlined, 
                color: Constants.appThemeColor,size: 30,),
                onPressed: (){
                  Navigator.pop(context, null);
                }
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context, markerPos);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Constants.appThemeColor,
                        borderRadius: new BorderRadius.circular(30.0)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("SET LOCATION FROM MAP", style: TextStyle(fontSize: 1.8 * unitHeightValue, color: Colors.white),),
                      ),
                    ),
                  )
                ],
              ),
            )

         ],
        ),
      ),
    );
  }
}