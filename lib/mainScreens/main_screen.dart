import 'package:flutter/material.dart';
import 'package:saglik_kapimda/tabPages/earning_tab.dart';
import 'package:saglik_kapimda/tabPages/home_tab.dart';
import 'package:saglik_kapimda/tabPages/profile_tab.dart';
import 'package:saglik_kapimda/tabPages/ratings_tab.dart';

class MainScreen extends StatefulWidget {


  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{

  TabController tabController;
  int selectedIndex=0;

  onItemClicked(int index){
    setState(() {
      selectedIndex= index;
      tabController.index =selectedIndex;

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController= TabController(length: 4, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics:const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          EarningTabPage(),
          RatingsTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label:"Ana Sayfa"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label:"Earning"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label:"Puan"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label:"Profil"
          ),

        ],
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
