import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);
const IOSNotificationDetails iosChannel = IOSNotificationDetails(
  presentAlert:
  true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
  presentBadge:
  true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
  presentSound:
  true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
  // sound: String?,  // Specifics the file path to play (only from iOS 10 onwards)
  // badgeNumber: int?, // The application's icon badge number
  // attachments: List<IOSNotificationAttachment>?, (only from iOS 10 onwards)
  // subtitle: String?, //Secondary description  (only from iOS 10 onwards)
  // threadIdentifier: String? (only from iOS 10 onwards)
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class PushNotifcationService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  /// this is must in IOS
  getPermissions() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {
    }
  }

  Future initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    getPermissions();
    var initialzationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification:
          (int value, String value1, String value2, String payload) {},
    );
    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) {
          if (payload != null) {
            manageNotification(jsonDecode(payload));
          }
        });
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // FirebaseMessaging.instance.getInitialMessage();

    /// This will be triggered when app is running.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = getNotificationData(message);

      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      AppleNotification apple = message.notification?.apple;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ),
            payload: jsonEncode(data));
      } else if (notification != null && apple != null) {
        const NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: iosChannel);
        flutterLocalNotificationsPlugin.show(notification.hashCode,
            notification.title, notification.body, platformChannelSpecifics,
            payload: jsonEncode(data));
      }
    });

    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    /// This callback will be triggered when app is in background and user taps on the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final data = getNotificationData(message);
      manageNotification(data);
    });
  }

  ///On signin this method is to let the user join the room according to the role.
  // static Future<void> joinRooms() async {
  //   AuthProvider authProvider = sl();
  //   if (authProvider.currentUser!.selectedUserType == '1') {
  //     await firebaseMessaging.subscribeToTopic('drivers');
  //   } else {
  //     await firebaseMessaging.subscribeToTopic('passengers');
  //   }
  // }

  /// On logging out , this method is to let user leave the room.
  // static Future<void> leaveRooms() async {
  //   AuthProvider authProvider = sl();
  //   if (authProvider.currentUser!.selectedUserType == '1') {
  //     await firebaseMessaging.unsubscribeFromTopic('drivers');
  //   } else {
  //     await firebaseMessaging.unsubscribeFromTopic('passengers');
  //   }
  // }

  /// This will work when will be in background whether it is in use or not
  static Future<void> backgroundHandler(RemoteMessage message) async {
    final data = getNotificationData(message);
    PushNotifcationService().manageNotification(data);

  }

  ///To get device specific notifcation
  Future<String> getToken() async {
    String token = await firebaseMessaging.getToken();
    return token;
  }

  ///This method will be triggered if app is killed and an user click on notification
  void checkNewStartApp() {
    firebaseMessaging.getInitialMessage().then((RemoteMessage message) {
      if (message != null) {
        final data = getNotificationData(message);
        manageNotification(data);
      }
    });
  }

  // to get notification data from notification
  static Map<String, dynamic> getNotificationData(message) {
    if (Platform.isAndroid) {
      return message.data;
    } else {
      return message.data;
    }
  }

  manageNotification(Map<String, dynamic> data) {


    // AuthProvider authProvider = sl();
    //
    // /// if not logged in then return;
    // if (authProvider.currentUser == null) {
    //   return;
    // }
    // /// if notification for specific role defined is notification data is not equal to current user's data then return.
    // if(data['role']!=authProvider.currentUser!.selectedUserType){
    //   return;
    // }
    //
    // if (data['name'] == 'rideRequest') {
    //   ManageNotification.manageRequestNotification(data);
    // } else if (data['name'] == 'acceptedRequest') {
    //   ManageNotification.manageAcceptedRequestNotificaition(data);
    // } else if (data['name'] == 'startedRide') {
    //   ManageNotification.manageStartRideNotification(data);
    // } else if (data['name'] == 'passengerRideStatus') {
    //   ManageNotification.managePassengerRideStatusNotification(data);
    // }else if (data['name'] == 'newDriverMatch') {
    //   ManageNotification.manageNewMatchedDriverFoundNotification(data);
    // }else if (data['name'] == 'confirmationByPassenger') {
    //   ManageNotification.manageNewMatchedDriverFoundNotification(data);
    // }
  }

  sendNotification({@required String token,@required String body})async{
    var postUrl = "https://fcm.googleapis.com/fcm/send";


      print('token : $token');

      final data = {

        "notification": {"body": body, "title": "New notification!"},
        "priority": "high",

        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
        },
        "to": "$token"
      };

      final key='AAAAmgp81Us:APA91bFFZP0s9WP-nTBxR4wiUul0j0c4i3T8YTjp5d2Go0xbmjJ5atxyDwOCU_fknsyvfi6vOXboQPaI1fFUeuebHYdPth5mF_0ArkafN1Yly_qg8oNSoyUZeM_nN2VlXveJUK28mzXx';
      final headers = {
        'content-type': 'application/json',
        'Authorization': 'key=$key'
      };


      BaseOptions options = new BaseOptions(
        connectTimeout: 5000,
        receiveTimeout: 3000,
        headers: headers,
      );


      try {
        final response = await Dio(options).post(postUrl,
            data: data);

        if (response.statusCode == 200) {
          print("send");
        } else {
          print('notification sending failed');
          // on failure do sth
        }
      }
      catch(e){
        print('exception $e');
      }





  }
}
