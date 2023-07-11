// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Python Integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic result;

  @override
  void initState() {
    super.initState();
  }

  _processImage(String imagePath) async {
    try {
      final pythonScript = '''
import cv2
import numpy as np
import json

def find_contours(image_path):
    image = cv2.imread(image_path)
    hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    blue_lower = np.array([80, 65, 65])
    blue_upper = np.array([150, 255, 255])
    blue_mask = cv2.inRange(hsv_image, blue_lower, blue_upper)
    kernel = np.ones((5, 5), np.uint8)
    blue_mask = cv2.morphologyEx(blue_mask, cv2.MORPH_OPEN, kernel)
    contours_blue, _ = cv2.findContours(blue_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    row_counts = {}
    for contour in contours_blue:
        area = cv2.contourArea(contour)
        if area > 2 * 1000:
            x, y, w, h = cv2.boundingRect(contour)
            cv2.rectangle(image, (x, y), (x+w, y+h), (0, 255, 0), 2)
            row = int(y / h)
            row_counts[row] = row_counts.get(row, 0) + 1

    row_count_json = json.dumps(row_counts)
    return row_count_json

result = find_contours('$imagePath')
print(result)
''';

      final tempDir = await getTemporaryDirectory();
      final scriptFile = File('${tempDir.path}/script.py');
      await scriptFile.writeAsString(pythonScript);

      final process = await Process.run('python', [scriptFile.path]);
      final stdout = process.stdout as String;
      final stderr = process.stderr as String;

      final trimmedOutput = stdout.trim();
      print("jgJGASJ KJHSAKHS => ${trimmedOutput}");
      if (trimmedOutput.isNotEmpty) {
        // final outputMap = json.decode(trimmedOutput);
        return trimmedOutput;
      } else {
        print('Python script output is empty');
      }

      if (stderr.isNotEmpty) {
        print('Python script error: $stderr');
      }
    } catch (e) {
      print('Error executing Python script: $e');
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              setState(() {
                result = _processImage("assets/images/1.jpeg");
              });
              print(result);
            },
            child: Text('Click to process'),
          ),
          result != Null ? Text(result.toString()) : Text("Not processed")
        ],
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
