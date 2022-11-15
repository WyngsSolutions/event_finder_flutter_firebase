// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors, avoid_unnecessary_containers
import 'dart:io';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'event_location.dart';

class AddEvents extends StatefulWidget {
  const AddEvents({ Key? key }) : super(key: key);

  @override
  State<AddEvents> createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {

  final format = DateFormat("dd-MM-yyyy HH:mm");
  //
  TextEditingController eventTitle = TextEditingController();
  TextEditingController eventDescription = TextEditingController();
  TextEditingController eventDate = TextEditingController();
  TextEditingController eventAddress = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController eventPrice = TextEditingController();
  bool setEventPrice = true;
  Map? selectedCategory;
  String? selectedCity;
  double latitude = 0;
  double longitude = 0;
  //PHOTO
  XFile? image;
  String imagePath = "";
  final ImagePicker picker = ImagePicker();
  String eventImageUrl = "";

  @override
  void initState() {
    super.initState();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery,);
    if(pickedFile!.path != null)
    {
      setState(() {
        image = pickedFile;
        imagePath = pickedFile.path;
      });
    }
  }

  Future<String> uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + basename(image!.path);
    final _firebaseStorage = FirebaseStorage.instance;
    //Upload to Firebase
    var snapshot = await _firebaseStorage.ref().child("event_pictures").child(fileName).putFile(File(image!.path));
    var downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void addEvent()async{
    if(eventTitle.text.isEmpty)
      Constants.showDialog('Please enter event title');
    else if(eventDescription.text.isEmpty)
      Constants.showDialog('Please enter event description');
    else if(eventDate.text.isEmpty)
      Constants.showDialog('Please enter event date');
    else if(selectedCategory == null)
      Constants.showDialog('Please enter event category');
    else if(eventAddress.text.isEmpty)
      Constants.showDialog('Please enter event address');
    else if(selectedCity == null)
      Constants.showDialog('Please enter event city');
    else if(!setEventPrice && eventPrice.text.isEmpty)
      Constants.showDialog('Please enter event ticket price');
    else if(image == null)
      Constants.showDialog('Please select event image');
    else if(latitude == 0 && longitude ==0)
      Constants.showDialog('Please set event location on map');
    else
    { 
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
      if(image != null)
        eventImageUrl = await uploadFile();

      if(setEventPrice)
        eventPrice.text = "0";
      dynamic result = await AppController().addEvent(eventTitle.text, eventDescription.text, eventDate.text, selectedCategory!, eventAddress.text, selectedCity!, eventPrice.text, latitude, longitude, eventImageUrl);
      EasyLoading.dismiss();
      if(result['Status'] == 'Success')
      {
        Get.back(result: true);
        Constants.showDialog('Event has been posted successfully');
      }
      else
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus)
              currentFocus.unfocus();
          },
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
                      IconButton(
                        onPressed: (){
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConfig.blockSizeVertical*3,),
                      )
                    ],
                  ),
                ),
              
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Text(
                    'Add Event',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*3.5,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Text(
                    'Fill up the form to post event',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                    ),
                  ),
                ),
                
                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      controller: eventTitle,
                      decoration: InputDecoration(
                        hintText: 'Event title',
                        hintStyle:TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: TextField(
                      minLines: 6,
                      maxLines: 6,
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      controller: eventDescription,
                      decoration: InputDecoration(
                        hintText: 'Event description',
                        hintStyle:TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: DateTimeField(
                      format: format,
                      controller: eventDate,
                      resetIcon: const Icon(Icons.close, color: Colors.transparent,),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        border: InputBorder.none,
                        hintText: 'Event date',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                      ),
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100)
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                          );
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                  ),
                ),

                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: DropdownButton<dynamic>(
                      isExpanded: true,
                      underline: Container(),
                      value: selectedCategory,
                      hint: Text('Event category', style: TextStyle(fontSize: SizeConfig.fontSize * 1.8),),
                      style: TextStyle(fontSize: SizeConfig.fontSize * 1.8, color: Colors.white,),
                      items: Constants.categories.map((dynamic value) {
                        return DropdownMenuItem<dynamic>(
                          value: value,
                          child: Text(
                            value['categoryName'],
                            style: TextStyle(fontSize: SizeConfig.fontSize * 1.8, color: Colors.black,),
                          ),
                        );
                      }).toList(),
                      onChanged: (_) async {
                        setState(() {
                          selectedCategory = _;
                        });
                      },
                    )
                  ),
                ),

                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      controller: eventAddress,
                      decoration: InputDecoration(
                        hintText: 'Event address',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: DropdownButton<dynamic>(
                      isExpanded: true,
                      underline: Container(),
                      value: selectedCity,
                      hint: Text('Event city', style: TextStyle(fontSize: SizeConfig.fontSize * 1.8),),
                      style: TextStyle(fontSize: SizeConfig.fontSize * 1.8, color: Colors.white,),
                      items: Constants.cities.map((dynamic value) {
                        return DropdownMenuItem<dynamic>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: SizeConfig.fontSize * 1.8, color: Colors.black,),
                          ),
                        );
                      }).toList(),
                      onChanged: (_) async {
                        setState(() {
                          selectedCity = _;
                        });
                      },
                    )
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Free Event?',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 1.8,
                          color: Colors.black,
                          //fontWeight: FontWeight.bold
                        ),
                      ),
                      
                      Container(
                        child: FlutterSwitch(
                          width: SizeConfig.blockSizeHorizontal* 15,
                          height: SizeConfig.blockSizeVertical* 3,
                          valueFontSize: 0.0,
                          toggleSize: SizeConfig.blockSizeVertical* 3,
                          value: setEventPrice,
                          borderRadius: SizeConfig.blockSizeVertical* 3,
                          padding: 0.0,
                          showOnOff: true,
                          activeColor: Constants.appThemeColor,
                          activeToggleColor: Colors.grey[200],
                          inactiveToggleColor: Colors.grey[200],
                          onToggle: (val) {
                            setState(() {
                              setEventPrice = val;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                ),

                if(!setEventPrice)
                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      controller: eventPrice,
                      decoration: InputDecoration(
                        hintText: 'Event ticket price',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              
                GestureDetector(
                  onTap: getImage,
                  child: Container(
                    height: SizeConfig.blockSizeVertical*25,
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: (image != null) ? FileImage(File(imagePath)) : AssetImage('assets/placeholder.jpeg') as ImageProvider,
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ),
              
                GestureDetector(
                  onTap: () async {
                    dynamic result = await Get.to(EventLocation());
                    if(result != null)
                    {
                      latitude = result.latitude;
                      longitude = result.longitude;
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*3, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6,),
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child : Center(
                      child: Text(
                        'Set Location On Map',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 2.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: addEvent,
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6, bottom: SizeConfig.blockSizeVertical*3),
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child : Center(
                      child: Text(
                        'Add Event',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 2.0,
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
        ),
      ),
    );
  }
}