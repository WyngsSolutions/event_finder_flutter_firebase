// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/models/app_user.dart';
import 'package:event_app/screens/event_detail/event_comments.dart';
import 'package:event_app/screens/host_profile/host_profile.dart';
import 'package:event_app/screens/login_screen/login_screen.dart';
import 'package:event_app/screens/qr_ticket_screen/qr_ticket_screen.dart';
import 'package:event_app/utils/constants.dart';
import 'package:event_app/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/app_controller.dart';
import '../chat_screen/chat_screen.dart';
import 'event_location.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class EventDetailScreen extends StatefulWidget {
  
  final Map eventDetail;
  const EventDetailScreen({ Key? key , required this.eventDetail}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {

  String eventImage = "";
  double distanceInKm = 0;
  late String timeOnly;
  late String dateOnly;
  bool isJoiningAnswer = false;
  bool isUserPostedEvent = false;
  //LIKES
  bool userlikedEvent = false;
  List eventLikedUsersList = [];
  Map likeDetail = {};
  //
  List eventJoinedByUsersList = [];
  AppUser hostDetails = AppUser();

  @override
  void initState() {
    super.initState();
    eventImage = widget.eventDetail['eventImageUrl'];
    double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, widget.eventDetail['latitude'], widget.eventDetail['longitude']);
    distanceInKm = distanceInMeters/1000;
    DateTime taskDate = DateFormat("dd-MM-yyyy HH:mm").parse(widget.eventDetail['eventDate'].toString());
    timeOnly = DateFormat("HH:mm aa").format(taskDate);
    dateOnly = DateFormat("dd MMM, yyyy").format(taskDate);
    //EVENTS
    isUserPostedEvent = (widget.eventDetail['userId'] == Constants.appUser.userId) ?  true : false;
    getAllUsersJoiningEvent();
  }

  void getAllUsersJoiningEvent()async{
    eventJoinedByUsersList.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getEventJoiningUser(eventJoinedByUsersList,widget.eventDetail);
    hostDetails = await AppUser.getUserDetailByUserId(widget.eventDetail['userId']);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(eventJoinedByUsersList.length);
       for(int i=0; i< eventJoinedByUsersList.length; i++)
       {
         if(Constants.appUser.userId == eventJoinedByUsersList[i]['joiningUserId'])
          isJoiningAnswer = true;
       }
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }

    getAllUsersLikesForEvent();
  }

  void joinEvent()async{
    if(AppUser.isGuestUser())
      Get.to(LoginScreen(showBackButton: true,));
    else
    {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
      dynamic result = await AppController().addJoinedEvent(widget.eventDetail);
      EasyLoading.dismiss();
      if(result['Status'] == 'Success')
      {
      setState(() {
        isJoiningAnswer = true;
        getAllUsersJoiningEvent();
      });
      }
      else
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  void addEventToCalender(){
    DateTime taskStartDate = DateFormat("dd-MM-yyyy HH:mm").parse(widget.eventDetail['eventDate'].toString());
    DateTime taskEndDate = DateTime(taskStartDate.year, taskStartDate.month, taskStartDate.day);
    taskEndDate = taskEndDate.add(Duration(days: 1));

    final Event event = Event(
      title: widget.eventDetail['eventTitle'],
      description: widget.eventDetail['eventDescription'],
      location: widget.eventDetail['eventAddress'],
      startDate: taskStartDate,
      endDate: taskEndDate,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  //LIKES
  void getAllUsersLikesForEvent()async{
    eventLikedUsersList.clear();
    userlikedEvent = false;
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getAllLikedUserForEvents(widget.eventDetail, eventLikedUsersList);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(eventLikedUsersList.length);
       for(int i=0; i< eventLikedUsersList.length; i++)
       {
         if(Constants.appUser.userId == eventLikedUsersList[i]['likingUserId'])
         {
          userlikedEvent = true;
          likeDetail = eventLikedUsersList[i];
         }
       }
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void addUserlikeEvent()async{
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().addUserlikeEvent(widget.eventDetail);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
        userlikedEvent = true;
        getAllUsersJoiningEvent();
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void removeUserlikeEvent()async{
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().removeUserlikeEvent(likeDetail);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
      setState(() {
        userlikedEvent = false;
        getAllUsersJoiningEvent();
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        titleSpacing: 0,
        title: Text(
          '${widget.eventDetail['eventTitle']}',
          maxLines: 1,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: SizeConfig.fontSize * 2,
            color: Colors.white,
            fontWeight: FontWeight.w500
          ),
        ),
        actions: [
          GestureDetector(
            onTap: addEventToCalender,
            child: Icon(Icons.calendar_month_sharp, color : Colors.white, size: SizeConfig.blockSizeVertical *3,)
          ),                        
          SizedBox(width: 15,), 
          GestureDetector(
            onTap: (){
              Share.share('Checkout the event ${widget.eventDetail['eventTitle']}\n on EventsApp');
            },
            child: Icon(Icons.share, color : Colors.white, size: SizeConfig.blockSizeVertical *3,)
          ),                        
          SizedBox(width: 15,),               
          GestureDetector(
            onTap: (){
              Get.to(EventLocation(eventDetail: widget.eventDetail,));
            },
            child: Icon(Icons.location_on, color : Colors.white, size: SizeConfig.blockSizeVertical *3,)
          ),                             
          SizedBox(width: 15,),
          GestureDetector(
            onTap: (){
              Get.to(TicketScreen(eventDetail: widget.eventDetail,));
            },
            child: Icon(Icons.wallet_membership_rounded, color : Colors.white, size: SizeConfig.blockSizeVertical *3,)
          ),                             
          SizedBox(width: 15,), 
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              
              Stack(
                children: [
                  Container(
                    height: SizeConfig.blockSizeVertical*35,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(eventImage),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
      
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 15, top: SizeConfig.blockSizeVertical *2.5),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Constants.appThemeColor
                      ),
                      child: Text(
                        (widget.eventDetail['eventPrice'] == "0") ? 'Free Entry' : 'Entry : Rs ${widget.eventDetail['eventPrice']}',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 1.8,
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      
              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.eventDetail['eventTitle'],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: SizeConfig.fontSize * 2.3,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    Container(
                      // child: Row(
                      //   children: [
                      //     Icon(Icons.favorite_border, color : Constants.appThemeColor, size: SizeConfig.blockSizeVertical *3.5,),        
                      //     SizedBox(width: 10,),               
                      //     Icon(Icons.share, color : Constants.appThemeColor, size: SizeConfig.blockSizeVertical *3.3,),                        
                      //     SizedBox(width: 10,),               
                      //     Icon(Icons.location_on, color : Constants.appThemeColor, size: SizeConfig.blockSizeVertical *3.3,),                        
                   
                      //   ],
                      // )
                    ),
                  ],
                ),
              ),
      
              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*1),
                child: Text(
                  widget.eventDetail['eventDescription'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 1.8,
                    color: Colors.black,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*3, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.people, color : Colors.grey[400], size: SizeConfig.blockSizeVertical*3.5,),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${eventJoinedByUsersList.length} people are going',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: SizeConfig.fontSize * 1.8,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              height: (eventJoinedByUsersList.isEmpty) ? 0 : SizeConfig.blockSizeVertical * 5,
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  itemCount: eventJoinedByUsersList.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (_, i) {
                                    return Container(
                                      margin: EdgeInsets.only(left:(i==0) ? 0 : 5),
                                      height: SizeConfig.blockSizeVertical * 5,
                                      width: SizeConfig.blockSizeVertical * 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[300],
                                        image: DecorationImage(
                                          image: (eventJoinedByUsersList[i]['joiningUserPhoto'].isEmpty) ? AssetImage('assets/placeholder.jpeg') : CachedNetworkImageProvider(eventJoinedByUsersList[i]['joiningUserPhoto']) as ImageProvider,
                                          fit: BoxFit.cover
                                        )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ),

              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*3, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, color : Colors.grey[400], size: SizeConfig.blockSizeVertical*3.0,),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${eventLikedUsersList.length} people like this',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: SizeConfig.fontSize * 1.8,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: (){
                                if(AppUser.isGuestUser())
                                  Get.to(LoginScreen(showBackButton: true,));
                                else
                                {
                                  if(!userlikedEvent)
                                    addUserlikeEvent();
                                  else
                                    removeUserlikeEvent();
                                }
                              },
                              child: Container(
                                height: SizeConfig.blockSizeVertical * 5,
                                width:  (!userlikedEvent) ? SizeConfig.blockSizeHorizontal *15 : SizeConfig.blockSizeHorizontal *20,
                                decoration: BoxDecoration(
                                  color: Constants.appThemeColor,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child : Center(
                                  child: Text(
                                    (!userlikedEvent) ? 'Like' : 'Unlike',
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontSize * 1.8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ),

              if(!isJoiningAnswer && !isUserPostedEvent)
              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*2.5, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.event_available, color : Colors.grey[400], size: SizeConfig.blockSizeVertical*3.5,),
                    SizedBox(width: 10,),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are you joining',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.8,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            height: SizeConfig.blockSizeVertical * 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: joinEvent,
                                  child: Container(
                                    height: SizeConfig.blockSizeVertical * 5,
                                    width: SizeConfig.blockSizeHorizontal *15,
                                    decoration: BoxDecoration(
                                      color: Constants.appThemeColor,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child : Center(
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                          fontSize: SizeConfig.fontSize * 1.8,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                // GestureDetector(
                                //   child: Container(
                                //     height: SizeConfig.blockSizeVertical * 5,
                                //     width: SizeConfig.blockSizeHorizontal *15,
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       border: Border.all(
                                //         color: Constants.appThemeColor,
                                //       )
                                //     ),
                                //     child : Center(
                                //       child: Text(
                                //         'No',
                                //         style: TextStyle(
                                //           fontSize: SizeConfig.fontSize * 1.8,
                                //           color: Constants.appThemeColor,
                                //           fontWeight: FontWeight.bold
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ),

              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*2.5, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, color : Colors.grey[400], size: SizeConfig.blockSizeVertical*3.5,),
                    SizedBox(width: 10,),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.eventDetail['eventAddress']},',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.8,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                          '${distanceInKm.toStringAsFixed(1)}km away',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.7,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ),

              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*2.5, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.calendar_month, color : Colors.grey[400], size: SizeConfig.blockSizeVertical*3.5,),
                    SizedBox(width: 10,),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateOnly,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.8,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            timeOnly,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.7,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ),

              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*2.5, right: SizeConfig.blockSizeHorizontal*4, top: SizeConfig.blockSizeVertical*2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person, color : Colors.grey[400], size: SizeConfig.blockSizeVertical*3.5,),
                    SizedBox(width: 10,),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: [
                              Text(
                                'Posted by ${widget.eventDetail['userName']}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.8,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal *2, right: SizeConfig.blockSizeHorizontal *2),
                                height: SizeConfig.blockSizeVertical * 2.4,
                                width: SizeConfig.blockSizeVertical * 2.4,
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
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Container(
                                height: SizeConfig.blockSizeVertical * 5,
                                width: SizeConfig.blockSizeVertical * 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(widget.eventDetail['userImage']),
                                    fit: BoxFit.cover
                                  )
                                ),
                              ),

                              if(!isUserPostedEvent)
                              GestureDetector(
                                onTap: (){
                                  if(AppUser.isGuestUser())
                                    Get.to(LoginScreen(showBackButton: true,));
                                  else
                                    Get.to(HostProfile(hostDetail: hostDetails));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  height: SizeConfig.blockSizeVertical * 3,
                                  width: SizeConfig.blockSizeHorizontal *20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Constants.appThemeColor,
                                      width: 0.5
                                    )
                                  ),
                                  child : Center(
                                    child: Text(
                                      'View Profile',
                                      style: TextStyle(
                                        fontSize: SizeConfig.fontSize * 1.3,
                                        color: Constants.appThemeColor,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*3, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6, bottom: SizeConfig.blockSizeVertical*4),
                height: SizeConfig.blockSizeVertical * 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    if(hostDetails.proUser && !isUserPostedEvent)
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          if(AppUser.isGuestUser())
                            Get.to(LoginScreen(showBackButton: true,));
                          else
                            Get.to(ChatScreen(chatUser: hostDetails, vendorName: hostDetails.name));
                        },
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal *84,
                          decoration: BoxDecoration(
                            color: Constants.appThemeColor,
                            borderRadius: BorderRadius.circular(40)
                          ),
                          child : Center(
                            child: Text(
                              'Contact Host',
                              style: TextStyle(
                                fontSize: SizeConfig.fontSize * 2.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if(hostDetails.proUser && !isUserPostedEvent)
                    SizedBox(width: SizeConfig.blockSizeHorizontal*5,),

                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          if(AppUser.isGuestUser())
                            Get.to(LoginScreen(showBackButton: true,));
                          else
                            Get.to(EventComments(eventDetails: widget.eventDetail,));
                        },
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal *84,
                          decoration: BoxDecoration(
                            color: Constants.appThemeColor,
                            borderRadius: BorderRadius.circular(40)
                          ),
                          child : Center(
                            child: Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: SizeConfig.fontSize * 2.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}