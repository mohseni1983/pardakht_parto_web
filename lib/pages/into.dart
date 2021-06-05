//import 'dart:html';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:flutter/services.dart';
import 'package:pardakht_parto/pages/recipt.dart';
import 'package:root_access/root_access.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/pages/main_page.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:package_info/package_info.dart';
import 'package:uni_links2/uni_links.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Future<SharedPreferences> _prefs=SharedPreferences.getInstance();
  bool isRoot=false;
  bool noInternet=false;
  bool useVpn=false;
  String _version='';
  String _latestLink = 'Unknown';
  UniLinksType _type = UniLinksType.string;



/*
  initPlatformState() async {
    if (_type == UniLinksType.string)
      await initPlatformStateForStringUniLinks();

  }
*/

/*
  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      print('got link: $link');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;
    Uri initialUri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
      if (initialLink!=null) initialUri = Uri.parse(initialLink);
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = initialLink;
    });
  }
*/



  //final FirebaseMessaging _firebaseMessaging;

   Future<bool> isDeviceRoot() async{
     if(Platform.isAndroid){
       return await RootAccess.rootAccess;
     }else
     return false;
   }

   Future<bool> isInternetConnected() async {
     var status= await Connectivity().checkConnectivity();
     if(status==ConnectivityResult.none){
       return false;
     }else{
       return true;
     }
   }

   Future<bool> isVpnConnected() async {
     return await CheckVpnConnection.isVpnActive();
   }
  Future<void> getInfo()async{
    final PackageInfo _info=await PackageInfo.fromPlatform();
    setState(() {
      _version='${_info.version}.${_info.buildNumber}';
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   /* initPlatformState();*/
    getInfo();
    isDeviceRoot().then((rooted) {
      if(rooted){
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return CAlertDialog(
              content: 'خطای مهم',
              subContent: 'گوشی شما دارای دسترسی روت می باشد. برای استفاده از اپ گپشی نباید روت باشد',
              buttons: [
                CButton(
                  label: 'خروج',
                  onClick: (){
                    exit(0);
                  },
                )
              ],
            );
          },
        ).then((value) => exit(0));
      }else{
        isVpnConnected().then((vpn) {
          if(vpn){
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return CAlertDialog(
                  content: 'خطای مهم',
                  subContent: 'شما در حال استفاده از VPN هستید. لطفا وی پی ان را قطع نمایید.',
                  buttons: [
                    CButton(
                      label: 'خروج',
                      onClick: (){
                        exit(0);
                      },
                    )
                  ],
                );
              },
            ).then((value) => exit(0));
          } else{
            isInternetConnected().then((connected) {
              if(!connected){
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  // false = user must tap button, true = tap outside dialog
                  builder: (BuildContext dialogContext) {
                    return CAlertDialog(
                      content: 'خطای مهم',
                      subContent: 'اتصال اینترنت گوشی برقرار نمی باشد.',
                      buttons: [
                        CButton(
                          label: 'خروج',
                          onClick: (){
                            exit(0);
                          },
                        )
                      ],
                    );
                  },
                ).then((value) => exit(0));

              }else{
                //_firebaseMessaging.requestNotificationPermissions();
              //  _firebaseMessaging.getToken().then((value) {
              //    debugPrint('Token FCB=$value');
                  _prefs.then((x) {
                    x.setString('fcmKey', 'debug');
                  });
          //      });
                auth.checkAuth().then((value) async {
                  // Future<SharedPreferences> _prefs=SharedPreferences.getInstance();
                  Future.delayed(Duration(seconds: 3)).then((s) {
                    if(value){
                     // debugPrint(_latestLink);
                      /*if(_latestLink!=null ){
                        if( !_latestLink.endsWith('Unknown')  )
                        {
                          debugPrint(_latestLink);
                          String link=_latestLink;
                          _latestLink=null;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ReciptPage(url: link,key: Key(Random(10000).toString()),),));
                        }}else*/
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage(),));
                    }else{
                      Navigator.of(context).pushReplacementNamed('/register');
                    }
                  });
                });
              }
            });
          }
        });
      }
    });



  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:       Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: PColor.orangeparto.shade200,
        child: Center(
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        alignment: Alignment.center,

                      )
                  ),
                ),
                Text('پرتو پرداخت'),
                Divider(indent: 90,endIndent: 90,thickness: 0.5,height: 1,),
                Text('نسخه:${_version}',textScaleFactor: 0.8,style: TextStyle(color: PColor.blueparto,fontWeight: FontWeight.bold),),


              ],
            )
        ),
      )
      ,
    );
  }
}
