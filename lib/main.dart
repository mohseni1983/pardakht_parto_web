import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pardakht_parto/UI/cust_colors.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:pardakht_parto/classes/internet_package.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
import 'package:pardakht_parto/pages/charge.dart';
import 'package:pardakht_parto/pages/donation.dart';
import 'package:pardakht_parto/pages/ghobooz.dart';
import 'package:pardakht_parto/pages/internet_package.dart';
import 'package:pardakht_parto/pages/into.dart';
import 'package:pardakht_parto/pages/main_page.dart';
import 'package:pardakht_parto/pages/notifications.dart';
import 'package:pardakht_parto/pages/profile.dart';
import 'package:pardakht_parto/pages/recipt.dart';
import 'package:pardakht_parto/pages/registeration.dart';
import 'package:pardakht_parto/pages/support.dart';
import 'package:pardakht_parto/pages/test.dart';
import 'package:pardakht_parto/pages/wallet.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links2/uni_links.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  print('Handling a background message ${message.notification.body}');
  //Navigator.of(context).p
}


const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);
/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
void main() async {

  String token_fcm='';
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


  await Firebase.initializeApp().timeout(Duration(seconds: 30));
  /*inal FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Set the background messaging handler early on, as a named top-level function
  try {
    _firebaseMessaging
        .getToken()
        .then((value) => debugPrint('This is token: ${value}'));
  } catch (e) {
    debugPrint('Error=====> ${e.toString()}');
  }*/
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);



  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  try{
    String _token=await FirebaseMessaging.instance.getToken();
    //debugPrint('Toooooooooooooooooooooooooooooooooken::::::::::::::::::::: $_token');
    SharedPreferences.getInstance().then((value) {
      value.setString('fcmKey', _token);
    });

  }catch (e){
    debugPrint('EEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRRRRRRROOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO::::$e');
  }




  await SentryFlutter.init(
          (options) {
        options.dsn = 'https://87a232be89fe4af1beb7a10c5be27cef@o502350.ingest.sentry.io/5635538';
      },

  appRunner: () {
        runApp(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: PColor.orangeparto,
              backgroundColor: Color.fromRGBO(233, 233, 233, 1),
              primaryColor: PColor.orangeparto,
              accentColor: PColor.blueparto,
              fontFamily: 'IRANSans(FaNum)',
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide(color: PColor.orangeparto,style: BorderStyle.solid,width: 2.0),
                ),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey,style: BorderStyle.solid,width: 3.0)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: PColor.blueparto,style: BorderStyle.solid,width: 2.0)
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: PColor.orangeparto,style: BorderStyle.solid,width: 2.5)
                ),
                fillColor: PColor.orangepartoAccent,
                focusColor: PColor.orangepartoAccent.shade200,
                hoverColor: PColor.orangepartoAccent.shade400,
                filled: true,
                contentPadding: EdgeInsets.fromLTRB(25, 1, 25, 1),
              ),
              textTheme: TextTheme(
                  caption: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                    color: PColor.blueparto,
                  ),
                  subtitle1: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                    color: PColor.blueparto,
                  ),
                  headline1: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: PColor.blueparto,
                  )
              )

          ),
          routes: {
            '/intro':(context)=>IntroPage(),
            '/':(context)=>MainPage(),
            '/register':(context)=>RegisterationPage(),
            '/bill':(context)=>BillsPage(),
            '/charge': (context)=>ChargeWizardPage(),
            '/internet':(context)=>InternetPackagePage(),
            '/wallet':(context)=>WalletPage(),
            '/profile':(context)=>ProfilePage(),
            '/donation':(context)=>DonationPage(),
            '/notifications':(context)=>NotificationsPage(),
            //ReciptPage.routeName:(context)=>ReciptPage(key: Key(Random(10000).toString()),)
            //'/test':(context)=>TestPage()
            '/support':(context)=>SupportPage()

          },
          initialRoute:
          '/intro',
          // home:value? new MainPage():new RegisterationPage(),
        )
        );

      }
    //appRunner: () => runApp(new MainPage(),),

  );
}



