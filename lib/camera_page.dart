import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:motivateme_mobile_app/model/subgoal.dart';
import 'package:motivateme_mobile_app/service/goal_manager.dart';

class CameraPage extends StatefulWidget {
  final SubGoal subGoal;

  CameraPage({Key key, this.subGoal}) : super(key: key);

  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
          future: availableCameras(),
          builder: (BuildContext context,
              AsyncSnapshot<List<CameraDescription>> snapshot) {
            print(snapshot.data);

            if (snapshot.hasData) {
              final firstCamera = snapshot.data.first;
              _controller = CameraController(
                firstCamera,
                ResolutionPreset.medium,
              );
              _initializeControllerFuture = _controller.initialize();
              return FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Container(height: 0, width: 0),
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DisplayPictureScreen(
                            imagePath: image?.path,
                            subGoal: widget.subGoal,
                          ))).then((value) {
                            print('camera page value: ' + value.toString());
                            if(value == true) {
                              Navigator.pop(context, true);
                            }
                          });
            } catch (e) {
              print(e);
            }
          }),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final goalManager = GoalManager();
  final SubGoal subGoal;

  DisplayPictureScreen({Key key, this.imagePath, this.subGoal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(children: [
            Container(
                color: Colors.black,
                child: Image.file(File(imagePath), scale: 0.25)),
            //  height: MediaQuery.of(context).size.height / 2,
            //  width: MediaQuery.of(context).size.width / 2)),
            Expanded(
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red)),
                      child:
                          Text('Retry', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        Navigator.pop(context, false);
                      })),
              Expanded(
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green)),
                      child:
                          Text('Submit', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        Directory appDocDirectory =
                            await getApplicationDocumentsDirectory();
                        String formattedGoalTitle =
                            this.subGoal.title.replaceAll(' ', '_');
                        Directory(
                                appDocDirectory.path + '/' + formattedGoalTitle)
                            .create(recursive: true)
                            .then((Directory directory) async {
                          File subGoalPicture = new File(imagePath);
                          String subGoalPicturePath = directory.path +
                              '/' +
                              formattedGoalTitle +
                              this.subGoal.gid.toString() +
                              '.jpg';
                          subGoalPicture.copy(subGoalPicturePath);
                          print('Path of new dir: ' + directory.path);
                          goalManager.savePicturePath(
                              this.subGoal, subGoalPicturePath);
                        });
                        print('picture saved!!!');
                        // Navigator.popUntil(context, ModalRoute.withName('/'));
                        Navigator.pop(context, true);
                      })),
            ])),
          ]),
        ));
  }
}
