import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uprint/main.dart';
import 'package:uprint/uploadFile.dart';
import 'userDashboard.dart';

class Dashboard extends StatefulWidget {
  String username;
  String accessToken;
  // const Dashboard({Key? key}) : super(key: key);

  Dashboard(this.username, this.accessToken);
  @override
  State<Dashboard> createState() =>
      _DashboardState(this.username, this.accessToken);
}

class _DashboardState extends State<Dashboard> {
  String username;
  String accessToken;

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController trxIDController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();

  _DashboardState(this.username, this.accessToken);
  bool _isLoggedIn = false;
  List<Post> _posts = [];
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _fetchPosts();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<bool> _logout() async {
    return await showDialog(
      context: context,
      builder:(_) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',style: TextStyle(color: Colors.blueGrey),),
          ),
          TextButton(
            onPressed: () async {
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
            },
            child: Text('Logout',style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  // var balance = 0 ;
  List<dynamic> _previousRequests = [];
  double balance = 0.0;
  String email = '';
  int phone_number = 0;

  // Future<void> fetchPreviousRequests() async {
  //   var url = Uri.parse('https://example.com/previous-requests');
  //   var response = await http.get(url);
  //
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _previousRequests = jsonDecode(response.body);
  //     });
  //   }
  // }

  Future<void> _fetchPosts() async {
    print(username);
    String url = 'https://www.uprintbd.com/mobileUserDashboard';
    // String url = 'http://192.168.0.110:5000/mobileUserDashboard';
    var headers = {
      'Authorization': 'Bearer $accessToken',
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        var requests = jsonDecode((response.body));
        _previousRequests = requests[0];
        print(_previousRequests);
        if (_previousRequests == []){
          _previousRequests = [{'file_name': "null"},{'cost': 0.0},{"otp_number":"none"}];
        }
        // var balance = jsonData((response.body[1]));
        // print(balance);
        balance = requests[1][0]['balance'];
        try{
          email = requests[1][0]['email'];
        }
        catch (e){
          email = "not provided";
        }

        phone_number = requests[1][0]['phone_number'];
        print(_previousRequests);
        print(balance);
        print(email);
        print(phone_number);
        // _posts = List<Post>.from(jsonData.map((post) => Post.fromJson(post)));
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
    return WillPopScope(
      onWillPop: _logout ,
      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Hello $username'),
          centerTitle: true,
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {

                _logout();
              },
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
        body: SizedBox.expand(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 50),
                color: Colors.white,
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Center(
                    child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Reamining Print Queue",
                                    style: TextStyle(
                                        fontSize: 25, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: _previousRequests.isEmpty
                                    ?FutureBuilder(
                                  future: Future.delayed(Duration(seconds: 3)),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else {
                                      return ElevatedButton(onPressed: _refresh, child: Text("Refresh"),style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),);
                                    }
                                  },
                                )
                                    :Expanded(
                                  child: SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: DataTable(
                                      headingRowColor: MaterialStateProperty.resolveWith(
                                              (states) => Colors.black26
                                      ),
                                      // columnSpacing: 1,
                                      columns: [
                                        DataColumn(label: Text('Print Requests')),
                                        // DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Cost')),
                                        DataColumn(label: Text('OTP')),
                                      ],
                                      rows: _previousRequests.map((request) {
                                        print(request['printing_status']);
                                        return DataRow(cells: [
                                          DataCell(Text('${request['file_name']}')),
                                          DataCell(Text('${request['cost']}')),
                                          // DataCell(Text('${request['printing_status']}')),
                                          DataCell(Text('${request['otpNumber']}')),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(150),
                              ),


                              child: Center(
                                child: Icon(Icons.image,color: Colors.white,)
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                            color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Name: $username",
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.email),
                                        Text(
                                          '   $email',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.phone),
                                        Text(
                                          '   $phone_number',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(

                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Center(
                          child: Text(
                            'Your Current Balance: $balance tk',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Previous Printing files',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add balance',
                        style:
                            TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        TextSpan(
                          text:
                              "Welcome to our add balance page! We are glad you've chosen to add balance to your account. This page will allow you to quickly and easily add funds to your account, so you can continue to enjoy all the features and benefits of our service. To add balance, first send the amount to ",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: '+8801521327804 ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            TextSpan(
                              text: 'by using',
                            ),
                            TextSpan(
                              text: ' Bkash ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            TextSpan(
                              text:
                                  "and fill the form and click the 'Submit' button. Your account balance will be updated within a few minutes. Thank you for choosing our service and enjoy!",

                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        maxLength: 11,
                        controller: phoneNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bkash Phone Number',
                          hintText: 'Enter the Bkash Number',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          hintText: 'Enter your amount',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: trxIDController,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Id',
                          hintText: 'Put your 10 character transaction ID',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: submitTransaction,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 18),
                            textStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20,right: 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Submit your comments, feedbaack or any suggestions about the device",style:
                      TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),
                      SizedBox(height: 20),
                      TextField(
                        controller: feedbackController,
                        maxLines: 6,
                        minLines: 4,
                        // maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Leave your comment here',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: submitFeedback,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 18),
                            textStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
            child: GNav(
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.green,
              padding: EdgeInsets.all(20),
              gap: 10,
              onTabChange: (index) {
                _pageController.jumpToPage(index);
              },
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: "Dashboard",
                ),
                GButton(
                  icon: Icons.person_2_rounded,
                  text: "Profile",
                ),
                GButton(
                  icon: Icons.monetization_on_sharp,
                  text: "Transaction",
                ),
                GButton(icon: Icons.feedback,text: "Feedback",)
              ],
            ),
          ),
        ),
      ),
    );
  }
  void submitFeedback() async{
    final feedback = feedbackController.text;
    // String url = "http://192.168.0.110:5000/mobileFeedback";
    String url = 'https://www.uprintbd.com/mobileFeedback';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': "Bearer $accessToken"},
      body: {'feedback': feedback},
    );
    print(response.statusCode);
    if (response.statusCode==200){
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your feedback has been submitted'),
            content: Text('We appreciate your advice. Your feedback is valuable to us and will help us continue improving our product.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                child: Text('OK',style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
    }
  }

  void submitTransaction() async{
    final phone_number = phoneNumberController.text;
    final amount = amountController.text;
    final trxID = trxIDController.text;
    // String url = 'http://192.168.0.110:5000/mobileUserTransaction';
    String url = 'https://wwww.uprintbd.com/mobileUserTransaction';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': "Bearer $accessToken"},
      body: {'phone_number': phone_number, 'amount': amount, 'trxID':trxID},
    );

    print(response.statusCode);
    if(response.statusCode==200){
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Successful'),
            content: Text('Our sales team will verify your transaction and add balance soon .'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                child: Text('OK',style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
    }else{
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Transaction unsuccessful'),
            content: Text('Please check your internet connection and try it again'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                child: Text('OK',style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
    }
  }
}
