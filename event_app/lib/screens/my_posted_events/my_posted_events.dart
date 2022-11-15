// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/screens/edit_event/edit_event.dart';
import 'package:event_app/screens/event_detail/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../services/ads_controllder.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class MyPostedEvents extends StatefulWidget {
  const MyPostedEvents({ Key? key }) : super(key: key);

  @override
  State<MyPostedEvents> createState() => _MyPostedEventsState();
}

class _MyPostedEventsState extends State<MyPostedEvents> {
 
  List allEvents = [];

  @override
  void initState() {
    super.initState();
    getMyPostedEvents();
    AdsController().showInterstitialAd();
  }

  void getMyPostedEvents()async{
    allEvents.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getMyPostedEvents(allEvents);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(allEvents.length);
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void deleteEvent(Map event, int index)async{
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().deleteEvent(event);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       allEvents.removeAt(index);
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                'My Events',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*3.5,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            Expanded(
              child: (allEvents.isEmpty) ? Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Center(
                  child: Text(
                    'No Event Posted',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                      color: Colors.grey[400]!
                    ),
                  ),
                ),
              ): Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: allEvents.length,
                    itemBuilder: (_, i) {
                      return eventCell(allEvents[i], i);
                    },
                    shrinkWrap: true,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget eventCell(dynamic eventDetail, int index){
    String eventImage = eventDetail['eventImageUrl'];
    double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, eventDetail['latitude'], eventDetail['longitude']);
    double distanceInKm = distanceInMeters/1000;

    return GestureDetector(
      onTap: (){
        Get.to(EventDetailScreen(eventDetail: eventDetail));
      },
      child: Column(
        children: [
          
          Container(
            height: SizeConfig.blockSizeVertical * 32,
            margin: EdgeInsets.only(top: (index==0) ? 0 : SizeConfig.blockSizeVertical * 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
              image: DecorationImage(
                image: CachedNetworkImageProvider(eventImage),
                fit: BoxFit.cover
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, right: SizeConfig.blockSizeVertical*1),
                    padding: EdgeInsets.fromLTRB(15, 3, 15, 5),
                    height: SizeConfig.blockSizeVertical*3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Constants.appThemeColor
                    ),
                    child: Text(
                      (eventDetail['eventPrice'] == "0") ? 'Free' : 'Entry : Rs ${eventDetail['eventPrice']}',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.7,
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: SizeConfig.blockSizeVertical*8,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: SizeConfig.blockSizeVertical * 5.5,
                        width: SizeConfig.blockSizeVertical * 5.5,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(eventDetail['userImage']),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                eventDetail['eventTitle'],
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 2,),
                              Text(
                                'Posted by ${eventDetail['userName']}',
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.4,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*1.7),
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color : Colors.white, size: SizeConfig.blockSizeVertical*2.5,),
                            Container(
                              margin: const EdgeInsets.only(left: 2),
                              child: Text(
                                '${distanceInKm.toStringAsFixed(1)}km',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  dynamic result = await Get.to(EditEvent(eventDetails: eventDetail,));
                  if(result != null)
                    getMyPostedEvents();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: SizeConfig.blockSizeVertical*6.5,
                  width: SizeConfig.blockSizeHorizontal*43,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: Text(
                      'Edit Event',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  deleteEvent(eventDetail, index);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: SizeConfig.blockSizeVertical*6.5,
                  width: SizeConfig.blockSizeHorizontal*43,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: Text(
                      'Delete Event',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ]
      )
    );
  }
}