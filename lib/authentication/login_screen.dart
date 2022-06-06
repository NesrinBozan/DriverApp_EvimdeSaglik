import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saglik_kapimda/authentication/signup_screen.dart';
import 'package:saglik_kapimda/global/global.dart';
import 'package:saglik_kapimda/splashScreen/splash_screen.dart';
import 'package:saglik_kapimda/widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailTextEditingController= TextEditingController();
  TextEditingController passwordTextEditingController= TextEditingController();

  validateForm(){
     if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "E-Posta geçerli değil.");
    }
    else if(passwordTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Şİfre boş bırakılamaz.");
    }
    else{
   loginDriverNow();
    }

  }
  loginDriverNow() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
          return ProgressDialog(message: "Bağlanıyor, Lütfen bekleyiniz...",);
        }
    );
    final User firebaseUser= (
        await fAuth.signInWithEmailAndPassword(
            email: emailTextEditingController.text.trim() ,
            password: passwordTextEditingController.text.trim()
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error:" + msg.toString());
        })
    ).user;

    if(firebaseUser != null)
    {

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Giriş Başarılı.");
      Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
    }
    else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Giriş sırasında hata oluştu.");

    }
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
              const SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/doctorambulance5.jpg"),
              ),
              const SizedBox(height: 10,),

              Text(
                "Sürücü Olarak Giriş Yapın",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: 21,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
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

              const SizedBox(height: 20,),

              ElevatedButton(
                  onPressed: ()
                  {
                  validateForm();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurpleAccent,
                  ),
                  child: const Text(
                    "Giriş Yap",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )),
              TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));

                  },
                   child: const Text(
                "Bir hesabın yok mu? Buradan Üye Ol",
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
