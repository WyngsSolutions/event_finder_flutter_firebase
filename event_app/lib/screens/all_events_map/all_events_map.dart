import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/screens/event_detail/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class AllEventLocations extends StatefulWidget {
  
  final List allEvents;
  const AllEventLocations({ Key? key, required this.allEvents }) : super(key: key);

  @override
  State<AllEventLocations> createState() => _AllEventLocationsState();
}

class _AllEventLocationsState extends State<AllEventLocations> {
  
  final Set<Marker> markers = Set();
  final Completer<GoogleMapController> _controller = Completer();
  late CameraPosition defaultPos;
  late double unitHeightValue;
  late LatLng markerPos;
  Map selectedEvent = {};

  @override
  void initState() {
    super.initState();
    defaultPos = CameraPosition(
      target: LatLng(widget.allEvents[0]['latitude'], widget.allEvents[0]['longitude']),
      zoom: 15,
    );
     markerPos = LatLng(widget.allEvents[0]['latitude'], widget.allEvents[0]['longitude']);
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    for(int i=0; i < widget.allEvents.length; i++)
    {
      final marker = Marker(
        markerId: MarkerId(widget.allEvents[i]['eventId']),
        position: LatLng(widget.allEvents[i]['latitude'], widget.allEvents[i]['longitude']),
        infoWindow: InfoWindow(
          title: widget.allEvents[i]['eventTitle'],
          snippet: widget.allEvents[i]['eventAddress'],
        ),
        consumeTapEvents: true,
        onTap: (){
          setState(() {
            selectedEvent = widget.allEvents[i]; 
            showDetailView();           
          });
        }
      );
      markers.add(marker);
    }
    setState(() { });
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
            onMapCreated: onMapCreated,
            markers: markers,
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

  void showDetailView()async
  {
    double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, selectedEvent['latitude'], selectedEvent['longitude']);
    String distanceInKm = (distanceInMeters/1000).toStringAsFixed(1);
    
    dynamic result = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*7, vertical: SizeConfig.blockSizeVertical*3),
          height: SizeConfig.blockSizeVertical*42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40)
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                selectedEvent['eventTitle'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.fontSize * 2.7,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),

              Center(
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
                  width: SizeConfig.blockSizeVertical*15,
                  height: SizeConfig.blockSizeVertical*15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(selectedEvent['eventImageUrl']),
                      fit: BoxFit.cover
                    )
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
                child: Text(
                  '${selectedEvent['eventAddress']},',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 1.8,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[400],),
                    SizedBox(width: 10,),
                    Text(
                      '$distanceInKm km away',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.7,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.back();
                        Get.to(EventDetailScreen(eventDetail: selectedEvent));
                      },
                      child: Container(
                        height: SizeConfig.blockSizeVertical*4.5,
                        width: SizeConfig.blockSizeHorizontal*30,
                        decoration: BoxDecoration(
                          color: Constants.appThemeColor,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Center(
                          child: Text(
                          'View detail',
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.7,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              
            ],
          ),
        );
      }
    );
  }
}