import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_otp/home.dart';
import 'package:login_otp/otp.dart';
import 'package:login_otp/phone.dart';

import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'phone',
    routes: {
      'phone':(context)=>MyPhone(),
      'otp':(context)=>MyOtp(),
      'home':(context)=>MyHome()
    }
  )
  );
}

