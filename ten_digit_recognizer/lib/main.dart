// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DigitRecognizer(),
    );
  }
}

class DigitRecognizer extends StatefulWidget {
  @override
  _DigitRecognizerState createState() => _DigitRecognizerState();
}

class _DigitRecognizerState extends State<DigitRecognizer> {
  File? _image;
  String _result = "No prediction yet!";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Load the TFLite model
  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/my_model.tflite",
      labels: "assets/labels.txt",
    );
    print("Model loaded: $res");
  }

  // Pick an image using the camera
  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "Predicting...";
      });
      runModel(_image!);
    }
  }

  // Pick an image from the gallery
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "Predicting...";
      });
      runModel(_image!);
    }
  }

  // Run the model on the selected image
  Future<void> runModel(File image) async {
    setState(() {
      _loading = true;
    });

    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 10, // Assuming 10 digits (0-9)
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      if (output != null && output.isNotEmpty) {
        _result =
            "Prediction: ${output[0]['label']} (Confidence: ${output[0]['confidence'].toStringAsFixed(2)})";
      } else {
        _result = "No digit recognized!";
      }
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Handwritten Digit Recognizer"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _image == null
                ? Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text("No image selected"),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _image!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
            SizedBox(height: 20),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: pickImageFromCamera,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: pickImageFromGallery,
                  icon: Icon(Icons.photo_library),
                  label: Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            if (_loading) ...[
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ]
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'dart:io';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: DigitRecognizer(),
//     );
//   }
// }

// class DigitRecognizer extends StatefulWidget {
//   const DigitRecognizer({super.key});

//   @override
//   _DigitRecognizerState createState() => _DigitRecognizerState();
// }

// class _DigitRecognizerState extends State<DigitRecognizer> {
//   File? _image;
//   String _result = "No prediction yet!";
//   bool _loading = false;
//   late Interpreter _interpreter;

//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//   }

//   // Load the TFLite model
//   Future<void> loadModel() async {
//     // Load the model and assign the interpreter
//     _interpreter = await Interpreter.fromAsset('my_model.tflite');
//     print("Model loaded!");
//   }

//   // Pick an image using the camera
//   Future<void> pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _result = "Predicting...";
//       });
//       runModel(_image!);
//     }
//   }

//   // Pick an image from the gallery
//   Future<void> pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _result = "Predicting...";
//       });
//       runModel(_image!);
//     }
//   }

//   // Run the model on the selected image
//   Future<void> runModel(File image) async {
//     setState(() {
//       _loading = true;
//     });

//     // Load image and process it
//     var input = await _processImage(image);

//     // Run inference
//     var output = List.filled(1, List.filled(10, 0.0));
//     _interpreter.run(input, output);

//     setState(() {
//       _loading = false;
//       _result =
//           "Prediction: ${output[0][0].toStringAsFixed(2)}"; // Assuming a single prediction
//     });
//   }

//   // Preprocess image before feeding it to the model
//   Future<List<List<List<List<double>>>>> _processImage(File image) async {
//     // Here, you should add code to convert the image into a suitable input format
//     // for your model, e.g., resizing, normalizing, etc.
//     // For now, we'll use a placeholder. Modify this to suit your model's needs.

//     return List.filled(
//         1, List.filled(28, List.filled(28, List.filled(1, 0.0))));
//   }

//   @override
//   void dispose() {
//     _interpreter.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Handwritten Digit Recognizer"),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             _image == null
//                 ? Container(
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Center(
//                       child: Text("No image selected"),
//                     ),
//                   )
//                 : ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.file(
//                       _image!,
//                       height: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//             const SizedBox(height: 20),
//             Text(
//               _result,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: pickImageFromCamera,
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("Camera"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: pickImageFromGallery,
//                   icon: const Icon(Icons.photo_library),
//                   label: const Text("Gallery"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.greenAccent,
//                   ),
//                 ),
//               ],
//             ),
//             if (_loading) ...[
//               const SizedBox(height: 20),
//               const CircularProgressIndicator(),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }
