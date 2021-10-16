import 'dart:convert';
//import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pardakht_parto/components/reg_page_template.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform, exit;
import 'package:http/http.dart' as http;
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_textfield.dart';
import 'package:pardakht_parto/pages/enter_otp.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;

class RegisterationPage extends StatefulWidget {
  @override
  _RegisterationPageState createState() => _RegisterationPageState();
}

class _RegisterationPageState extends State<RegisterationPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _progressing = false;
  TextEditingController _mobile = new TextEditingController();
 // DeviceInfoPlugin plugin = new DeviceInfoPlugin();
  String _deviceId = '---';
  int os_id = 0;
  TextEditingController _referrer = new TextEditingController();
  bool _hasRef = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
/*    try {
      if (Platform.isAndroid) {
        plugin.androidInfo.then((value) {
          setState(() {
            _deviceId = value.androidId;
            os_id = 1;
          });
          debugPrint(value.androidId);
        });
      } else if (Platform.isIOS) {
        plugin.iosInfo.then((value) {
          setState(() {
            _deviceId = value.identifierForVendor;
            os_id = 2;
          });
          debugPrint(value.identifierForVendor);
        });
      }
    } on PlatformException {
      setState(() {
        _deviceId = 'Error';
      });
    }*/
    setState(() {
      os_id=3;
      _deviceId='test_id_for_web';

    });
    _prefs.then((value) {
      var _sign = value.getString('sign');

      if (value.containsKey('token'))
        auth.checkAuth().then((value) {
          if (value)
            setState(() {
            });
        });
    });
  }

  Future<void> sendMobileNumber() async {
    setState(() {
      _progressing = true;
    });
    var _cellNumber = _mobile.text.substring(1, 11);
    var _devId = _deviceId;
    var result = await http
        .post(Uri.parse('${globalVars.srvUrl}/Api/Charge/Register'), body: {
      "CellNumber": _cellNumber,
      "DeviceKey": _devId,
      "Os": "$os_id",
      "Referral": _referrer.text
    });
    if (result.statusCode == 200) {
      var res = json.decode(result.body);
      if (res['ResponseCode'] == 0)
        _prefs.then((value) {
          value.setString('username', _cellNumber);
          value.setString('device_id', _devId);
          value.setInt('os', os_id);
          setState(() {
            _progressing = false;
          });
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => EnterOTP()));
        });
      else {
        setState(() {
          _progressing = false;
        });

        showDialog(
          context: context,
          builder: (context) => CAlertDialog(
            content: res['ResponseMessage'],
            buttons: [
              CButton(
                label: 'قبول',
                onClick: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      }
    } else {
      setState(() {
        _progressing = false;
        showDialog(
          context: context,
          builder: (context) => CAlertDialog(
            content: 'خطای سرور ${result.statusCode}',
            subContent: 'خطا در برقراری ارتباط با سرور',
            buttons: [
              CButton(
                onClick: () {
                  Navigator.of(context).pop();
                },
                label: 'بستن',
              )
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: ModalProgressHUD(
              child: RegPageTemplate(
                children: [
                  Text(
                    'برای ورود یا ثبت نام شماره همراه خود را وارد کنید',
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                  CTextField(
                    textAlign: TextAlign.center,
                    controller: _mobile,
                    maxLenght: 11,
                    keyboardType: TextInputType.phone,
                  ),
                  Padding(padding: EdgeInsets.only(top: 3)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _hasRef = !_hasRef;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      height: 50,
                      decoration: BoxDecoration(
                        color: PColor.orangepartoAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _hasRef
                          ? Row(
                        children: [
                          Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'شماره موبایل معرف',
                                    // counter: ,
                                    counterText: ''
                                  //counter: Stage

                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.phone,
                                maxLength: 11,
                                controller: _referrer,
                              )),
                          IconButton(
                              icon: Icon(
                                Icons.close,
                                color: PColor.blueparto,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hasRef = !_hasRef;
                                });
                              })
                        ],
                      )
                          : Text(
                        'معرف دارم',
                        style: TextStyle(color: PColor.blueparto),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 3)),
                  CButton(
                    onClick: () {
                      if (_mobile.text.length == 11 && _mobile.text.startsWith('09'))
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CAlertDialog(
                              content: 'آیا از صحت شماره همراه وارد شده اطمینان دارید؟',
                              subContent: '${_mobile.text}',
                              buttons: [
                                CButton(
                                  onClick: () {
                                    Navigator.of(context).pop();
                                  },
                                  label: 'ویرایش',
                                  minWidth: 120,
                                ),
                                CButton(
                                  onClick: () {
                                    sendMobileNumber();
                                    Navigator.of(context).pop();
                                  },
                                  label: 'ادامه',
                                  minWidth: 120,
                                ),
                              ],
                            );
                          },
                        );
                      else
                        showDialog(
                          context: context,
                          builder: (context) => CAlertDialog(
                            content: 'خطا',
                            subContent: 'شماره موبایل وارد شده صحیح نیست',
                            buttons: [
                              CButton(
                                label: 'اصلاح',
                                onClick: () => Navigator.of(context).pop(),
                              )
                            ],
                          ),
                        );
                    },
                    label: 'ورود',
                    minWidth: 120,
                  ),
                ],
              ),
              inAsyncCall: _progressing,
            )), onWillPop: _onWillPop)
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
