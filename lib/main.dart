import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/auth_screen.dart';
import 'package:flutter_complete_guide/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_complete_guide/services/push_notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotifcationService().initialize();
  runApp(MyApp());

}




class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(



      title: 'Flutter Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        backgroundColor: Colors.pink,
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.pink,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          )
        )
      ),

      home:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder:(context, userSnapshot) {
          if(userSnapshot.hasData) {
            return ChatScreen();
          }
          return AuthScreen();
        }),


    );
  }
}
