import 'dart:io';
import 'package:flutter/material.dart';
// TFLite Library Import
import "package:tflite/tflite.dart";
// Import Image Picker
import "package:image_picker/image_picker.dart";

// Main Class
void main(){
  runApp(MaterialApp(
    // Don't show the Debug Banner on the App
    debugShowCheckedModeBanner: false,
    // Set App Theme
    theme: ThemeData.dark(),
    // App Home Page
    home: HomePage(),
  ));
}

// Stateful Widget for App Home Page
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Boolean to see if page is loading and show Circular Progress Indicator
  bool _isloading = false;
  // Image File
  File _image;
  // Output: Model Prediction
  List _output;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Set the Loading Flag to True
    _isloading = true;
    // Load TFLite Model by calling the loadModel function
    loadModel().then((value) {
      setState(() {
        // If model has loaded, stop the CircularProgressIndicator
        _isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Classification using TFLite"),
      ),
      // If the Model is Loading, show the CircularProgressIndicator
      body: _isloading ?  Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ) : Container(
        // Else, if model is loaded, show the image and prediction
        // Using column here as Image and Prediction show in same line
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Show the Image if available
            _image == null ? Container() : Image.file(_image),
            SizedBox(height: 16,),
            // Show the Output Label if available
            _output == null ? Text("") : Text(
              "${_output[0]["label"]}"
            )
          ],
        ),
      ),
      // Define the Image Picker Button to choose the Image
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // Choose the Image
          chooseImage();
        },
      ),
    );
  }

  // Function to load TFLite Model
  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  // Function to Choose Image using ImagePicker
  chooseImage() async{
    // Choose the image
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _isloading = true;
      _image = image;
    });
    classifyImage(image);
  }

  // Function to Make Inference for the Captured Image
  classifyImage(File image) async{
    // Run Model on Image
    var output = await Tflite.runModelOnImage(
      path: image.path,
      // Number of Outputs
      numResults: 2,
      // Accuracy Threshold
      threshold: 0.5,
      // Image Mean and Standard Deviation
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isloading = false;
      _output = output;
    });
  }
}
