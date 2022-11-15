import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class SearchScreen extends StatefulWidget {

  final List allEvents;
  const SearchScreen({ Key? key, required this.allEvents }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  List prices = ['Free', 'Paid'];
  List filteredEvents = [];

  @override
  void initState() {
    super.initState();
  }

  void setFilters(){
    //CATEGORY
    if(Constants.selectedCat.isNotEmpty)
      filteredEvents = widget.allEvents.where((element) => element['selectedCategory']['categoryId'] == Constants.selectedCat['categoryId']).toList();
    else
      filteredEvents = widget.allEvents;

    //CITY
    if(Constants.selectedCity.isNotEmpty)
      filteredEvents = filteredEvents.where((element) => element['eventCity'] == Constants.selectedCity).toList();

    //PRICE
    if(Constants.selectedPrice.isNotEmpty && Constants.selectedPrice == "Free")
      filteredEvents = filteredEvents.where((element) => element['eventPrice'] == '0').toList();
    
    if(Constants.selectedPrice.isNotEmpty && Constants.selectedPrice != "Free")
      filteredEvents = filteredEvents.where((element) => element['eventPrice'] != '0').toList();

    Get.back(result: filteredEvents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body : Container(
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
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                'Set Categories',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize* 1.9,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.4/1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10
                ),
                itemBuilder: (_, index) => categoryCell(Constants.categories[index], index),
                itemCount: Constants.categories.length,
              )
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                'Set Cities',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize* 1.9,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.4/1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10
                ),
                itemBuilder: (_, index) => cityCell(Constants.cities[index], index),
                itemCount: Constants.cities.length,
              )
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                'Event Price',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize* 1.9,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.4/1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10
                ),
                itemBuilder: (_, index) => priceCell(prices[index], index),
                itemCount: prices.length,
              )
            ),

            Spacer(),
            GestureDetector(
              onTap: setFilters,
              child: Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*7, right: SizeConfig.blockSizeHorizontal*7, bottom: SizeConfig.blockSizeVertical*3),
                height: SizeConfig.blockSizeVertical * 7,
                width: SizeConfig.blockSizeHorizontal *84,
                decoration: BoxDecoration(
                  color: Constants.appThemeColor,
                  borderRadius: BorderRadius.circular(40)
                ),
                child : Center(
                  child: Text(
                    'Set Filters',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize * 2.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
          ]
        )
      )
    );
  }

  Widget filterView(){
    return Container(

    );
  }

  Widget categoryCell(Map category, int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          Constants.selectedCat = category;
        });
      },
      child: Container(
        //margin: EdgeInsets.only(left: (index==0) ? 0 : SizeConfig.blockSizeHorizontal * 4),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: (Constants.selectedCat['categoryName'] == category['categoryName']) ? Constants.appThemeColor : Colors.white,
          border: Border.all(
            width: 1,
            color: Constants.appThemeColor
          )
        ),
        child: Center(
          child: Text(
            category['categoryName'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeConfig.fontSize * 1.7,
              color: (Constants.selectedCat['categoryName'] != category['categoryName']) ? Constants.appThemeColor : Colors.white,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

  Widget cityCell(String city, int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          Constants.selectedCity = city;
        });
      },
      child: Container(
        //margin: EdgeInsets.only(left: (index==0) ? 0 : SizeConfig.blockSizeHorizontal * 4),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: (Constants.selectedCity == city) ? Constants.appThemeColor : Colors.white,
          border: Border.all(
            width: 1,
            color: Constants.appThemeColor
          )
        ),
        child: Center(
          child: Text(
            city,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeConfig.fontSize * 1.7,
              color: (Constants.selectedCity != city) ? Constants.appThemeColor : Colors.white,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

   Widget priceCell(String price, int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          Constants.selectedPrice = price;
        });
      },
      child: Container(
        //margin: EdgeInsets.only(left: (index==0) ? 0 : SizeConfig.blockSizeHorizontal * 4),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: (Constants.selectedPrice == price) ? Constants.appThemeColor : Colors.white,
          border: Border.all(
            width: 1,
            color: Constants.appThemeColor
          )
        ),
        child: Center(
          child: Text(
            price,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeConfig.fontSize * 1.7,
              color: (Constants.selectedPrice != price) ? Constants.appThemeColor : Colors.white,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }
}