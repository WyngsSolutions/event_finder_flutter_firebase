// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, curly_braces_in_flow_control_structures, unused_local_variable, avoid_print
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/screens/add_event/add_event.dart';
import 'package:event_app/screens/chatlist_screen/chatlist_screen.dart';
import 'package:event_app/screens/event_calender_view/event_calender_view.dart';
import 'package:event_app/screens/event_detail/event_detail.dart';
import 'package:event_app/screens/search_screen/search_screen.dart';
import 'package:event_app/screens/signup_screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/app_user.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../all_events_map/all_events_map.dart';
import '../edit_profile/edit_profile.dart';
import '../joined_events/joined_events.dart';
import '../my_posted_events/my_posted_events.dart';
import '../pro_user_screen/pro_user_screen.dart';

class HomeScreen extends StatefulWidget {
 
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final GlobalKey<ScaffoldState> key = GlobalKey(); // Create a key.
  String selectedCat = "";
  List allEvents = [];
  List featuredEvents = [];
  List filteredEvents = [];
  //*******ONE SIGNAL*******\\
  String _debugLabelString = "";
  final _requireConsent = false;// CHANGE THIS parameter to true if you want to test GDPR privacy consent
  String userId = "";
  //AD
  late BannerAd bannerAd;
  bool bannerAdIsLoaded = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getAllEvents();
    //loadBannerAd();
  }

  void loadBannerAd(){
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            bannerAdIsLoaded = true;            
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
      request: AdRequest())
    ..load();
  }
  
  ///******* INITIAL METHOD ****************///  
  Future<void> initPlatformState() async {
    if (!mounted) return;

    //EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);
    if(Platform.isIOS)
    {
      await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    }
    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print(changes.to.status);
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
        print('FOREGROUND HANDLER CALLED WITH: $event');
        /// Display Notification, send null to not display
        event.complete(null);
        setState(() {
          _debugLabelString = "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
          //NotificationHandler.checkRecievedNotification(event.notification, context);
        });
        Get.snackbar(
          "New Message", 
          event.notification.body!,
          duration: Duration(seconds: 3),
          animationDuration: Duration(milliseconds: 800),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Constants.appThemeColor,
          colorText: Colors.white
        );
    });  

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      //this.setState(() {
      //  _debugLabelString ="Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      //});
      //print(_debugLabelString);
      //print(result.notification.payload.additionalData['orderId']);  
      //NotificationHandler.checkNotificationFromTopBarOrAppClose(result.notification, context);
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
      //print("SUBSCRIPTION STATE CHANGED: ${changes.to.subscribed} -----  ${changes.to.pushToken} ----- ${changes.to.userId}");
      if(changes.to.userId!.isNotEmpty) {
        userId = changes.to.userId!;
        //EasyLoading.dismiss(); // show hud
        registerOneSignalUserID();
      }
    });

    await OneSignal.shared.setAppId(Constants.oneSignalId);
    var status = await OneSignal.shared.getDeviceState();
    if(status!.subscribed){
      userId = status.userId!;
      registerOneSignalUserID();
    }
  }

  void registerOneSignalUserID()async{
    //EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    AppController().updateOneSignalUserID(userId);
    //EasyLoading.dismiss();   
  }


  void getAllEvents()async{
    allEvents.clear();
    featuredEvents.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getAllEvents(allEvents, featuredEvents);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(allEvents.length);
       filteredEvents = List.from(allEvents);
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
      key: key,
      drawer: (!AppUser.isGuestUser()) ? homeDrawer() : null,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
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
                        (!AppUser.isGuestUser()) ?
                        IconButton(
                          onPressed: (){
                            key.currentState!.openDrawer();  
                          },
                          icon: Icon(Icons.menu, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                        ) : Container(),
                        Row(
                          children: [
                            IconButton(
                              onPressed: (){
                                Get.to(EventCalenderView(allEvents: allEvents,));
                              },
                              icon: Icon(Icons.calendar_month, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                            ),
                            IconButton(
                              onPressed: (){
                                Get.to(AllEventLocations(allEvents: allEvents,));
                              },
                              icon: Icon(Icons.share_location_sharp, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              
               Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Text(
                  'Featured Events',
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize*2.7,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
      
              Container(
                height: SizeConfig.blockSizeVertical*25,
                width: SizeConfig.blockSizeHorizontal*80,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4, bottom: SizeConfig.blockSizeVertical*1.5),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: featuredEvents.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      return featureCell(featuredEvents[i], i);
                    },
                    shrinkWrap: true,
                  ),
                ),
              ),
      
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Events',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize*2.7,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        dynamic result = await Get.to(SearchScreen(allEvents: allEvents,));
                        if(result != null)
                        {
                          setState(() {
                            filteredEvents = List.from(result);                          
                          });
                        }
                      },
                      icon: Icon(Icons.search, color: Constants.appThemeColor, size: SizeConfig.blockSizeVertical * 3,),
                    )
                  ],
                )
              ),
      
              // Container(
              //   height: SizeConfig.blockSizeVertical*6.5,
              //   margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(
              //       width: 1,
              //       color: Constants.appThemeColor
              //     )
              //   ),
              //   child: Center(
              //     child: TextField(
              //       obscureText: true,
              //       textAlignVertical: TextAlignVertical.center,
              //       style: TextStyle(fontSize: SizeConfig.fontSize*2),
              //       decoration: InputDecoration(
              //         hintText: 'Search',
              //         hintStyle: TextStyle(fontSize: SizeConfig.fontSize*2),
              //         border: InputBorder.none,
              //         prefixIcon: Icon(Icons.search)
              //       ),
              //     ),
              //   ),
              // ),
      
              // Container(
              //   height: SizeConfig.blockSizeVertical * 4.5,
              //   margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              //   child:  ListView.builder(
              //     itemCount: Constants.categories.length,
              //     scrollDirection: Axis.horizontal,
              //     itemBuilder: (_, i) {
              //       return categoryCell(Constants.categories[i], i);
              //     },
              //     shrinkWrap: true,
              //   ),
              // ),
      
            (filteredEvents.isEmpty) ? Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*10, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Center(
                  child: Text(
                    'No Events Found',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                      color: Colors.grey[400]!
                    ),
                  ),
                ),
              ): Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4, bottom: SizeConfig.blockSizeVertical*2),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (_, i) {
                      return eventCell(filteredEvents[i], i);
                    },
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
              ),
      
            ],
          ),
        ),
      ),
      floatingActionButton: (!AppUser.isGuestUser()) ? FloatingActionButton(
        elevation: 0.0,
        child: const Icon(Icons.add),
        backgroundColor: Constants.appThemeColor,
        onPressed: () async {
          dynamic result = await Get.to(const AddEvents());
          if(result != null)
            getAllEvents();
        }
      ) : Container(),
      // bottomNavigationBar: Container(
      //   height: (!bannerAdIsLoaded) ? 0 : bannerAd.size.height.toDouble(),
      //   width: double.infinity,
      //   child: AdWidget(ad: bannerAd)
      // )
    );
  }

  Widget categoryCell(Map category, int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          selectedCat = category['categoryName'];
          filteredEvents = allEvents.where((element) => element['selectedCategory']['categoryId'] == category['categoryId']).toList();
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: (index==0) ? 0 : SizeConfig.blockSizeHorizontal * 4),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (selectedCat == category['categoryName']) ? Constants.appThemeColor : Colors.white,
          border: Border.all(
            width: 1,
            color: Constants.appThemeColor
          )
        ),
        child: Center(
          child: Text(
            category['categoryName'],
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: SizeConfig.fontSize * 2.0,
              color: (selectedCat != category['categoryName']) ? Constants.appThemeColor : Colors.white,
              fontWeight: FontWeight.w500
            ),
          ),
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
      child: Container(
        height: SizeConfig.blockSizeVertical * 32,
        width: SizeConfig.blockSizeHorizontal*90,
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
            )
          ],
        ),
      ),
    );
  }

  Widget featureCell(dynamic eventDetail, int index){
    String eventImage = eventDetail['eventImageUrl'];
    double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, eventDetail['latitude'], eventDetail['longitude']);
    double distanceInKm = distanceInMeters/1000;

    return GestureDetector(
      onTap: (){
        Get.to(EventDetailScreen(eventDetail: eventDetail));
      },
      child: Container(
        height: SizeConfig.blockSizeVertical * 32,
        width: (featuredEvents.length == 1) ? SizeConfig.blockSizeHorizontal*92 : SizeConfig.blockSizeHorizontal*80,
        margin: EdgeInsets.only(left: (index==0) ? 0 : SizeConfig.blockSizeHorizontal * 6),
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
            )
          ],
        ),
      ),
    );
  }

  Widget homeDrawer(){
    return Container(
      width: SizeConfig.blockSizeHorizontal * 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius:  BorderRadius.only(
          bottomRight:Radius.circular(30),
          topRight:Radius.circular(30),
        ),
        image: DecorationImage(
          image: AssetImage('assets/splash.png'),
          fit: BoxFit.cover
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4, right: SizeConfig.blockSizeHorizontal *4, top: SizeConfig.blockSizeVertical*10),
              height: SizeConfig.blockSizeVertical * 20,
              width: SizeConfig.blockSizeVertical* 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: (Constants.appUser.userProfilePicture.isEmpty) ? AssetImage('assets/placeholder.jpeg') : CachedNetworkImageProvider(Constants.appUser.userProfilePicture) as ImageProvider,
                  fit: BoxFit.cover
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(Constants.appUser.proUser)
                  Container(
                    height: SizeConfig.blockSizeVertical * 5,
                    width: SizeConfig.blockSizeVertical * 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/verified.png'),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
         
          GestureDetector(
            onTap: ()  async {
              await Get.to(MyPostedEvents());
              getAllEvents();
            },
            child: Container(
             // color: Colors.red,
              height: SizeConfig.blockSizeVertical * 7,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
              child: Row(
                children: [
                Container(
                  child: Icon(Icons.event, color: Colors.white, size: SizeConfig.blockSizeVertical * 3.3,)
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4),
                  child: Text(
                    'Posted Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ],
              )
            ),
          ),

          GestureDetector(
            onTap: ()  {
              Get.to(JoinedEvents());
            },
            child: Container(
             // color: Colors.red,
              height: SizeConfig.blockSizeVertical * 7,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
              child: Row(
                children: [
                Container(
                  child: Icon(Icons.event_available, color: Colors.white, size: SizeConfig.blockSizeVertical * 3.3,)
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4),
                  child: Text(
                    'Joined Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ],
              )
            ),
          ),

          GestureDetector(
            onTap: () async {
              Get.to(ChatListScreen());
            },
            child: Container(
              //color: Colors.red,
              height: SizeConfig.blockSizeVertical * 7,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
              child: Row(
                children: [
                Container(
                  child: Icon(Icons.chat, color: Colors.white, size: SizeConfig.blockSizeVertical * 3,)
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4),
                  child: Text(
                    'My Chats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ],
              )
            ),
          ),

          GestureDetector(
            onTap: () async {
              await Get.to(EditProfile());
              setState(() {});
            },
            child: Container(
             // color: Colors.red,
              height: SizeConfig.blockSizeVertical * 7,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
              child: Row(
                children: [
                Container(
                  child: Icon(Icons.edit, color: Colors.white, size: SizeConfig.blockSizeVertical * 3,)
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ],
              )
            ),
          ),

          if(!Constants.appUser.isAdmin && !Constants.appUser.proUser)
          GestureDetector(
            onTap: () async {
              await Get.to(ProUserScreen());
              setState(() {});
            },
            child: Container(
              //color: Colors.red,
              height: SizeConfig.blockSizeVertical * 7,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
              child: Row(
                children: [
                Container(
                  child: Icon(Icons.verified, color: Colors.white, size: SizeConfig.blockSizeVertical * 3,)
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4),
                  child: Text(
                    'Become a Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ],
              )
            ),
          ),


          GestureDetector(
            onTap: () async {
              Share.share('Download EventFinder app and stay upto date with all the latest evemts arounds you\nhttps://itunes.apple.com/app/id1639081876');
            },
            child: Container(
             // color: Colors.red,
              height: SizeConfig.blockSizeVertical * 7,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
              child: Row(
                children: [
                Container(
                  child: Icon(Icons.share, color: Colors.white, size: SizeConfig.blockSizeVertical * 3,)
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4),
                  child: Text(
                    'Share App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ],
              )
            ),
          ),

          
          GestureDetector(
            onTap: () async {
              Constants.appUser = AppUser();
              await AppUser.deleteUserAndOtherPreferences();
              Get.offAll(SignUpScreen());
            },
            child: Container(
              //color: Colors.red,
              height: SizeConfig.blockSizeVertical * 7,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
              child: Row(
                children: [
                Container(
                  child: Icon(Icons.logout, color: Colors.white, size: SizeConfig.blockSizeVertical * 3,)
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *4),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ],
              )
            ),
          ),
          
        ],
      ) ,
    );
  }
}