import "dart:io";
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  // FilePickerResult? result;
  // String? _fileName;
  // PlatformFile? pickedfile;
  // bool isLoading=false;
  // File? fileToDisplay;
  String? _filePath;
  String? predicted;
  String prediction='';
  int flag=0;
  int flag1=0;

  final audioPlayer=AudioPlayer();
  bool isPlaying=false;
  Duration duration=Duration.zero;
  Duration position=Duration.zero;

  final audioPlayer1=AudioPlayer();
  bool isPlaying1=false;
  Duration duration1=Duration.zero;
  Duration position1=Duration.zero;

  @override
  void initState(){
    super.initState();
    //setAudio();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying=state==PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration=newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position=newPosition;
      });
    });
    audioPlayer1.onPlayerStateChanged.listen((state1) {
      setState(() {
        isPlaying1=state1==PlayerState.playing;
      });
    });
    audioPlayer1.onDurationChanged.listen((newDuration1) {
      setState(() {
        duration1=newDuration1;
      });
    });
    audioPlayer1.onPositionChanged.listen((newPosition1) {
      setState(() {
        position1=newPosition1;
      });
    });
  }

  @override
  void dispose(){
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Future<void> uploadAudio(File audioFile) async {
    //final url = 'http://10.0.2.2:5000/predict'; // Change this to your Flask back-end URL
    final url = 'http://34.228.69.120:80/predict';
    var request = await http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    setState(() {
      prediction = responseData;
    });
    debugPrint(responseData);
  }
  Future<void> pickFile() async {
    FilePickerResult? result=await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if(result!=null){
      PlatformFile file=result.files.first;
      setState(() {
        _filePath=file.path;
        flag1=1;
      });
      // _fileName=result!.files.first.name;
      // pickedfile=result!.files.first;
      //fileToDisplay=File(pickedfile!.path.toString() as List<Object>);
      //print('File name $_fileName');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Predictor'),
        // ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:<Widget>[
                ElevatedButton(
                  child: Text('Pick File'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ), onPressed: pickFile,
                ),
                SizedBox(height: 10,),
                _filePath != null
                    ? Text('Selected file: $_filePath')
                    : Text('No file selected'),
                SizedBox(height: 10,),
                flag1==1?Column(
                  children: [
                    Slider(
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey,
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position=Duration(seconds: value.toInt());
                        await audioPlayer.seek(position);
                        await audioPlayer.resume();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Text(formatTime(position)),
                            Text(formatTime(duration)),
                          ]
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 35,
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause:Icons.play_arrow,
                        ),
                        iconSize: 50,
                        onPressed: () async {
                          if(isPlaying){
                            await audioPlayer.pause();
                          }else{
                            // await audioPlayer.resume();
                            File audioFile=File(_filePath??"");
                            await audioPlayer.play(UrlSource(audioFile.path));
                          }
                        },
                      ),
                    ),
                  ],
                ):Text(''),
                SizedBox(height: 30,),
                ElevatedButton(onPressed: ()async{
                  await uploadAudio(File(_filePath??""));
                  flag=1;
                }, child: Text('Predict'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                prediction!=''?Text('Prediction : $prediction'):Text(''),
                SizedBox(height: 10,),
                flag==1?Column(
                  children: [
                    Slider(
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey,
                      min: 0,
                      max: duration1.inSeconds.toDouble(),
                      value: position1.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position1=Duration(seconds: value.toInt());
                        await audioPlayer1.seek(position1);
                        await audioPlayer1.resume();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Text(formatTime(position1)),
                            Text(formatTime(duration1)),
                          ]
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 35,
                      child: IconButton(
                        icon: Icon(
                          isPlaying1 ? Icons.pause:Icons.play_arrow,
                        ),
                        iconSize: 50,
                        onPressed: () async {
                          if(isPlaying1){
                            await audioPlayer1.pause();
                          }else{
                            // await audioPlayer.resume();
                            //File audioFile=File(_filePath??"");
                            await audioPlayer1.play(AssetSource('$prediction.wav'));
                          }
                        },
                      ),
                    ),
                  ],
                ):Text(''),
                SizedBox(height: 20,),
                ElevatedButton(
                  child: Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ), onPressed: (){
                  Navigator.pushNamed(context, 'phone');
                },
                ),
              ],
            ),
          ),
          // child: SizedBox(
          //     height: 50,
          //     width: 300,
          //     child: ElevatedButton(
          //       child: Text('Pick File'),
          //       style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.green,
          //           shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(10)
          //           )
          //       ), onPressed: pickFile,
          //     ),
          // ),
        )
    );
  }

  // Future setAudio() async {
  //   audioPlayer.setReleaseMode(ReleaseMode.LOOP);
  //   File audioFile=File(_filePath??"");
  //   await audioPlayer.setUrl(audioFile.path);
  //
  // }
}