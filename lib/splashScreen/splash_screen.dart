import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saglik_kapimda/authentication/login_screen.dart';
import 'package:saglik_kapimda/authentication/signup_screen.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/mainScreens/main_screen.dart';


class MySplashScreen extends StatefulWidget {
  
  
  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen> {
  
  startTimer(){
    Timer( const Duration(seconds:1),() async{
      if(await fAuth.currentUser !=null)
      {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }else
        {
          // send user to main screen
          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
        }

      
    });
  }
  @override
  void initState() {
    super.initState();
    startTimer();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurpleAccent,
              Colors.white,
            ],
          ),
        ),
        // color: Colors.white,
  /*      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/doctorambulance5.jpg"),
             const  SizedBox(height: 10,),
           const  Text(
                "Evimde Sağlık ",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),*/


      ),
    );
  }
}
