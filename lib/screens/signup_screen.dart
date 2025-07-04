import 'package:attendance/screens/login_page.dart';
import 'package:attendance/widgets%20and%20%20functions/sign_up_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? _selectedRole;
  TextEditingController username_c=TextEditingController();
  TextEditingController user_id_c=TextEditingController();
  TextEditingController email_c=TextEditingController();
  TextEditingController pass_1=TextEditingController();
  TextEditingController pass_2=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        
          height: double.maxFinite,
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                height: 160,
                decoration: const BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                  )
                ),
                child: Container(
                  padding: const EdgeInsets.only(left: 10,top: 20),
                  child: Column(
        
                    children: [
                      Container(
                  alignment: Alignment.topLeft,
                        child: Text(
                          "Sign up ",
                          style: GoogleFonts.roboto(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
        
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Empower Your Attendance",
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
        
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 250,
                height: 220,
                child: Lottie.asset(
                  'local_items/signup_ani.json', // Path to your animation file
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 20,),
              Padding(
                padding:const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    hint: const Text('    Choose a role'),
                    items: <String>['Employee', 'Admin'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
        
                    },
                  ),
                ),
              ),
              const SizedBox(height: 7,),
        
              Text_fiels("User Name",username_c),
              Text_fiels('User Id', user_id_c),
              Text_fiels("Email",email_c),
              Text_fiels("Password",pass_1),
              Text_fiels("Confirm Password",pass_2),
        
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: const BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius:BorderRadius.all(Radius.circular(20))
                ),
                width: double.maxFinite,
                height: 40,
                child: TextButton(onPressed: (){
                  String username=username_c.text.trim();
                  String user_id=user_id_c.text.trim();
                  String email=email_c.text.trim();
                  String pass1=pass_1.text.trim();
                  String pass2=pass_2.text.trim();
                  registerUser(
                      username: username,
                    user_id: user_id,
                    email: email,
                    password1:pass1,
                    password2: pass2,
                    context: context,
                    role: _selectedRole??""
        
                  );
                }, child: const Text("Sign-up",style: TextStyle(color: Colors.white),)),
              ),
        
              TextButton(onPressed: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
              }, child: const Text("Login?"))
        
            ],
          ),
        ),
      ),
    );
  }
}
