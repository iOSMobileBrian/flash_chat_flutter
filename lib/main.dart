import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';



void main(){

  WidgetsFlutterBinding.ensureInitialized();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  // Create the initilization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print("error: something went wrong");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(

            initialRoute:WelcomeScreen.id ,
            routes: {
              WelcomeScreen.id: (context) => WelcomeScreen(),
              ChatScreen.id: (context) => ChatScreen(),
              RegistrationScreen.id: (context) => RegistrationScreen(),
              LoginScreen.id: (context) => LoginScreen(),

            },
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Loading(indicator: BallPulseIndicator(),size: 100.0,color: Colors.red,);
      },
    );
  }
}











