import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../event_detail/event_detail.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCalenderView extends StatefulWidget {

  final List allEvents;
  const EventCalenderView({ Key? key, required this.allEvents }) : super(key: key);

  @override
  State<EventCalenderView> createState() => _EventCalenderViewState();
}

class _EventCalenderViewState extends State<EventCalenderView> {

  List filteredEvents = [];

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    filterTasksOnDate();
  }

  void filterTasksOnDate(){
    filteredEvents.clear();
    for(int i=0; i< widget.allEvents.length; i++)
    {
      DateTime taskDate = DateFormat("dd-MM-yyyy HH:mm").parse(widget.allEvents[i]['eventDate'].toString());
      if(taskDate.day == _selectedDay.day && taskDate.month == _selectedDay.month && taskDate.year == _selectedDay.year) {
        setState(() {
          filteredEvents.add(widget.allEvents[i]);          
        });
      }
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
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                      ),
                    ],
                  )
                ],
              ),
            ),

            TableCalendar(
              calendarFormat: _calendarFormat,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration : BoxDecoration(
                  color: Constants.appThemeColor,
                  shape: BoxShape.circle
                )
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  filterTasksOnDate();
                });
              },
            ),

            (filteredEvents.isEmpty) ? Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*10, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Center(
                  child: Text(
                    'No Events Found',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                      color: Colors.grey[400]!
                    ),
                  ),
                ),
              ),
            ) : Expanded(
              child: Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (_, i) {
                      return eventCell(filteredEvents[i], i);
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
      child: Container(
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
            )
          ],
        ),
      ),
    );
  }
}