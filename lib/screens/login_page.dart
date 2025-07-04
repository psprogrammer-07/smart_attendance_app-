import 'package:attendance/screens/signup_screen.dart';
import 'package:attendance/widgets%20and%20%20functions/login_funcitons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:lottie/lottie.dart';

import '../widgets and  functions/sign_up_functions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email_c=TextEditingController();
  TextEditingController pass_c=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(


          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                height: 160,
                decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                    )
                ),
              ),
              Container(
                width: 275,
                height: 275,
                child: Lottie.asset(
                  'local_items/signup_ani.json', // Path to your animation file
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20,),

              SizedBox(height: 20,),

              Text_fiels("Email",email_c),
              Text_fiels("Password",pass_c),


              SizedBox(height: 10,),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius:BorderRadius.all(Radius.circular(20))
                ),
                width: double.maxFinite,
                height: 60,
                child: TextButton(onPressed: (){

                  String email=email_c.text.trim();
                  String pass=pass_c.text.trim();
                  loginUser(email, pass, context);
                }, child: Text("Login",style:
                  TextStyle(
                    color: Colors.white,
                  )
                  ,)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("You Not Have an account?",style: TextStyle(fontSize: 13),),
                  TextButton(onPressed: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen(),));

                  }, child: Text("Register",style: TextStyle(fontSize: 12),),
                  )
                ],
              ),




            ],
          ),
        ),
      ),
    );
  }
}
