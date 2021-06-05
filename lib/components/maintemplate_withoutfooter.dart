import 'dart:convert';

import 'package:adobe_xd/pinned.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/pages/main_page.dart';
import 'package:pardakht_parto/pages/profile.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';

import '../main.dart';
import 'TopWallet.dart';
// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}
class MasterTemplateWithoutFooter extends StatefulWidget {
  final Widget wchild;

  final bool isHome;



  const MasterTemplateWithoutFooter({Key key,  this.wchild,this.isHome=false}) : super(key: key);
  @override
  _MasterTemplateState createState() => _MasterTemplateState();
}
class _MasterTemplateState extends State<MasterTemplateWithoutFooter> with TickerProviderStateMixin{
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
          showDialog(context: context, builder:(context) => CAlertDialog(
            content: 'پیام',
            subContent: message.toString(),
          ),);

      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      showDialog(context: context, builder:(context) => CAlertDialog(
        content: 'پیام',
        subContent: message.toString(),
      ),);

    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Directionality(textDirection: TextDirection.rtl,
          child:       Scaffold(
            //backgroundColor: const Color(0xffe9e9e9),
            // backgroundColor: Colors.red,
            body: Stack(
              children: <Widget>[
                Container(
                  //color: Colors.blueAccent,
                  margin: EdgeInsets.only(left:10,top:160,right:10,bottom: 0),

                  child: widget.wchild,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width>340 ?200.0:160,
                  child: Stack(
                    children: [
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 375.0, 200.0),
                        size: Size(375.0, 200.0),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: SvgPicture.string(
                          _svg_mq30wu,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 375.0, 200.0),
                        size: Size(375.0, 200.0),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: SvgPicture.string(
                          _svg_2rup1j,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 375.0, 200.0),
                        size: Size(375.0, 200.0),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: SvgPicture.string(
                          _svg_30ph6e,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Pinned.fromSize(
                        bounds: Rect.fromLTWH(0.0, 0.0, 375.0, 200.0),
                        size: Size(375.0, 200.0),
                        pinLeft: true,
                        pinRight: true,
                        pinTop: true,
                        pinBottom: true,
                        child: SvgPicture.string(
                          _svg_jyq2pk,
                          allowDrawingOutsideViewBox: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                          right: 0,
                          top: 100,
                          child: GestureDetector(
                            onTap:()=> Navigator.of(context).pop(),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                                color: PColor.blueparto.withOpacity(0.5),
                              ),
                              height: 30,
                              width: 40,

                              child: Icon(Icons.arrow_forward,color: Colors.white,),
                            ),
                          )),


                      Center(child: Container(
                        height: 120,
                        width: 140,
                        child: WalletWidget(),
                      ),)
                    ],
                  ),
                ),




              ],
            ),
          )
      );


  }

}
const String _svg_mq30wu =
    '<svg viewBox="0.0 0.0 375.0 200.0" ><path transform="translate(1903.0, 2890.0)" d="M -1902.700317382813 -2690.000244140625 L -1902.700561523438 -2690.000244140625 L -1902.999633789063 -2690.000244140625 L -1902.999633789063 -2890 L -1528.000244140625 -2890 L -1528.000244140625 -2690.29638671875 C -1587.228271484375 -2715.314453125 -1650.143798828125 -2728 -1715.00048828125 -2728 C -1780.109130859375 -2728 -1843.260375976563 -2715.215087890625 -1902.7001953125 -2690.000244140625 L -1902.700317382813 -2690.000244140625 L -1902.700561523438 -2690.000244140625 L -1902.700317382813 -2690.000244140625 Z" fill="#e07243" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_2rup1j =
    '<svg viewBox="0.0 0.0 375.0 200.0" ><path transform="translate(2133.0, 2890.0)" d="M -1758.30029296875 -2690.000244140625 L -1758.30029296875 -2690.29638671875 C -1817.527587890625 -2715.314453125 -1880.44384765625 -2728 -1945.300537109375 -2728 C -2010.409301757813 -2728 -2073.560546875 -2715.215576171875 -2133 -2690.000244140625 L -2133 -2740.299560546875 L -1945.500366210938 -2890 L -1757.999755859375 -2740.29931640625 L -1757.999755859375 -2690.000244140625 L -1758.30029296875 -2690.000244140625 Z" fill="#ffffff" fill-opacity="0.2" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_30ph6e =
    '<svg viewBox="0.0 0.0 375.0 200.0" ><path transform="translate(2100.0, 2890.0)" d="M -2099.999755859375 -2690.000244140625 L -2099.999755859375 -2757.60595703125 L -1911.999633789063 -2890 L -1725.000366210938 -2758.310302734375 L -1725.000366210938 -2690.29638671875 C -1784.228393554688 -2715.314453125 -1847.144775390625 -2728 -1912.00048828125 -2728 C -1977.109252929688 -2728 -2040.260498046875 -2715.215576171875 -2099.699951171875 -2690.000244140625 L -2099.999755859375 -2690.000244140625 Z" fill="#ffffff" fill-opacity="0.2" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jyq2pk =
    '<svg viewBox="0.0 0.0 375.0 200.0" ><path transform="translate(2196.0, 2890.0)" d="M -1820.998168945313 -2689.99853515625 L -1821.00048828125 -2689.99853515625 L -1821.30029296875 -2690.000244140625 L -1821.30029296875 -2690.29638671875 C -1880.52783203125 -2715.314208984375 -1943.443969726563 -2728 -2008.300537109375 -2728 C -2073.408935546875 -2728 -2136.56005859375 -2715.215087890625 -2196 -2690.000244140625 L -2008.500366210938 -2890 L -1820.999755859375 -2690.000244140625 L -1820.998168945313 -2689.99853515625 Z" fill="#e9e9e9" fill-opacity="0.2" stroke="none" stroke-width="1" stroke-opacity="0.2" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_houo9n =
    '<svg viewBox="0.0 0.0 375.0 62.0" ><defs><filter id="shadow"><feDropShadow dx="0" dy="-2" stdDeviation="6"/></filter></defs><path transform="translate(2187.0, 2890.0)" d="M -2187 -2827.999755859375 L -2187 -2890 L -2044.746948242188 -2890 C -2046.241821289063 -2885.329833984375 -2047.000610351563 -2880.451904296875 -2047.000610351563 -2875.5 C -2047.000610351563 -2849.308349609375 -2025.692138671875 -2827.999755859375 -1999.500366210938 -2827.999755859375 C -1973.30859375 -2827.999755859375 -1952.000122070313 -2849.308349609375 -1952.000122070313 -2875.5 C -1952.000122070313 -2880.450927734375 -1952.7587890625 -2885.328857421875 -1954.253784179688 -2890 L -1812.000610351563 -2890 L -1812.000610351563 -2827.999755859375 L -2187 -2827.999755859375 Z" fill="#e07243" stroke="#26445d" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" filter="url(#shadow)"/></svg>';
