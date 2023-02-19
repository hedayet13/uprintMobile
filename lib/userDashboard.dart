import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uprint/main.dart';

class UserDashboard extends StatefulWidget {
  String username;
  // UserDashboard( {Key? key, required this.email}) : super(key: key);
  UserDashboard(this.username);
  @override
  State<UserDashboard> createState() => _UserDashboardState(this.username);
}

class _UserDashboardState extends State<UserDashboard> {
  String username;
  _UserDashboardState(this.username);
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
      MaterialPageRoute(builder: (context) => MyHomePage(title: "good",)),
          (route) => false,
    );
  }

  Future<void> _fetchPosts() async {
    print(username);
    final response = await http.get(Uri.parse('http://192.168.0.110:5000/mobileUserDashboard/'+username));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      setState(() {
        _posts = List<Post>.from(jsonData.map((post) => Post.fromJson(post)));
      });
    } else {
      throw Exception('Failed to fetch posts from serer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Dashboard"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),

      body: _posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          :Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Previous Print Requests'),
              Text('Cost'),
              Text ("Printing Status"),
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


  Post({required this.id,required this.file_name, required this.file_location, required this.cost, required this.print_status,required this.otpNumber, required this.remaining_time });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      file_name: json['file_name'],
      file_location: json['file_location'],
      cost: json['cost'],
      print_status: json['print_status'],
      otpNumber: json['otpNumber'],
      remaining_time: json['remaining_time']
    );
  }
}