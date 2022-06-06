import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/splashScreen/splash_screen.dart';

class CarInfoScreen extends StatefulWidget {

  @override
  _CarInfoScreenState createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {

  TextEditingController carModelEditingController= TextEditingController();
  TextEditingController carNumberTextEditingController= TextEditingController();
  TextEditingController carColorTextEditingController= TextEditingController();


 List<String> carTypeList =["Hizmet-1","Hizmet-2","Hizmet-3"];
 String selectedCarType;

 saveCarInfo(){
   Map driverCarInfoMap={
     "car_color":carColorTextEditingController.text.trim(),
     "car_number":carNumberTextEditingController.text.trim(),
     "car_model":carModelEditingController.text.trim(),
     "type":selectedCarType,

   };
   DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
   driversRef.child(currentFirebaseUser.uid).child("car_details").set(driverCarInfoMap);

   Fluttertoast.showToast(msg: "Araba Detayları kaydedildi,Tebrikler.");
   Navigator.push(context, MaterialPageRoute(builder: (c)=>  MySplashScreen()));
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 24,),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/doctorambulance5.jpg"),
              ),
              const SizedBox(height: 10,),

              Text(
                "Araba Detaylarını Yazınız",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: 21,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                controller: carModelEditingController,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent
                ),
                decoration: const InputDecoration(
                  labelText: "Hizmet Adı",
                  hintText: "Hizmet Adı",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide( color: Colors.deepPurpleAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide( color: Colors.deepPurpleAccent),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: carNumberTextEditingController,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent
                ),
                decoration: const InputDecoration(
                  labelText: "Araba Numarası",
                  hintText: "Araba Numarası",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide( color: Colors.deepPurpleAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide( color: Colors.deepPurpleAccent),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller:carColorTextEditingController,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent
                ),
                decoration: const InputDecoration(
                  labelText: "Araba Rengi",
                  hintText: "Araba Rengi",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide( color: Colors.deepPurpleAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide( color: Colors.deepPurpleAccent),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 14,
                  ),
                ),
              ),

           const SizedBox(height: 10,),

              DropdownButton(
                iconSize: 26,
                dropdownColor: Colors.white,
                hint: const Text(
                  "Lütfen Hizmet Türünü seçiniz",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.deepPurple,
                  ),
                ),
                value: selectedCarType,
                onChanged: (newValue){
                  setState(() {
                    selectedCarType= newValue.toString();
                  });
                },
                items: carTypeList.map((car){
                  return DropdownMenuItem(
                      child:Text(
                    car,
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    value: car,
                  );

              }).toList(),
              ),
              const SizedBox(height: 20,),

              ElevatedButton(
                  onPressed: (){
                    if(carColorTextEditingController.text.isNotEmpty
                        && carNumberTextEditingController.text.isNotEmpty
                        && carModelEditingController.text.isNotEmpty && selectedCarType != null)
                    {
                    saveCarInfo();

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurpleAccent,
                  ),
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
