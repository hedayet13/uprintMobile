import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uprint/main.dart';
import 'package:uprint/userDashboard.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phone_numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirm_passwordController = TextEditingController();

  bool isLoadingRegistration =false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Registration'),
      // ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Register Now!!",
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50,),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Your Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              maxLength: 11,
              keyboardType: TextInputType.number,
              controller: phone_numberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number(Whatsapp)',
                hintText: 'Enter your Whatsapp Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirm_passwordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 60,right: 60),
              height:60,
              width: MediaQuery.of(context).size.width,

              child: ElevatedButton(
                onPressed: (){
                  setState(() {
                    isLoadingRegistration = true;
                  });
                  registration();

                },
                child: isLoadingRegistration? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green,),
                    Text("   prograssing",style: TextStyle(
                      color: Colors.green
                    ),)
                  ],
                ): Text('Register'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,

                    // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
            const SizedBox(height: 20,),
            const Text("or,",style: TextStyle(fontSize: 20),),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>const MyHomePage(title: "demo")),
                );
              },
              child: const Text('Already have an account?',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),),
            ),
          ],
        ),
      ),
    );

  }

  void registration() async {
    final username = usernameController.text;
    final phone_number = phone_numberController.text;
    final password = passwordController.text;
    final confirm_password =confirm_passwordController.text;

    if (password== confirm_password) {

      print(username);
      print(password);
      print(phone_number);
      // print(confirm_password);

      final response = await http.post(
        Uri.parse('https://www.uprintbd.com/mobileRegistration'),
        body: {'username': username,'phone_number':phone_number, 'password': password},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // print()
        final data = json.decode(response.body);
        if (data['success']) {
          print("Successfully registered");
          // Navigate to home screen
          // ignore: use_build_context_synchronously
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "sample")),);
        }
        else {

        }
      } else {
        setState(() {
          isLoadingRegistration = false;
        });
        print("error");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Login'),
              content: Text('You are not a valid user.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        // Show error message
      }
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Incorrect Password'),
            content: Text('Please Provide a valid password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }


  }
}