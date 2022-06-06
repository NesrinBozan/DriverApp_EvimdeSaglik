import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/infoHandler/app_info.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';


class RatingsTabPage extends StatefulWidget {

  const RatingsTabPage({Key key}) : super(key: key);


  @override
  _RatingsTabPageState createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  double ratingsNumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRatingsNumber();

  }

  getRatingsNumber()
  {
    setState(() {
      ratingsNumber =   double.parse(Provider.of<AppInfo>(context,listen:false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle()
  {
    if(ratingsNumber ==1)
    {
      setState(() {
        titleStarsRating = "Çok Kötü";
      });
    }
    if(ratingsNumber ==2)
    {
      setState(() {
        titleStarsRating = "Kötü";
      });
    }
    if(ratingsNumber ==3)
    {
      setState(() {
        titleStarsRating = "İyi";
      });
    }
    if(ratingsNumber ==4)
    {
      setState(() {
        titleStarsRating = "Çok İyi";
      });
    }
    if(ratingsNumber ==5)
    {
      setState(() {
        titleStarsRating = "Harika";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent[50],
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.deepPurpleAccent[100],
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:  [

              const SizedBox(height: 22.0,),

              const Text(
                " Senin Puanın",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),),
              const SizedBox(height: 22.0,),

              const Divider(height: 4.0, thickness: 4.0,),

              const SizedBox(height: 22.0,),

              SmoothStarRating(
                  rating: ratingsNumber,
                  allowHalfRating: false,
                  starCount: 5,
                  color: Colors.limeAccent,
                  borderColor: Colors.limeAccent,
                  size: 46,

              ),

              const SizedBox(height: 12.0,),

              Text(
                titleStarsRating,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),

              const SizedBox(height: 18.0,),



            ],
          ),
        ),
      ),
    );
  }
}
