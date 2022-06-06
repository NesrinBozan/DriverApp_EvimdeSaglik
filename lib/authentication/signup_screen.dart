
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:saglik_kapimda/authentication/car_info_screen.dart';
import 'package:saglik_kapimda/authentication/login_screen.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/widgets/progress_dialog.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController nameTextEditingController= TextEditingController();
  TextEditingController emailTextEditingController= TextEditingController();
  TextEditingController phoneTextEditingController= TextEditingController();
  TextEditingController passwordTextEditingController= TextEditingController();

  validateForm(){
    if(nameTextEditingController.text.length < 3){

      Fluttertoast.showToast(msg: " Ad en az 3 karakter olmalıdır.");
    }
    else if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "E-Posta geçerli değil.");
    }
    else if(phoneTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Telefon numarası zorunlu.");
    }
    else if(passwordTextEditingController.text.length < 6){
      Fluttertoast.showToast(msg: "Şİfre en az 6 karakter olmalıdır.");
    }
    else{
      saveDriverInfoNow();
    }

  }
  saveDriverInfoNow() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
          return ProgressDialog(message: "Bağlanıyor, Lütfen bekleyiniz...",);
        }
    );
    final User firebaseUser= (
    await fAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim() ,
        password: passwordTextEditingController.text.trim()
    ).catchError((msg){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error:" + msg.toString());
    })
    ).user;

    if(firebaseUser != null){
      Map driverMap={
        "id":firebaseUser.uid,
        "name":nameTextEditingController.text.trim(),
        "email":emailTextEditingController.text.trim(),
        "phone":phoneTextEditingController.text.trim(),
      };

      DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
      driversRef.child(firebaseUser.uid).set(driverMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Hesap Oluşturuldu.");
      Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));
    }
    else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Hesap Oluşturulamadı.");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset("images/doctorambulance5.jpg"),
              ),
              const SizedBox(height: 6,),

              Text(
                "Sürücü Olarak Kaydolun",
                style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 21,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),

              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(
                  color: Colors.deepPurpleAccent
                ),
                decoration: const InputDecoration(
                  labelText: "Ad",
                  hintText: "Ad",
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
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
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
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent
                ),
                decoration: const InputDecoration(
                  labelText: "Telefon Numarası",
                  hintText: "Telefon Numarası",
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
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent
                ),
                decoration: const InputDecoration(
                  labelText: "Şifre",
                  hintText: "Şifre",
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

              const SizedBox(height: 8,),

              ElevatedButton(
                  onPressed: (){
                    validateForm();
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));

              },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurpleAccent,
                  ),
                  child: const Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )),
              TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));

                  },
                  child: const Text(
                    "Zaten bir hesabın var mı? Giriş Yap",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ))
            ],
          ),
        ),

      ),
    );
  }
}
