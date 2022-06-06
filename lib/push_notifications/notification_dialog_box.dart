import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saglik_kapimda/assistants/assistant_methods.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/mainScreens/new_trip_screen.dart';
import 'package:saglik_kapimda/models/user_ride_request_information.dart';


class NotificationDialogBox extends StatefulWidget {

  UserRideRequestInformation userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});
  @override
  _NotificationDialogBoxState createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14,),

            Image.asset("images/ambulance.png",
            width: 140,),

           const  SizedBox(height: 12,),

            Text(
              "Yeni Rota",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.deepPurple
              ),
            ),

            const SizedBox(height: 14.0,),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      Icon(Icons.location_on,
                      size: 30,
                      color: Colors.amberAccent,),
                      const SizedBox(width: 22,),

                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails.originAddress,
                            style:  const TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurple
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

           const Divider(
             height: 3,
             thickness: 3,
           ),

           Padding(
             padding: const EdgeInsets.all(20.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     primary: Colors.redAccent
                   ),
                   onPressed: ()
                   {
                     audioPlayer.pause();
                     audioPlayer.stop();
                     audioPlayer = AssetsAudioPlayer();
                     // cansel the rideRequest

                     FirebaseDatabase.instance.ref()
                         .child("All Ride Request")
                         .child(widget.userRideRequestDetails.rideRequestId)
                         .remove().then((value)
                     {
                       FirebaseDatabase.instance.ref()
                           .child("drivers")
                           .child(currentFirebaseUser.uid)
                           .child("newRideStatus").set("idle");
                     }).then((value)
                     {
                       FirebaseDatabase.instance.ref()
                           .child("drivers")
                           .child(currentFirebaseUser.uid)
                           .child("tripHistory")
                           .child(widget.userRideRequestDetails.rideRequestId)
                           .remove();
                     }).then((value)
                     {
                       Fluttertoast.showToast(msg: "Hizmet isteği başarıyla iptal edildi.");

                     });
                     SystemNavigator.pop();
                   },
                   child: Text(
                     "İptal Et".toUpperCase(),
                     style:  const TextStyle(
                         fontSize:  14.0
                     ),
                   ),
                 ),

                 const SizedBox(width: 25,),

                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       primary: Colors.green
                   ),
                   onPressed: ()
                   {
                     audioPlayer.pause();
                     audioPlayer.stop();
                     audioPlayer = AssetsAudioPlayer();
                     // accept the rideRequest
                     acceptRideRequest(context);
                   },
                   child: Text(
                     "Onayla".toUpperCase(),
                     style:  const TextStyle(
                         fontSize:  14.0
                     ),
                   ),
                 )
               ],
             ),
           )

          ],
        ),
      ),
    );
  }

  acceptRideRequest (BuildContext context)
  {
    String getRideRequestId = "";
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser.uid)
        .child("newRideStatus")
        .once()
        .then((snap)
    {
     if(snap.snapshot.value != null)
       {
         getRideRequestId = snap.snapshot.value.toString();
         print("This is getRideRequestId ::");
         print(getRideRequestId);

       }
     else
       {
         Fluttertoast.showToast(msg: "Sürüş talebi tanımlı değil.");
       }

     print("This is widget.userRideRequestDetails.rideRequestId::");
     print(widget.userRideRequestDetails.rideRequestId.toString());
     Fluttertoast.showToast(msg: "widget.userRideRequestDetails.rideRequestId= " + widget.userRideRequestDetails.rideRequestId.toString());

     if(getRideRequestId == widget.userRideRequestDetails.rideRequestId)
     {
       FirebaseDatabase.instance.ref()
           .child("drivers")
           .child(currentFirebaseUser.uid)
           .child("newRideStatus")
           .set("accepted");

       AssistantMethods.pauseLiveLocationUpdates();

       // trip  started now - send driver to tripscreen
         Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripScreen(
           userRideRequestDetails: widget.userRideRequestDetails,

         )));

           }
     else
       {
         Fluttertoast.showToast(msg: "Sürüş talebi tanımlı değil.");
       }

    });
  }


}
