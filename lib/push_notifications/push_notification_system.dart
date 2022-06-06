

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/models/user_ride_request_information.dart';
import 'package:saglik_kapimda/push_notifications/notification_dialog_box.dart';


class PushNotificationSystem
{
  FirebaseMessaging messaging = FirebaseMessaging.instance;


  Future initializedCloudMessaging(BuildContext context)async
  {
    //1.Terminated
    FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage remoteMessage) {
      if (remoteMessage != null) {

        // display ride request information - user information who request a ride
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"],context);
      }
    });

    //2.Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {

      readUserRideRequestInformation(remoteMessage.data["rideRequestId"],context);
    });
    //3.Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {

      readUserRideRequestInformation(remoteMessage.data["rideRequestId"],context);
    });

  }
    readUserRideRequestInformation(String userRideRequestId, BuildContext context)
    {
      FirebaseDatabase.instance.ref()
          .child("All Ride Request")
          .child(userRideRequestId)
          .once()
          .then((snapData)
      {
        if(snapData.snapshot.value !=null)
          {

            audioPlayer.open(Audio("music/music_notification.mp3"));
            audioPlayer.play();

            double originLat = double.parse((snapData.snapshot.value as Map)["origin"]["latitude"].toString());
            double originLng = double.parse((snapData.snapshot.value as Map)["origin"]["longitude"].toString());
            String originAddress = (snapData.snapshot.value as Map)["originAddress"];


            String userName =(snapData.snapshot.value as Map)["userName"];
            String userPhone =(snapData.snapshot.value as Map)["userPhone"];

            String rideRequestId = snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();

            userRideRequestDetails.originLatLng =LatLng(originLat, originLng);
            userRideRequestDetails.originAddress = originAddress;

            userRideRequestDetails.userName = userName;
            userRideRequestDetails.userPhone = userPhone;

            userRideRequestDetails.rideRequestId = rideRequestId;

            showDialog(
                context: context,
                builder: (
                BuildContext contxt) => NotificationDialogBox(
                userRideRequestDetails: userRideRequestDetails,),
            );
          }
        else{
          Fluttertoast.showToast(msg: "Bu sürüş isteği tanımlı değil.");
        }
      });
    }



  Future<String> generateAndGetToken()async
  {
    String registrationToken = await messaging.getToken();
    print(registrationToken);

    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");

  }
}