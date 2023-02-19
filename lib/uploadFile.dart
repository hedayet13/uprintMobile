import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class UploadFile extends StatefulWidget {
  String accessToken;
  // const UploadFile(String accessToken, {Key? key}) : super(key: key);
  UploadFile(this.accessToken);

  @override
  State<UploadFile> createState() => _UploadFileState(this.accessToken);
}

class _UploadFileState extends State<UploadFile> {
  String accessToken;
  _UploadFileState(this.accessToken);
  File?file;
  @override
  Widget build(BuildContext context) {
    final filename = file!=null? basename(file!.path): "No file Selected";

    return Scaffold(
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: selectFile,
              child: Text('        Select File       '),
            ),
            SizedBox(width: 20),
            Text(filename),
            SizedBox(width: 20,),// add some spacing between the buttons
            ElevatedButton(
              onPressed: (){
                _uploadFile();
              },
              child: Text('Upload File'),
            ),
          ],
        ),
      ),

    );
  }
  Future selectFile() async{
    print("working");
    // print(accessToken);
    final result  = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf'],allowMultiple: false);

    if(result != null) {
      final path = result.files.single.path!;
      // final path = result.files.single.path!;
      print(path);
      setState(()=> file =File(path));
      // print(file);
    } else {
      // User canceled the picker
    }

  }
  Future<void> _uploadFile() async {
    // if (file == null) return;
    print(accessToken);
    // print(file!.path);
    // final filepath = await http.MultipartFile.fromPath('file', file!.path);
    var headers = {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY3NjgyOTM3MiwianRpIjoiMDliMjkyNWUtOWJmMi00MWJiLTk3NjEtZWY0NGM4NTFiYjVhIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImFkbWluIiwibmJmIjoxNjc2ODI5MzcyLCJleHAiOjE2NzY4MzAyNzJ9.kyTmcgnerQzo3KpkcyvyoXBX1MT2ufPJUnW_mQDxUOo',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('http://127.0.0.1:5000/protected'));
    request.body = json.encode({
      "data": "Text"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }
  //
  // Future<void> _uploadFile() async {
  //   if (file == null) return;
  //   print(file!.path);
  //   print(accessToken);
  //   final url = 'http://192.168.0.110:5000/uploader';
  //   final request = http.MultipartRequest('POST', Uri.parse(url));
  //   request.headers['Authorization'] = 'Bearer $accessToken';
  //   request.files.add(await http.MultipartFile.fromPath('pdf', file!.path));
  //   final response = await request.send();
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     print('File Uploaded');
  //   } else {
  //     print('Error uploading file');
  //   }
  // }


}
