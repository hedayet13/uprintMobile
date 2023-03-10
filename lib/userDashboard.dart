import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uprint/main.dart';
import 'package:uprint/uploadFile.dart';

class UserDashboard extends StatefulWidget {
  String username;
  String accessToken;
  // UserDashboard( {Key? key, required this.email}) : super(key: key);
  UserDashboard(this.username, this.accessToken);
  @override
  State<UserDashboard> createState() =>
      _UserDashboardState(this.username, this.accessToken);
}

class _UserDashboardState extends State<UserDashboard> {
  String username;
  String accessToken;
  _UserDashboardState(this.username, this.accessToken);
  bool _isLoggedIn = false;
  List<Post> _posts = [];


  // String email => email;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => MyHomePage(
                title: "good",
              )),
      (route) => false,
    );
  }

  Future<void> _fetchPosts() async {
    print(username);
    // String url = 'https://uprintbd.com/mobileUserDashboard/';
    String url = 'http://192.168.0.110:5000/mobileUserDashboard';
    var headers = {
      'Authorization': 'Bearer $accessToken',
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        _posts = List<Post>.from(jsonData.map((post) => Post.fromJson(post)));
      });
    } else {
      throw Exception('Failed to fetch posts from serer');
    }
  }

  Future<void> _refresh() async {
    // Call the _fetchData() method to reload data from the server
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome " + username),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print(accessToken);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UploadFile(accessToken)));
        },
        label: const Text("Upload PDF"),
        icon: const Icon(Icons.picture_as_pdf_sharp),
        backgroundColor: Colors.pink,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _posts.isEmpty
            ? ListView(
          children: [
            Center(child: Text("No Print Queue")),
          ],
        )
            : Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Previous Print Requests'),
                Text('Cost'),
                Text("Printing Status"),
                Text('OTP'),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (BuildContext context, int index) {
                  final post = _posts[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(post.file_name),
                      Text(post.cost),
                      Text(post.print_status),
                      Text(post.otpNumber),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        // currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        // onTap: _onItemTapped,
      ),
    );
  }
}

class Post {
  final int id;
  final String file_name;
  final String file_location;
  final String cost;
  final String print_status;
  final String otpNumber;
  final String remaining_time;

  Post(
      {required this.id,
      required this.file_name,
      required this.file_location,
      required this.cost,
      required this.print_status,
      required this.otpNumber,
      required this.remaining_time});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        file_name: json['file_name'],
        file_location: json['file_location'],
        cost: json['cost'],
        print_status: json['print_status'],
        otpNumber: json['otpNumber'],
        remaining_time: json['remaining_time']);
  }
}
