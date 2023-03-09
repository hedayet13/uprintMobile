import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:uprint/notificationservice/local_notification_service.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:uprint/dashboard.dart';
import 'package:uprint/registration.dart';
import 'package:http/http.dart' as http;
import 'package:uprint/userDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  LocalNotificationService.initialize();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  bool isloading = false;
  String deviceTokenToSendPushNotification = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();

    FirebaseMessaging.instance.getInitialMessage().then(
          (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
          (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);

        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );
  }

  Future<void> _onBackgroundMessage() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceTokenToSendPushNotification = token.toString();
    // print("deviceToken  $deviceTokenToSendPushNotification");
    // Show a local notification or update the UI
  }
  void checkLogin() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? val = await pref.getString('login');
    if (val!= null){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> Dashboard()), (route) => false);
    }
  }

  Widget build(BuildContext context) {
    _onBackgroundMessage();
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to uPrint",
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: !_showPassword,
              controller: passwordController,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      icon: _showPassword
                          ? Icon(Icons.visibility_outlined)
                          : Icon(Icons.visibility_off_outlined))),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 60, right: 60),
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isloading = true;
                  });
                  login();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                child: isloading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Transform.scale(scaleX:0.5, scaleY:0.8,child:CircularProgressIndicator(color: Colors.red,)),
                          CircularProgressIndicator(
                            color: Colors.pinkAccent,
                          ),
                          Text(
                            "   logging in",
                            style: TextStyle(color: Colors.pink),
                          )
                        ],
                      )
                    : Text('Login'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "or,",
              style: TextStyle(fontSize: 20),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text(
                'Create an account',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login() async {
    final username = usernameController.text;
    final password = passwordController.text;
    print(username);
    print(password);
    String url = 'https://www.uprintbd.com/mobileLogin';
    // String url = 'http://192.168.0.110:5000/mobileLogin';
    final response = await http.post(
      Uri.parse(url),
      body: {'username': username, 'password': passwordController.text},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      // print()
      final data = json.decode(response.body);
      final accessToken = data['access_token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('login', accessToken);
      await prefs.setString('username', username);
      // await prefs.setString('username', username);
      print("Login token is: ${accessToken}");
      if (data['success']) {
        // Navigate to home screen
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Dashboard()),
        );
      } else {}

      // print(accessToken);
      return accessToken;
    } else {
      setState(() {
        isloading = false;
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
  }
}
