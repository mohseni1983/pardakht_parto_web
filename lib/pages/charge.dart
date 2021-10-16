import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:contact_picker/contact_picker.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/classes/topup.dart';
import 'package:pardakht_parto/classes/wallet.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_pre_invoice.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_buttonbar.dart';
import 'package:pardakht_parto/custom_widgets/cust_seletable_grid_item.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:url_launcher/url_launcher.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;

class ChargeWizardPage extends StatefulWidget {
  @override
  _ChargeWizardPageState createState() => _ChargeWizardPageState();
}

class _ChargeWizardPageState extends State<ChargeWizardPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _mobile = new TextEditingController();
  int _topUpOperator = -1;
  bool _progressing = false;
  String _paymentLink = '';
  bool _canUseWallet = false;
  double _walletAmount = 0;
  bool _readyToPay = false;
  String _invoiceTitle = '';
  String _invoiceSubTitle = '';
  double _invoiceAmount = 0;

  Widget Progress() => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: PColor.orangeparto.withOpacity(0.8),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                ),
                Text(
                  'در حال دریافت اطلاعات',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textScaleFactor: 1.4,
                )
              ],
            ),
          ),
        ),
      );

// List of mobile operator with color and grayscale images
  List<StraightChargeOperators> _operatorsWithLogo = [
    new StraightChargeOperators(
        id: 0,
        name: 'ایرانسل',
        colorImage: 'assets/images/mtn-color.jpg',
        grayImage: 'assets/images/mtn-gray.jpg',
        chargeTypes: [
          new ChargeTypesWithPrice(
              id: 0,
              name: 'معمولی',
              coverImage: '',
              prices: [10000, 20000, 50000, 100000, 200000]),
          new ChargeTypesWithPrice(
              id: 1,
              name: 'شگفت انگیز',
              coverImage: '',
              prices: [50000, 100000, 200000]),

          new ChargeTypesWithPrice(
              id: 11,
              name: 'اعتبار خط دائمی',
              coverImage: '',
              prices:  [10000, 20000, 50000, 100000, 200000])

        ]),
    new StraightChargeOperators(
        id: 1,
        name: 'همراه اول',
        colorImage: 'assets/images/mci-color.jpg',
        grayImage: 'assets/images/mci-gray.jpg',
        chargeTypes: [
          new ChargeTypesWithPrice(
              id: 0,
              name: 'معمولی',
              coverImage: '',
              prices: [10000, 20000, 50000, 100000, 200000]),
          new ChargeTypesWithPrice(
              id: 2,
              name: 'بانوان',
              coverImage: '',
              prices: [10000, 20000, 50000, 100000, 200000]),
          new ChargeTypesWithPrice(
              id: 3,
              name: 'جوانان',
              coverImage: '',
              prices: [10000, 20000, 50000, 100000, 200000])
        ]),
    new StraightChargeOperators(
        id: 3,
        name: 'رایتل',
        colorImage: 'assets/images/rightel-color.jpg',
        grayImage: 'assets/images/rightel-gray.jpg',
        chargeTypes: [
          new ChargeTypesWithPrice(
              id: 0,
              name: 'معمولی',
              coverImage: '',
              prices: [10000, 20000, 50000, 100000, 200000]),
          new ChargeTypesWithPrice(
              id: 1,
              name: 'شورانگیز',
              coverImage: '',
              prices: [10000, 20000, 50000, 100000, 200000]),
        ]),
    new StraightChargeOperators(
        id: 4,
        name: 'شاتل موبایل',
        colorImage: 'assets/images/shatel-color.jpg',
        grayImage: 'assets/images/shatel-gray.jpg',
        chargeTypes: [
          new ChargeTypesWithPrice(
              id: 0,
              name: 'معمولی',
              coverImage: '',
              prices: [10000, 20000, 50000, 100000, 200000])
        ])
  ];

  // for step of Stepper
  int _currentStep = 0;

  bool _inprogress = false;

//send to payment Api  *** most redefine
  void _sendToPayment() {
    TopUp _current = new TopUp();
    _prefs.then((value) {
      _current.sign = value.getString('sign');
      _current.amount = _selectedAmount;
      _current.chargeType = _selectedTopUpType;
      _current.cellNumber = _mobile.text.substring(1, 11);
      _current.deviceId = 0;
      _current.useWallet = false;
      _current.localDate = DateTime.now();
      _current.topUpOperator = _topUpOperator;
      _current.uniqCode = "";
    }).then((value) {
      setState(() {
        _progressing = true;
      });

      _payChargeWithCardAndSend(_current).then((value) {});
    });
  }

// List of master method of charging credit [مستقیم , کارت شارژ]
  List<String> _chargeTypes = ['شارژ مستقیم',/* 'کارت شارژ'*/];

  int _selectedAmount = 0;
  int _selectedChargeType = 0;
  int _selectedTopUpType = 0;

  //ویجت پرداخت
  int _selectedPaymentType = 1;

  Future<void> _payWithWallet() async {
    int _refIdIndex = _paymentLink.indexOf('?RefId=') + 7;
    String _refId = _paymentLink.substring(_refIdIndex);
    setState(() {
      _readyToPay = false;
      _progressing = true;
    });

    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String _token = _prefs.getString('token');
        var _body = {
          "ReferenceNumber": int.parse(_refId),
          "LocalDate": DateTime.now().toString(),
          "Sign": _prefs.getString('sign'),
          "UseWallet": true
        };
        var jBody = json.encode(_body);

        var result = await http.post(
            Uri.parse(('${globalVars.srvUrl}/Api/Charge/WalletApprove')),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jBody);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            _payWithWallet();
          });
        }
        if (result.statusCode == 200) {
          setState(() {
            _progressing = false;
          });

          await setWalletAmount(this);
          setState(() {});
          var jres = json.decode(result.body);
          if (jres["ResponseCode"] == 0)
            showDialog(
              context: context,
              builder: (context) => CAlertDialog(
                content: 'عملیات موفق',
                subContent:
                    'خرید شارژ با موفقیت انجام شد به زودی خط مورد نظر شارژ می‌شود. جهت اشتراک رسید به بخش تراکنش ها مراجعه نمایید. ',
                buttons: [
                  CButton(
                    label: 'بستن',
                    onClick: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            );
          else
            showDialog(
              context: context,
              builder: (context) => CAlertDialog(
                content: 'عملیات ناموفق',
                subContent: jres['ResponseMessage'],
                buttons: [
                  CButton(
                    label: 'بستن',
                    onClick: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            );
        }
      }
    });
  }

  Widget _paymentDialog() {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedPositioned(
          duration: Duration(seconds: 2),
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7 + 30,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width - 30,
                    padding: EdgeInsets.only(top: 5, left: 15, right: 15),
                    decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                        boxShadow: []),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              Text(
                                'تایید اطلاعات تراکنش',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textScaleFactor: 1.3,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'اطلاعات را مطالعه و پس از اطمینان پرداخت نمایید',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                                textScaleFactor: 0.8,
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                padding: EdgeInsets.all(12),
                                margin:
                                    EdgeInsets.only(top: 5, left: 0, right: 0),
                                decoration: BoxDecoration(
                                  color: PColor.blueparto.shade900,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'نام محصول:',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal),
                                          textScaleFactor: 1,
                                        ),
                                        Text(
                                          '${_invoiceTitle}',
                                          style: TextStyle(
                                              color: PColor.orangeparto,
                                              fontWeight: FontWeight.bold),
                                          textScaleFactor: 1,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'نوع محصول:',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal),
                                          textScaleFactor: 1,
                                        ),
                                        Text(
                                          '${_invoiceSubTitle}',
                                          style: TextStyle(
                                              color: PColor.orangeparto,
                                              fontWeight: FontWeight.bold),
                                          textScaleFactor: 1,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'شماره همراه:',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal),
                                          textScaleFactor: 1.2,
                                        ),
                                        Text(
                                          '${_mobile.text}',
                                          style: TextStyle(
                                              color: PColor.orangeparto,
                                              fontWeight: FontWeight.bold),
                                          textScaleFactor: 1.2,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'مبلغ پرداخت:',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal),
                                          textScaleFactor: 1.2,
                                        ),
                                        Text(
                                          '${getMoneyByRial(_invoiceAmount.toInt())} ریال',
                                          style: TextStyle(
                                              color: PColor.orangeparto,
                                              fontWeight: FontWeight.bold),
                                          textScaleFactor: 1.2,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'روش پرداخت',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textScaleFactor: 1.3,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'یکی از روش های پرداخت را انتخاب نمایید',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                                textScaleFactor: 0.8,
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                children: [
                                  CSelectedButton(
                                    label: 'کیف پول',
                                    height: 40,
                                    selectedColor: Colors.blue,
                                    selectedValue: _selectedPaymentType,
                                    value: 0,
                                    onPress: (v) {
                                      setState(() {
                                        _selectedPaymentType = v;
                                      });
                                    },
                                  ),
                                  CSelectedButton(
                                    label: 'کارت بانکی',
                                    selectedValue: _selectedPaymentType,
                                    selectedColor: Colors.blue,
                                    height: 40,
                                    value: 1,
                                    onPress: (v) {
                                      setState(() {
                                        _selectedPaymentType = v;
                                      });
                                    },
                                  )
                                ],
                              ),
                              _selectedPaymentType == 0
                                  ? Container(
                                      padding: EdgeInsets.all(12),
                                      margin: EdgeInsets.only(
                                          top: 5, left: 0, right: 0),
                                      decoration: BoxDecoration(
                                        color: PColor.blueparto.shade900,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'مانده کیف پول:',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                textScaleFactor: 1,
                                              ),
                                              Text(
                                                '${getMoneyByRial(_walletAmount.toInt())} ریال',
                                                style: TextStyle(
                                                    color: PColor.orangeparto,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textScaleFactor: 1,
                                              ),
                                            ],
                                          ),
                                          _walletAmount < _invoiceAmount
                                              ? Text(
                                                  'مبلغ ${getMoneyByRial(_invoiceAmount.toInt())} ریال با کارت بانکی پرداخت شود',
                                                  style: TextStyle(
                                                      color: PColor.orangeparto,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  textScaleFactor: 1,
                                                )
                                              : Container(
                                                  height: 0,
                                                ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: 0,
                                    ),
                            ],
                          ),
                        ),
                        Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _selectedPaymentType == 0 &&
                                      _walletAmount >= _invoiceAmount
                                  ? CButton(
                                      label: 'پرداخت با کیف پول',
                                      textScaleFactor: 0.8,
                                      onClick: () {
                                        _payWithWallet();
                                      },
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                    )
                                  : CButton(
                                      label: 'پرداخت با درگاه بانکی',
                                      onClick: () async {
                                        launch(_paymentLink).then((value) {
                                          setState(() {
                                            _readyToPay = false;
                                          });
                                          Navigator.of(context).popUntil(
                                              ModalRoute.withName('/'));
                                        });
                                      },
                                      color: Colors.redAccent,
                                      textColor: Colors.white,
                                    ),
                              Column(
                                children: [
                                  Text(
                                    'مبلغ قابل پرداخت',
                                    style: TextStyle(color: Colors.white70),
                                    textScaleFactor: 0.9,
                                  ),
                                  Text(
                                    ' ${getMoneyByRial(_invoiceAmount.toInt())} ریال',
                                    style: TextStyle(
                                        color: PColor.orangeparto,
                                        fontWeight: FontWeight.bold),
                                    textScaleFactor: 1.2,
                                  )
                                ],
                              )
                            ],
                          ),
                          //  color: Colors.red,
                        )
                      ],
                    ),
                  ),
                  Positioned(
                      top: 10,
                      child: GestureDetector(
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(150),
                              color: PColor.orangeparto),
                          child: Icon(
                            Icons.close,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _readyToPay = false;
                          });
                        },
                      ))
                ],
              ),
            ),
          ),
          bottom: _readyToPay
              ? 0
              : (MediaQuery.of(context).size.height * 0.7 + 30) * -1,
          right: 5,
          left: 5,
          curve: Curves.fastLinearToSlowEaseIn,
        ));
  }

//پایان ویجت پرداخت

  Future<void> _payChargeWithCard(TopUp topUp) async {
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _p = await SharedPreferences.getInstance();
        String _token = _p.getString('token');
        var jsonTopUp = topUpToJson(topUp);
        var result = await http.post(
            Uri.parse('${globalVars.srvUrl}/Api/Charge/TopUp'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jsonTopUp);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            _payChargeWithCard(topUp);
          });
        }
        if (result.statusCode == 200) {
          debugPrint(result.body);
          var jres = json.decode(result.body);
          setState(() {
            _progressing = false;
          });

          if (jres['ResponseCode'] == 0)
            showDialog(
              context: context,
              builder: (context) {
                return PreInvoice(
                  title:
                      '${_chargeTypes[_selectedChargeType]}  ${_operatorsWithLogo[_topUpOperator].name}',
                  subTitle:
                      '${_operatorsWithLogo[_topUpOperator].chargeTypes[_selectedTopUpType].name}',
                  amount: _selectedAmount.toDouble(),
                  canUseWallet: jres['CanUseWallet'],
                  paymentLink: jres['Url'],
                  walletAmount: 0,
                );
              },
            );
          else if (jres['ResponseCode'] == 5) {
            auth.retryAuth().then((value) {
              _payChargeWithCard(topUp);
            });
          } else
            showDialog(
              context: context,
              builder: (context) => CAlertDialog(
                subContent: jres['ResponseMessage'],
                buttons: [
                  CButton(
                    label: 'بستن',
                    onClick: () => Navigator.of(context).pop(),
                  )
                ],
                content: '',
              ),
            );
        }
      } else
        showDialog(
          context: context,
          builder: (context) => CAlertDialog(
            content: 'خطا در احراز هویت',
            buttons: [
              CButton(
                label: 'بستن',
                onClick: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
    });
  }

  Future<void> _payChargeWithCardAndSend(TopUp topUp) async {
    auth.checkAuth().then((value) async {
      if (value) {
        try {
          SharedPreferences _p = await SharedPreferences.getInstance();
          String _token = _p.getString('token');
          var jsonTopUp = topUpToJson(topUp);
          debugPrint(jsonTopUp.toString());
          var result = await http
              .post(Uri.parse('${globalVars.srvUrl}/Api/Charge/TopUp'),
                  headers: {
                    'Authorization': 'Bearer $_token',
                    'Content-Type': 'application/json'
                  },
                  body: jsonTopUp)
              .timeout(Duration(seconds: 20));
          if (result.statusCode == 401) {
            auth.retryAuth().then((value) {
              _payChargeWithCard(topUp);
            });
          }
          if (result.statusCode == 200) {
            debugPrint(result.body);
            var jres = json.decode(result.body);
            setState(() {
              _progressing = false;
            });

            if (jres['ResponseCode'] == 0) {
              setState(() {
                _invoiceTitle =
                    '${_chargeTypes[_selectedChargeType]}  ${_operatorsWithLogo[_topUpOperator].name}';
                _invoiceSubTitle =
                    '${_operatorsWithLogo[_topUpOperator].chargeTypes.firstWhere((element) => element.id == _selectedTopUpType).name}';
                _invoiceAmount = _selectedAmount.toDouble();
                _canUseWallet = jres['CanUseWallet'];
                _paymentLink = jres['Url'];
                _walletAmount = jres['Cash'];
                _readyToPay = true;
              });
            } else
              showDialog(
                context: context,
                builder: (context) => CAlertDialog(
                  content: 'خطای تراکنش',
                  subContent: jres['ResponseMessage'],
                  buttons: [
                    CButton(
                      label: 'بستن',
                      onClick: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              );
          }
        } on TimeoutException catch (e) {
          setState(() {
            _progressing = false;
          });
          showDialog(
            context: context,
            builder: (context) => CAlertDialog(
              content: 'خطای ارتباط',
              subContent: 'ارتباط با سرور برقرار نشد',
              buttons: [
                CButton(
                  label: 'بستن',
                  onClick: () => Navigator.of(context).pop(),
                )
              ],
            ),
          );
        } catch (exception, stackTrace) {
          await Sentry.captureException(
            exception,
            stackTrace: stackTrace,
          );
        }
      }
    });
  }

  Widget SinglePrices = Container(
    height: 0,
  );

  Widget Prices(int OperatorId, int TopUpId) {
    List<Widget> _widgets = [];
    if (OperatorId != -1 && TopUpId != -1) {
      var _list = _operatorsWithLogo[OperatorId]
          .chargeTypes
          .firstWhere((element) => element.id == TopUpId)
          .prices;
      var _x = _list.asMap();
      _x.forEach((key, value) {
        _widgets.add(
/*            CSelectedButton(
          height: 40,
          label: getMoneyByRial(value),
          selectedValue: _selectedAmount,
          onPress: (v) {
            setState(() {
              _selectedAmount = value;
            });
          },
          value: value,

        )*/
            CSelectedGridItem(
          height: 40,
          label: getMoneyByRial(value),
          selectedValue: _selectedAmount,
          onPress: (v) {
            setState(() {
              _selectedAmount = value;
            });
          },
          value: value,
        ));
      });
    }
    return GridView.count(
      mainAxisSpacing: 2,
      crossAxisCount: 3,
      childAspectRatio: 3,
      children: _widgets,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
    );
  }

  Widget ChargeTypes() {
    List<Widget> _list = [];
    var _x = _chargeTypes.asMap();
    _x.forEach((key, v) {
      _list.add(CSelectedButton(
        value: key,
        label: v,
        height: 40,
        selectedValue: _selectedChargeType,
        onPress: (x) {
          setState(() {
            _selectedChargeType = x;
            _topUpOperator = 0;
          });
        },
      ));
    });

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _list,
    );
  }

  Widget TopUpChargeTypes(int OperatorId) {
    List<Widget> _wlist = [];
    if (OperatorId != -1) {
      var _list = _operatorsWithLogo[OperatorId].chargeTypes;

      _list.forEach((element) {
        _wlist.add(CSelectedButton(
          height: 40,
          label: element.name,
          value: element.id,
          selectedValue: _selectedTopUpType,
          onPress: (t) {
            setState(() {
              _selectedTopUpType = t;
            });
          },
        ));
      });
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: _wlist,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // inAsyncCall: _inprogress,
        body: Stack(
      children: [
        MasterTemplateWithoutFooter(

            // inProgress: _inprogress,
            wchild: Column(
          children: [
            //    Padding(padding: EdgeInsets.only(top: 5)),
            Text(
              'شارژ تلفن همراه',
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
            ),
            Text(
              'اطلاعات مربوط به خرید شارژ را وارد کنید',
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
            Divider(
              color: PColor.orangeparto,
              thickness: 2,
            ),
            // بخش مربوط به اطلاعات اصلی
            Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: [
/*
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: PColor.orangeparto,
                        width: 2,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'نوع خرید شارژ را مشخص کنید',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(
                        color: PColor.orangeparto,
                        indent: 5,
                        endIndent: 5,
                        thickness: 2,
                      ),
                      ChargeTypes(),
                    ],
                  ),
                ),
*/
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: PColor.orangeparto,
                        width: 2,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: PColor.orangepartoAccent,
                  ),
                  child: _selectedChargeType == 0
                      ?
                      //بخش مربوط به تاپ آپ
                      Column(
                          children: [
                            Text(
                              'شماره همراه مورد نظر را وارد و یا از دفترچه تلفن انتخاب کنید',
                              textScaleFactor: 0.9,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        gapPadding: 2,
                                      ),
                                      suffixIcon: GestureDetector(
                                        child: Icon(
                                          Icons.sim_card,
                                          color: PColor.orangeparto,
                                        ),
                                        onTap: () {
                                          _prefs.then((value) {
                                            setState(() {
                                              _mobile.text =
                                                  value.getString('cellNumber');
                                            });
                                          });
                                        },
                                      ),
                                      fillColor: Colors.white,
                                      counterText: '',
                                      hintText: 'مثال 09123456789'),
                                  keyboardType: TextInputType.phone,
                                  maxLength: 11,
                                  controller: _mobile,
                                  onChanged: (v) {
                                    if (v.isNotEmpty &&
                                        v.length > 3 &&
                                        v.startsWith('09')) {
                                      setState(() {
                                        _selectedTopUpType = 0;
                                      });
                                      _onPhoneChange(v);
                                    } else {
                                      setState(() {
                                        _topUpOperator = -1;
                                      });
                                    }
                                    if (v.length == 11)
                                      FocusScope.of(context).unfocus();
                                  },
                                  textAlign: TextAlign.center,
                                )),
/*
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 5),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: PColor.blueparto,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.contact_page_rounded,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    getContact().then((value) {
                                      setState(() {
                                        _mobile.text = value;
                                        _onPhoneChange(value);
                                      });
                                    });
                                  },
                                )
*/
                              ],
                            ),
                            Divider(
                              color: PColor.orangeparto,
                              indent: 5,
                              endIndent: 5,
                              thickness: 2,
                            ),
                            Text(
                              'در صورت ترابرد خط، اپراتور را تغییر دهید',
                              style: TextStyle(
                                  color: PColor.blueparto,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                              textAlign: TextAlign.start,
                            ),
                            //بخش مربوط به گزینه های نوع شارژ تاپ آپ
                            Container(
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              height: 60,
                              //لیست لوگو و آیکون اپراتورهای موبایل
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _operatorsWithLogo.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          border: Border.all(
                                              color: index == _topUpOperator
                                                  ? PColor.blueparto
                                                  : Colors.grey,
                                              width: 1),
                                          boxShadow: index == _topUpOperator
                                              ? [
                                                  BoxShadow(
                                                      color: PColor.blueparto,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 1,
                                                      blurRadius: 1)
                                                ]
                                              : [
                                                  BoxShadow(
                                                      color: PColor.orangeparto,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 0,
                                                      blurRadius: 0)
                                                ],
                                          image: DecorationImage(
                                            image: AssetImage(
                                                index == _topUpOperator
                                                    ? _operatorsWithLogo[index]
                                                        .colorImage
                                                    : _operatorsWithLogo[index]
                                                        .grayImage),
                                            fit: BoxFit.fill,
                                          )),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _topUpOperator = index;
                                        _selectedTopUpType = 0;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                            //بخش نمایش گزینه های تاپ آپ قابل انجام برای هر اپراتور
                            _selectedTopUpType != -1 && _topUpOperator != -1
                                ? Column(
                                    children: [
                                      Divider(
                                        color: PColor.orangeparto,
                                        indent: 5,
                                        endIndent: 5,
                                        thickness: 2,
                                      ),
                                      Text(
                                        'یکی از روش های شارژ را انتخاب کنید',
                                        style: TextStyle(
                                            color: PColor.blueparto,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                        textAlign: TextAlign.start,
                                      ),
                                      TopUpChargeTypes(_topUpOperator),
                                    ],
                                  )
                                : Container(
                                    height: 0,
                                  ),
                            // بخش نمایش مبالغ مربوط به گزینه تا آپ
                            _selectedTopUpType != -1 && _topUpOperator != -1
                                ? Column(
                                    children: [
                                      Divider(
                                        color: PColor.orangeparto,
                                        indent: 5,
                                        endIndent: 5,
                                        thickness: 2,
                                      ),
                                      Text(
                                        'مبلغ شارژ مورد نظر را انتخاب کنید',
                                        style: TextStyle(
                                            color: PColor.blueparto,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                        textAlign: TextAlign.start,
                                      ),
                                      Column(
                                        children: [
                                          Prices(_topUpOperator,
                                              _selectedTopUpType)
                                        ],
                                      )

                                      //Prices(_topUpOperator, _selectedTopUpType)
                                    ],
                                  )
                                : Container(
                                    height: 0,
                                  )
                          ],
                        )
                      :
                      //بخش مربوط به کارت شارژ
                      Column(
                          children: [
                            Text(
                              'این بخش بزودی فعال می گردد',
                              style: TextStyle(
                                  color: PColor.blueparto,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                ),
                Container(
                  height: 90,
                ),
              ],
            )),
          ],
        )),
        _progressing
            ? Progress()
            : Positioned(
                bottom: 0,
                left: 5,
                right: 5,
                child: Container(
                  height: 60,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: PColor.orangeparto,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                            color: PColor.blueparto.shade300,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, -1))
                      ]),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CButton(
                          label: 'بعدی',
                          onClick: () {
                            if (_selectedChargeType == 0) if (_topUpOperator ==
                                    -1 ||
                                _mobile.text.length < 11) {
                              showDialog(
                                  context: context,
                                  builder: (context) => CAlertDialog(
                                        content: 'خطا در شماره',
                                        subContent:
                                            'شماره همراه وارد شده درست نیست، لطفا شماره را بررسی کنید.',
                                        buttons: [
                                          CButton(
                                            label: 'بستن',
                                            onClick: () =>
                                                Navigator.of(context).pop(),
                                          )
                                        ],
                                      ));
                            } else if (_selectedAmount < 500) {
                              showDialog(
                                  context: context,
                                  builder: (context) => CAlertDialog(
                                        content: 'خطا در مبلغ',
                                        subContent:
                                            'مبلغ برای شارژ را انتخاب کنید',
                                        buttons: [
                                          CButton(
                                            label: 'بستن',
                                            onClick: () =>
                                                Navigator.of(context).pop(),
                                          )
                                        ],
                                      ));
                            } else {
                              _sendToPayment();
                            }
                          },
                          minWidth: 120,
                        ),
                        CButton(
                          label: 'تکرار خرید قبلی',
                          onClick: () {
                            getLastPurchase();
                          },
                          minWidth: 120,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        _paymentDialog()
      ],
    ));
  }

  //Detect operator of mobile with 3 number of starting
  _onPhoneChange(String number) {
    if (number.length > 2) {
      var _firstCharacter = number.substring(0, 3);
      switch (_firstCharacter) {
        case '091':
          {
            setState(() {
              _topUpOperator = 1;
            });
            setState(() {});
          }
          break;
        case '093':
          {
            setState(() {
              _topUpOperator = 0;
            });
            setState(() {});
          }
          break;
        case '092':
          {
            setState(() {
              _topUpOperator = 2;
            });
            setState(() {});
          }
          break;
        case '099':
          {
            setState(() {
              _topUpOperator = 3;
            });
            setState(() {});
          }
          break;

        default:
          {
            setState(() {
              _topUpOperator = -1;
            });
          }
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

/*
  Future<String> getContact() async {
    final ContactPicker _contactPicker = new ContactPicker();
    String _phoneNumber = '';
    Contact contact = await _contactPicker.selectContact();
    if (contact.phoneNumber != null) {
      _phoneNumber = contact.phoneNumber.number;
      _phoneNumber = _phoneNumber.replaceAll('+98', '0');
      _phoneNumber = _phoneNumber.replaceAll(' ', '');
      _phoneNumber = _phoneNumber.replaceAll('-', '');
      _phoneNumber = _phoneNumber.replaceAll('(', '');
      _phoneNumber = _phoneNumber.replaceAll(')', '');
    }
    return _phoneNumber;
  }
*/

  Future<void> getLastPurchase() async {
    setState(() {
      _progressing = true;
    });
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _p = await SharedPreferences.getInstance();
        String _token = _p.getString('token');
        var _body = {
          "RequestType": 0,
          "LocalDate": DateTime.now().toString(),
          "Sign": _p.getString('sign'),
          "UseWallet": true
        };

        var result = await http.post(
            Uri.parse('${globalVars.srvUrl}/Api/Charge/LastTxn'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: json.encode(_body));
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            getLastPurchase();
          });
        }
        if (result.statusCode == 200) {
          debugPrint(result.body);
          var jres = json.decode(result.body);
          setState(() {
            _progressing = false;
          });

          if (jres['ResponseCode'] == 0) {
            setState(() {
              _mobile.text = '0' + jres['CellNumber'];
              _invoiceTitle =
                  '${_operatorsWithLogo[jres['Operator']].chargeTypes.firstWhere((m) => m.id == jres['ChargeType']).name}  ${_operatorsWithLogo[jres['Operator']].name}';
              _invoiceSubTitle =
                  '${_operatorsWithLogo[jres['Operator']].chargeTypes.firstWhere((element) => element.id == jres['ChargeType']).name}';
              _invoiceAmount = (jres['Amount']);
              _canUseWallet = jres['CanUseWallet'];
              _paymentLink = jres['Url'];
              _walletAmount = jres['Cash'];
              _progressing = false;
              _readyToPay = true;
            });
          } else if (jres['ResponseCode'] == 5) {
            auth.retryAuth().then((value) {
              getLastPurchase();
            });
          } else
            showDialog(
              context: context,
              builder: (context) => CAlertDialog(
                subContent: jres['ResponseMessage'],
                buttons: [
                  CButton(
                    label: 'بستن',
                    onClick: () => Navigator.of(context).pop(),
                  )
                ],
                content: '',
              ),
            );
        }
      } else
        showDialog(
          context: context,
          builder: (context) => CAlertDialog(
            content: 'خطا در احراز هویت',
            buttons: [
              CButton(
                label: 'بستن',
                onClick: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
    });
  }
}
