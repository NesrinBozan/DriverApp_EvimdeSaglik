import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saglik_kapimda/assistants/assistant_methods.dart';
import 'package:saglik_kapimda/assistants/black_theme_google_map.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/models/user_ride_request_information.dart';
import 'package:saglik_kapimda/widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {


  UserRideRequestInformation userRideRequestDetails;
  NewTripScreen({
    this.userRideRequestDetails
});
  @override
  _NewTripScreenState createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {

  GoogleMapController newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String buttonTitle ="Ulaşıldı";
  Color buttonColor = Colors.lightGreenAccent;
  String statusBtn = "accepted";

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyLine = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polyLinePoints = PolylinePoints();

  double mapPadding =0;
  BitmapDescriptor iconAnimetedMarker;
  var geoLocator = Geolocator();
  Position onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";
  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;


  // 1. when driver accepts the user ride request
  // originLatlng = driverCurrent Location
  // destinationLatlng = user PickUp Location

  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng) async
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points);

    polyLinePositionCoordinates.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
    {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
      {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyLine.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyLine.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }
  createDriverIconMarker()
  {
    if(iconAnimetedMarker == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/ambulance2.png").then((value)
      {
        iconAnimetedMarker = value;
      });
    }
  }
  getDriversLocationUpdatesAtRealTime()
  {

    LatLng oldLatLng = LatLng(0, 0);

     streamSubscriptionDriverLivePosition =Geolocator.getPositionStream()
        .listen((Position position)
    {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition =position;

      LatLng latLngLiveDriverPosition= LatLng(
          onlineDriverCurrentPosition.latitude,
          onlineDriverCurrentPosition.longitude
      );

      Marker animetingMarker = Marker(
          markerId: const MarkerId("AnimatedMarker"),
          position: latLngLiveDriverPosition,
        icon: iconAnimetedMarker,
        infoWindow: const InfoWindow(title: "Konumun"),

      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target:latLngLiveDriverPosition, zoom: 16 );
        newTripGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere((element) => element.mapsId.value == "AnimatedMarker");
        setOfMarkers.add(animetingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

       Map driverLatLngDataMap =
       {
         "latitude": onlineDriverCurrentPosition.latitude.toString(),
         "longitude": onlineDriverCurrentPosition.longitude.toString(),
       };

       FirebaseDatabase.instance.ref()
            .child("All Ride Request")
           .child(widget.userRideRequestDetails.rideRequestId).child("driverLocation")
           .set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async
  {
   if(isRequestDirectionDetails == false)
     {
       isRequestDirectionDetails =true;


       if(onlineDriverCurrentPosition == null)
         {
           return;
         }

       var originLatLng = LatLng(
           onlineDriverCurrentPosition.latitude,
           onlineDriverCurrentPosition.longitude
       ); // Driver Current Location

       var destinationLatLng;

       if(rideRequestStatus == "accepted")
       {
         destinationLatLng = widget.userRideRequestDetails.originLatLng; // User PickUp location

       }
       else
       {

         var destinationLatLng = widget.userRideRequestDetails.destinationLatLng; // user
       }


       var directionInformation = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng );

       if(directionInformation != null)
       {
         setState(() {
           durationFromOriginToDestination = directionInformation.duration_text;
         });
       }
       isRequestDirectionDetails = false;
     }
  }

  @override
  Widget build(BuildContext context) {

    createDriverIconMarker();
    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyLine,

            onMapCreated: (GoogleMapController contoller)
            {

              _controllerGoogleMap.complete(contoller);
              newTripGoogleMapController =contoller;

              setState(() {
                mapPadding =350;
              });
              //black theme google map
              blackThemeGoogleMap(newTripGoogleMapController);

              var driverCurrentLatLng = LatLng(
                  driverCurrentPosition.latitude,
                  driverCurrentPosition.longitude);


             var userPickUpLatlng = widget.userRideRequestDetails.originLatLng;

             drawPolyLineFromOriginToDestination(driverCurrentLatLng, userPickUpLatlng);

             getDriversLocationUpdatesAtRealTime();


             },

          ),

          //ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration:  const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(0.6,0.6),
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 20.0),
                child: Column(
                  children: [

                    // duration
                    Text(
                      durationFromOriginToDestination,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightGreenAccent
                    ),),

                    const SizedBox(height: 18,),
                    const   Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 8,),
                    // user name - icon
                    Row(
                      children: [
                        Text(
                        widget.userRideRequestDetails.userName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreenAccent
                          ),
                        ),
                     const  Padding(
                          padding:  EdgeInsets.all(10.0),
                          child: Icon(Icons.phone_android,
                          color: Colors.black,),
                        )
                      ],
                    ),

                    const SizedBox(height: 18,),

                    // user picUpplocation with icon
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

                    const SizedBox(height: 24.0,),

                    const   Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.black26,
                    ),

                    const SizedBox(height: 10.0,),

                    ElevatedButton.icon(onPressed: () async
                        {
                          if(rideRequestStatus  == "accepted")
                            {
                              rideRequestStatus = "Ulaşıldı";
                              FirebaseDatabase.instance.ref()
                              .child("All Ride Request ")
                              .child(widget.userRideRequestDetails.rideRequestId)
                              .child("status").set(rideRequestStatus);

                              setState(() {
                                buttonTitle = "İşlem Tamam";
                                buttonColor = Colors.lightGreenAccent;
                              });
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext c) => ProgressDialog(
                                   message: "Hastaya Ulaştınız...",
                              ),
                              );
                              await drawPolyLineFromOriginToDestination(
                              widget.userRideRequestDetails.originLatLng,
                              widget.userRideRequestDetails.destinationLatLng);
                        }
                          else if (rideRequestStatus == "Ulaşıldı")
                            {
                              endTripNow();

                            }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: buttonColor
                        ),
                        icon: const Icon(
                          Icons.directions_car,
                          color: Colors.black,
                          size: 25,
                        ), label:
                        Text
                          (
                          buttonTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ) ,

    );
  }

  endTripNow() async
  {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext c) => ProgressDialog(
        message: "Hastaya Ulaştınız...",
      ),
    );

    //get the tripDirectionDetails = distance travelled
    var currentDriverPositionLatLng = LatLng(

      onlineDriverCurrentPosition.latitude,
      onlineDriverCurrentPosition.longitude,
    );
  var tripDirectionDetails =  await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        currentDriverPositionLatLng
        ,widget.userRideRequestDetails.originLatLng );

  // fare amount
    double  totalFareAMount= AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails);

    FirebaseDatabase.instance.ref()
        .child("All Ride Request")
        .child(widget.userRideRequestDetails.rideRequestId)
        .child("fareAmount")
        .set(totalFareAMount.toString());
    FirebaseDatabase.instance.ref()
        .child("All Ride Request")
        .child(widget.userRideRequestDetails.rideRequestId)
        .child("status")
        .set("ended");

    streamSubscriptionDriverLivePosition.cancel();

    Navigator.pop(context);

  }


  saveAssignedDriverDetailsToUserRideRequest()
  {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref()
                                           .child("All Ride Request")
                                           .child(widget.userRideRequestDetails.rideRequestId);

    Map driverLocationDataMap =
    {
      "latitude": driverCurrentPosition.latitude.toString(),
      "longitude": driverCurrentPosition.longitude.toString(),
    };

    databaseReference.child("driverLocation").set(driverLocationDataMap);

    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(onlineDriverData.id);
    databaseReference.child("driverName").set(onlineDriverData.name);
    databaseReference.child("driverPhone").set(onlineDriverData.phone);
    databaseReference.child("car_details").set(onlineDriverData.car_color.toString() + onlineDriverData.car_model.toString() + onlineDriverData.car_number.toString());

   saveRideRequestIdToDriverHistory();


  }
  saveRideRequestIdToDriverHistory ()
  {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser.uid)
        .child("tripsHistory");
 tripsHistoryRef.child(widget.userRideRequestDetails.rideRequestId).set(true);
  }

}
