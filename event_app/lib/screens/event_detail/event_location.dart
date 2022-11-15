// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/size_config.dart';

class EventLocation extends StatefulWidget {
  
  final Map eventDetail;

  const EventLocation({ Key? key, required this.eventDetail }) : super(key: key);

  @override
  State<EventLocation> createState() => _EventLocationState();
}

class _EventLocationState extends State<EventLocation> {

  final Completer<GoogleMapController> _controller = Completer();
  late CameraPosition defaultPos;
  late double unitHeightValue;
  late LatLng markerPos;

  @override
  void initState() {
    super.initState();
    defaultPos = CameraPosition(
      target: LatLng(widget.eventDetail['latitude'], widget.eventDetail['longitude']),
      zoom: 15,
    );
     markerPos = LatLng(widget.eventDetail['latitude'], widget.eventDetail['longitude']);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
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
                position: LatLng(widget.eventDetail['latitude'], widget.eventDetail['longitude']),
                draggable: true,
                markerId: const MarkerId("1"),
                icon: BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: 'Event Location',
                  snippet: widget.eventDetail['eventAddress'],
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
            height: SizeConfig.blockSizeVertical* 15,
            padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 6, right: SizeConfig.blockSizeHorizontal * 6, top: SizeConfig.blockSizeVertical * 6),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/top_bg.png'),
                fit: BoxFit.fill
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: (){
                       Get.back(); 
                      },
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                    ),
                  ],
                )
              ],
            ),
          ),

          
       ],
      ),
    );
  }
}