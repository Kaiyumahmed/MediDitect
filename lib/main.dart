import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MaterialApp(
    title: 'MediDitect',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: true, 
    ),
    home: LeafApp(),
  ));
}

class LeafApp extends StatefulWidget {
  @override
  _LeafAppState createState() => _LeafAppState();
}

class _LeafAppState extends State<LeafApp> {
  File? _image;
  List<Map<String, dynamic>>? _recognitions;
  String _statusMessage = 'Select a leaf from camera or gallery to start.';
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() { _loading = false; });
    });
  }

  // 1. LOAD THE MODEL
  Future loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/leaf_model.tflite");
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // 2. OPEN CAMERA OR GALLERY & PICK IMAGE
  Future pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;
    
    setState(() {
      _loading = true;
      _image = File(pickedFile.path);
      _recognitions = null;
      _statusMessage = 'Analyzing image...';
    });
    classifyImage(_image!);
  }

  // NEW: Reset the screen for another scan
  void clearImage() {
    setState(() {
      _image = null;
      _recognitions = null;
      _statusMessage = 'Select a leaf from camera or gallery to start.';
    });
  }

  // 3. RUN THE AI (INFERENCE)
  Future classifyImage(File image) async {
    try {
      final imageBytes = image.readAsBytesSync();
      img.Image? originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        setState(() {
          _loading = false;
          _statusMessage = 'Failed to decode image.';
        });
        return;
      }
      
      img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);
      
      final input = List.generate(
        1, (_) => List.generate(
          224, (_) => List.generate(
            224, (_) => List.filled(3, 0.0),
          ),
        ),
      );

      int greenPixelCount = 0;
      int totalPixels = 224 * 224;

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          int r = pixel.r.toInt();
          int g = pixel.g.toInt();
          int b = pixel.b.toInt();

          // Green Filter Logic
          if (g > r + 15 && g > b + 15) {
            greenPixelCount++;
          }

          input[0][y][x][0] = r / 255.0;
          input[0][y][x][1] = g / 255.0;
          input[0][y][x][2] = b / 255.0;
        }
      }

      double greenRatio = greenPixelCount / totalPixels;

      // Reject non-green objects immediately
      if (greenRatio < 0.02) {
        setState(() {
          _loading = false;
          _recognitions = [
            {"label": "No Leaf Detected", "confidence": 0.0}
          ];
          _statusMessage = 'Please ensure a green leaf is clearly visible.';
        });
        return; 
      }

      final output = List.generate(1, (_) => List.filled(5, 0.0));
      _interpreter.run(input, output);

      final labels = await loadLabels();
      final scores = output[0];
      final predictions = List.generate(scores.length, (index) {
        final label = index < labels.length ? labels[index] : 'Class $index';
        return {"label": label, "confidence": scores[index]};
      });
      predictions.sort((a, b) => (b["confidence"] as double).compareTo(a["confidence"] as double));
      
      double highestConfidence = predictions.first["confidence"] as double;
      double threshold = 0.80; 

      setState(() {
        _loading = false;
        if (highestConfidence < threshold) {
          _recognitions = [
            {"label": "Unknown Object", "confidence": 0.0}
          ];
          _statusMessage = 'Leaf is unclear or not recognized.';
        } else {
          _recognitions = predictions.take(3).toList();
          _statusMessage = 'Detection complete.';
        }
      });

    } catch (e) {
      print("Error classifying image: $e");
      setState(() {
        _loading = false;
        _recognitions = null;
        _statusMessage = 'Detection failed. Please try another image.';
      });
    }
  }
  
  Future<List<String>> loadLabels() async {
    try {
      final labelsData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      return labelsData.split('\n').where((line) => line.isNotEmpty).toList();
    } catch (e) {
      print("Error loading labels: $e");
      return ["Unknown"];
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  // 4. THE UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Upgraded App Logo Icon
            Icon(Icons.eco_rounded, color: Colors.green[800], size: 28),
            SizedBox(width: 8),
            Text('MediDitect', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900])),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Medicinal Leaf Detector',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green[900]),
                ),
                SizedBox(height: 8),
                Text(
                  'Take a fresh photo or choose a leaf from your gallery to identify the plant.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Text(
                  _statusMessage,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[800]),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: _loading
                      ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
                      : Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: _image != null
                                      ? Image.file(_image!, fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.green[50],
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Upgraded Empty State Icon
                                                Icon(Icons.energy_savings_leaf_rounded, size: 72, color: Colors.green[300]),
                                                SizedBox(height: 16),
                                                Text(
                                                  'No leaf selected yet',
                                                  style: TextStyle(fontSize: 18, color: Colors.green[900], fontWeight: FontWeight.w600),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Use camera or gallery to start.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            if (_recognitions != null && _recognitions!.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Upgraded Prediction Header Icon
                                        Icon(Icons.biotech_rounded, color: Colors.green[800]),
                                        SizedBox(width: 8),
                                        Text('Prediction Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900])),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    ..._recognitions!.map((result) {
                                      double conf = result['confidence'] as double;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${result['label']}',
                                                style: TextStyle(
                                                  fontSize: 18, 
                                                  fontWeight: FontWeight.w600,
                                                  color: conf == 0.0 ? Colors.red[700] : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (conf > 0.0)
                                              Text(
                                                '${(conf * 100).toStringAsFixed(1)}%',
                                                style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
                                    SizedBox(height: 8),
                                    Divider(color: Colors.green[100], height: 1),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Try another leaf', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                        TextButton.icon(
                                          // NEW: Properly resets the state instead of forcing the gallery
                                          onPressed: clearImage,
                                          // Upgraded Reset/Retry Icon
                                          icon: Icon(Icons.restart_alt_rounded, color: Colors.green[700]),
                                          label: Text('Reset', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => pickImage(ImageSource.camera),
                        // Upgraded Camera Icon
                        icon: Icon(Icons.camera_alt_rounded, color: Colors.white),
                        label: Text('Camera', style: TextStyle(color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.green[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => pickImage(ImageSource.gallery),
                        // Upgraded Gallery Icon
                        icon: Icon(Icons.photo_library_rounded, color: Colors.green[900]),
                        label: Text('Gallery', style: TextStyle(color: Colors.green[900], fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.green[100],
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}