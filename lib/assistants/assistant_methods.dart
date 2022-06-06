import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saglik_kapimda/assistants/request_assistant.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/global/map_key.dart';
import 'package:saglik_kapimda/infoHandler/app_info.dart';
import 'package:saglik_kapimda/models/direction_details_info.dart';
import 'package:saglik_kapimda/models/directions.dart';
import 'package:saglik_kapimda/models/user_model.dart';


class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {
    String apiUrl= "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";


    var requestResponse =   await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response")
   {
     humanReadableAddress = requestResponse["results"][0]["formatted_address"];

     Directions userPickUpAddress = Directions();
     userPickUpAddress.locationLatitude =position.latitude;
     userPickUpAddress.locationLongitude = position.longitude;
     userPickUpAddress.locationName = humanReadableAddress;

     Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

   }
    return humanReadableAddress;
  }
  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser =fAuth.currentUser;

    DatabaseReference userRef=FirebaseDatabase.instance
        .ref()
        .child("users").child(currentFirebaseUser.uid);

    userRef.once().then((snap)
    {
      if(snap.snapshot.value !=null)
        {
      userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      print("name = "+ userModelCurrentInfo.name.toString());
      print("email = "+ userModelCurrentInfo.email.toString());

        }
    });
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng origionPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error Occurred, Failed. No Response.")
    {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }


 static pauseLiveLocationUpdates()
  {
    streamSubscriptionPosition.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }


  static resumeLiveLocationUpdates()
  {
    streamSubscriptionPosition.resume();
    Geofire.setLocation(currentFirebaseUser.uid,
        driverCurrentPosition.latitude,
        driverCurrentPosition.longitude);
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value /60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value /1000) * 0.1;

    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;

    if(driverVehicleType == "Hizmet-1")
    {
      double resultFareAmount = (totalFareAmount.truncate()) /2.0;
      return resultFareAmount;
    }
    else if(driverVehicleType == "Hizmwt-2")
      {
        return totalFareAmount.truncate().toDouble();
      }
    else if(driverVehicleType == "Hizmet-3")
      {
        double resultFareAmount = (totalFareAmount.truncate()) /2.0;
        return resultFareAmount;

      }
    else
      {
        return totalFareAmount.truncate().toDouble();
    }


  }

  static void readDriverRatings(context)
  {
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(fAuth.currentUser.uid)
        .child("ratings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null){
        String driverRatings =snap.snapshot.value.toString();
        Provider.of<AppInfo>(context,listen:false).updateDriverAverageRatings(driverRatings);


      }
    });


  }

}
