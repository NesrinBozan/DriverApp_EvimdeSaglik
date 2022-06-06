


import 'package:flutter/cupertino.dart';
import 'package:saglik_kapimda/models/directions.dart';


class AppInfo extends ChangeNotifier
{
  Directions userPickUpLocation, userDropOffLocation;
  String driverAverageRatings = "0";

  void updatePickUpLocationAddress(Directions userPickUpAddress)
  {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
  void updateDropOffLocationAddress(Directions DropOffAddress)
  {
    userDropOffLocation =DropOffAddress;
    notifyListeners();
  }

  updateDriverAverageRatings(String driverRatings)
  {
    driverAverageRatings = driverRatings;

  }
}