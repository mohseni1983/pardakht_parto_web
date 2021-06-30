import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pardakht_parto/components/maintemplate.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/pages/recipt.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:pardakht_parto/classes/wallet.dart';
import 'package:uni_links2/uni_links.dart';

bool _initialUriIsHandled = false;
/// To verify things are working, check out the native platform logs.


class MainPage extends StatefulWidget {

  final bool isCallback;

  const MainPage({Key key, this.isCallback=false}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}
enum UniLinksType { string, uri }

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{

  Uri _initialUri;
  Uri _latestUri;
  Object _err;
  StreamSubscription _sub;
  String _test='0';

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri uri) {
        if (!mounted) return;
        print('got uri: $uri');


        setState(() {
          _latestUri = uri;
          _err = null;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => ReciptPage(url: uri.toString(),key: Key(Random(10000).toString()),),));
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;

      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReciptPage(url: uri.toString(),key: Key(Random(10000).toString()),),));
        }
        if (!mounted) return;
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
      }
    }
  }



  bool _hasMessage=false;

  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    setState(() {
      _test="Checking";
    });
    if (initialMessage != null) {
      setState(() {
        _test='TRUE';
      });
Navigator.of(context).pushNamed('/notifications');
    }else{
      setState(() {
        _test="FALSE";
      });
    }
  }


  @override
  void didUpdateWidget(MainPage oldWidget) {
    setWalletAmount(this);
    setState(() {
    });
  }
  //final NavigationService _navigationService = locator<NavigationService>();
  @override
  void initState() {
    // TODO: implement initState
    checkForInitialMessage();

    setWalletAmount(this);
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();
    FirebaseMessaging.onMessage.listen((event) {
      showDialog(context: context, builder: (context) {
        return CAlertDialog(
          content: '${event.notification.title}',
          subContent: '${event.notification.body}',
          buttons: [CButton(
            minWidth: 60,

            label: 'بستن',
            onClick: (){
              Navigator.of(context).pop();
            },
          ),
            CButton(
              label: 'پیام ها',
              minWidth: 60,
              onClick: (){
                Navigator.of(context).pushNamed('/notifications');
              },
            ),

          ],
        );
      },);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {

        showDialog(context: context, builder: (context) {
          return
            CAlertDialog(
            content: '${event.notification.title}',
            subContent: '${event.notification.body}',
            buttons: [
              CButton(
              label: 'بستن',
              minWidth:60,
              onClick: (){
                Navigator.of(context).pop();
              },
            ),
              CButton(
                label: 'پیام ها',
                minWidth:60,
                onClick: (){
                  Navigator.of(context).pushNamed('/notifications');
                },
              ),

            ],
          );
        },);

    });
/*
    FirebaseMessaging.onBackgroundMessage((message) =>
    Navigator.of(context).pushNamed('/notifications')
    );
*/


  }
  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
          child: MasterTemplate(
            hasMessage: _hasMessage,
              isHome: true,
              wchild: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                padding:
                EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 50),
                children: [
                  MainIcon(
                    label: 'شارژ سیم کارت',
                    image: AssetImage('assets/images/charge.png'),
                      onPress: ()=>Navigator.of(context).pushNamed('/charge')
                  ),
                  MainIcon(
                    label: 'بسته اینترنت',
                    image: AssetImage('assets/images/4GPackages.png'),
                    onPress: ()=>Navigator.of(context).pushNamed('/internet')
                  ),
                  MainIcon(
                    label: 'قبوض خدماتی',
                    image: AssetImage('assets/images/ghobooz3.png'),
                      onPress: ()=>Navigator.of(context).pushNamed('/bill')
                  ),
                  MainIcon(
                    label: 'نیکوکاری',
                    image: AssetImage('assets/images/donation2.png'),
                      onPress: ()=>Navigator.of(context).pushNamed('/donation')
                  ),
                 // Text('$_test')




                ],
              )),
          onWillPop: () => _onWillPop())

    ;
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
            context: context,
            builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: Text('آیا اطمینان دارید؟'),
                    content: Text('آیا می خواهید از اپ خارج شوید'),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('خیر'),
                      ),
                      FlatButton(
                        onPressed: () {
                          exit(0);
                        },
                        child: Text('بلی'),
                      ),
                    ],
                  ),
                )) ??
        false;
  }
}


class MainIcon extends StatefulWidget {
  final String label;
  final AssetImage image;
  final VoidCallback onPress;

  const MainIcon({Key key, this.label, this.image, this.onPress}) : super(key: key);
  @override
  _MainIconState createState() => _MainIconState();
}

class _MainIconState extends State<MainIcon> {
  @override
  Widget build(BuildContext context) {
    return                 GestureDetector(
      onTap: widget.onPress,
      child: Container(


          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.width/3,
                width: MediaQuery.of(context).size.width/3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:widget.image,
                      fit: BoxFit.contain

                  )
                ),
              ),
              Text('${widget.label}',style: TextStyle(color: PColor.blueparto),textScaleFactor: 1.1,),
            ],
          )
      ),
    );

  }
}



