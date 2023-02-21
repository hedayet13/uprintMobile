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
  File? file;
  bool isLoadUploading = false;
  String uploadFilename = "none";
  @override
  Widget build(BuildContext context) {
    final filename = file != null ? basename(file!.path) : "No file Selected";

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: selectFile,
              child: Text('        Select File       '),
            ),
            SizedBox(width: 40),
            Text(filename),
            SizedBox(
              height: 20,
            ), // add some spacing between the buttons
            Container(
              padding: EdgeInsets.only(left: 80, right: 80),
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
                ),
                onPressed: () {
                  setState(() {
                    isLoadUploading = true;
                  });
                  _uploadFile();
                },
                child: isLoadUploading? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20,),
                    Text("uploading . . .",style: TextStyle(fontSize: 18),)
                  ],
                ):Text('Upload File', style: TextStyle(fontSize: 18),),
              ),
            ),
            SizedBox(height: 20,),
            Text(uploadFilename,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }

  Future selectFile() async {
    print("working");
    // print(accessToken);
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false);

    if (result != null) {
      final path = result.files.single.path!;
      // final path = result.files.single.path!;
      print(path);
      setState(() => file = File(path));
      // print(file);
    } else {
      // User canceled the picker
    }
  }

  Future<void> _uploadFile() async {
    if (file == null) {
      print("No file selected");
    } else {
      print(file!.path);
      print(accessToken);
      final url = 'https://www.uprintbd.com/mobileUploader';
      // final url = 'http://192.168.0.110:5000/mobileUploader';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));
      final response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('File Uploaded');
        setState(() {
          isLoadUploading = false ;
          var isfilename = basename(file!.path);
          uploadFilename = "$isfilename uploaded";
        });
        // Text("done");
      } else {
        setState(() {
          isLoadUploading = false;
        });
        print('Error uploading file');
      }
    }
  }
}
