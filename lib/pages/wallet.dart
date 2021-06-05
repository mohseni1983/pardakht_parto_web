import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/classes/wallet_trans.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_buttonbar.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:url_launcher/url_launcher.dart';
import 'package:persian_datepicker/persian_datepicker.dart';
import 'package:persian_datepicker/persian_datetime.dart';
import 'package:intl/intl.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _progressing = false;
  TextEditingController _startDatePicker = new TextEditingController();
  TextEditingController _endDatePicker = new TextEditingController();
  PersianDatePickerWidget _startPickerWidget;
  PersianDatePickerWidget _endPickerWidget;
  List<FinancingInfoListElement> _transList = [];
  int _transCount = 0;
  PersianDateTime getPersianDate(DateTime dateTime) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    PersianDateTime todayPersianDate = PersianDateTime.fromGregorian(
        gregorianDateTime: formatter.format(dateTime));
    return todayPersianDate;
  }

  @override
  void initState() {
    // TODO: implement initState

    _startPickerWidget = PersianDatePicker(
      controller: _startDatePicker,
      //datePickerHeight: 80,
      fontFamily: 'Dirooz',
      datetime:
          getPersianDate(DateTime.now().add(Duration(days: -1))).toString(),
      headerTodayBackgroundColor: PColor.orangeparto,
      farsiDigits: false,
      //daysBackgroundColor: PColor.blueparto,
      headerBackgroundColor: PColor.orangeparto,
      headerTodayIcon: Icon(
        Icons.today_rounded,
        color: PColor.blueparto,
      ),
      selectedDayBackgroundColor: PColor.orangepartoAccent,
      weekCaptionsBackgroundColor: PColor.blueparto,
      //datetime: todayPersianDate.toString(),
      //maxDatetime: todayPersianDate.toString(),
      rangeDatePicker: false,
      //rangeSeparator: '/',
    ).init();
    _endPickerWidget = PersianDatePicker(
      controller: _endDatePicker,
      //datePickerHeight: 80,
      fontFamily: 'Dirooz',
      farsiDigits: false,

      datetime: getPersianDate(DateTime.now()).toString(),
      headerTodayBackgroundColor: PColor.orangeparto,
      //daysBackgroundColor: PColor.blueparto,
      headerBackgroundColor: PColor.orangeparto,
      headerTodayIcon: Icon(
        Icons.today_rounded,
        color: PColor.blueparto,
      ),
      selectedDayBackgroundColor: PColor.orangepartoAccent,
      weekCaptionsBackgroundColor: PColor.blueparto,
      //datetime: todayPersianDate.toString(),
      //maxDatetime: todayPersianDate.toString(),
      rangeDatePicker: false,
      //rangeSeparator: '/',
    ).init();

    super.initState();
  }

  //پروگرس ارتباط با سرور جهت دریافت اطلاعات
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

  // for step of Stepper
  int _currentStep = 0;

  bool _inprogress = false;

  Future<void> _payWalletCharge() async {
    setState(() {
      _progressing = true;
    });
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _p = await SharedPreferences.getInstance();
        String _token = _p.getString('token');
        var _body = {
          "Amount": _selectAmountForCharge,
          "LocalDate": DateTime.now().toString(),
          "Sign": _p.getString('sign'),
          "UseWallet": true
        };
        var jBody = json.encode(_body);
        var result = await http.post(
            Uri.parse('${globalVars.srvUrl}/Api/Charge/Wallet'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jBody);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            _payWalletCharge();
          });
        }
        if (result.statusCode == 200) {
          setState(() {
            _progressing = false;
          });
          debugPrint(result.body);
          var jres = json.decode(result.body);
          if (jres['ResponseCode'] == 0) {
            launch(jres['Url']).then((value) =>
                Navigator.of(context).popUntil(ModalRoute.withName('/')));
          } else {
            showDialog(
              context: context,
              builder: (context) => CAlertDialog(
                content: 'خطا در عملیات',
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
      }
    });
  }

//ویجت مربوط به انتخاب عملیات کیف پول
  List<String> _walletOperationTypeList = ['شارژ کیف پول', 'گزارش تراکنش ها'];
  int _selectedWalletOperation = 0;
  Widget WalletOperationTypes() {
    List<Widget> _list = [];
    var _x = _walletOperationTypeList.asMap();
    _x.forEach((key, v) {
      _list.add(CSelectedButton(
        value: key,
        label: v,
        height: 35,
        selectedValue: _selectedWalletOperation,
        onPress: (x) {
          setState(() {
            _selectedWalletOperation = x;
          });
          if (x == 1) {
            setState(() {
              _transList = [];
              _currentPage = 1;
            });
            getWalletTransactions(
                pageNumber: _currentPage,
                startDate: DateTime.now().add(Duration(days: -1)),
                endDate: DateTime.now(),
                pageSize: pageSize);
          }
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
//ویجت مربوط به انتخاب عملیات کیف پول-پایان

  //ویجت عدد اعتبار
  int _selectAmountForCharge = 10000;
  List<int> _predefinedAmountList = [500000, 750000, 1000000];
  Widget ChargeAmountSelector() {
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: PColor.orangeparto, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    color: PColor.blueparto,
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(10))),
                width: 80,
                height: 50,
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                if (_selectAmountForCharge < 2000000)
                  setState(() {
                    _selectAmountForCharge = _selectAmountForCharge + 10000;
                  });
              },
            ),
            Expanded(
                child: Container(
                    color: PColor.orangepartoAccent,
                    height: 50,
                    child: Center(
                      child: Text(
                        '${getMoneyByRial(_selectAmountForCharge)} ریال',
                        style: TextStyle(
                            color: PColor.blueparto,
                            fontWeight: FontWeight.bold),
                        textScaleFactor: 1.2,
                      ),
                    ))),
            GestureDetector(
              child: Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                    color: PColor.blueparto,
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(10))),
                child: Center(
                  child: Icon(
                    Icons.remove,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                if (_selectAmountForCharge >= 60000)
                  setState(() {
                    _selectAmountForCharge = _selectAmountForCharge - 10000;
                  });
              },
            ),
          ],
        ));
  }

  Widget PreDefinedAmountSelector() {
    var _list = _predefinedAmountList.asMap();
    List<Widget> _widgetList = [];
    _list.forEach((key, value) {
      _widgetList.add(CSelectedButton(
        height: 40,
        label: getMoneyByRial(value),
        value: value,
        selectedValue: _selectAmountForCharge,
        onPress: (v) {
          setState(() {
            _selectAmountForCharge = v;
          });
        },
      ));
    });
    return Container(
      margin: EdgeInsets.all(5),
      child: Row(
        children: _widgetList,
      ),
    );
  }

  //بخش دریافت لیست تراکنش های کیف پول
  Future<void> getWalletTransactions(
      {int pageNumber,
      DateTime startDate,
      DateTime endDate,
      int pageSize}) async {
    setState(() {
      isLoading = true;
    });
    auth.checkAuth().then((value) async {
      if (value)
        try {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          String _sign = _prefs.getString('sign');
          String _token = _prefs.get('token');
          var _body = {
            "LocalDate": DateTime.now().toString(),
            "Sign": _sign,
            "UseWallet": true,
            "CurrentPage": pageNumber,
            "DateFrom": startDate.toString(),
            "DateTo": endDate.toString(),
            "PageSize": pageSize,
            "UseWallet": true
          };
          var _jBody = json.encode(_body);
          var result = await http
              .post(
                  Uri.parse('${globalVars.srvUrl}/Api/Charge/GetFinancingInfo'),
                  headers: {
                    'Authorization': 'Bearer $_token',
                    'Content-Type': 'application/json'
                  },
                  body: _jBody)
              .timeout(Duration(seconds: 20));
          if (result.statusCode == 401) {
            auth.retryAuth().then((value) {
              getWalletTransactions(
                  pageNumber: pageNumber,
                  startDate: startDate,
                  endDate: endDate,
                  pageSize: pageSize);
            });
          }
          if (result.statusCode == 200) {
            setState(() {
              _progressing = false;
              isLoading = false;
            });
            debugPrint(result.body);
            var jres = json.decode(result.body);
            debugPrint(jres.toString());

            if (jres['ResponseCode'] == 0) {
              var _financeList = jres['FinancingInfoList'];
              debugPrint(jres.toString());
              WalletTransFinancingInfoList _list =
                  WalletTransFinancingInfoList.fromJson(_financeList);
              setState(() {
                _transCount = _list.totalCounts;
                _transList.addAll(_list.financingInfoLists);
              });
            }
          }
        } on TimeoutException catch (e) {
          showDialog(
            context: context,
            builder: (context) => CAlertDialog(
              content: 'خطای ارتباط',
              subContent: 'ارتباط با سرور بر قرار نشد',
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
    });
  }


  bool isLoading = false;
  int pageSize = 10;
  int _currentPage = 1;
  Widget MakeListOfTrans() {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            // start loading data
            if (_currentPage <= (_transCount / pageSize).ceil()) {
              setState(() {
                _currentPage++;
                isLoading = true;
              });
              getWalletTransactions(
                  pageNumber: _currentPage,
                  startDate: DateTime.now().add(Duration(days: -1)),
                  endDate: DateTime.now(),
                  pageSize: pageSize);
            }
          }
          return true;
        },
        child: ListView.builder(
          //shrinkWrap: true,

          itemCount: _transList.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            var _item = _transList[index];
            return Container(
                padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                height: 80,
                //color: Colors.green,
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                    color: PColor.orangepartoAccent,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 8,
                      height: 67,
                      decoration: BoxDecoration(
                          color: _item.creditAmount > 0
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(12))),
                    ),
                    Container(
                      width: 20,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_item.transactionTypeDetails}',
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: PColor.blueparto),
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: PColor.orangeparto,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'مانده کیف: ${getMoneyByRial(_item.creditRemain.toInt())} ریال ',
                                style: TextStyle(
                                    color: PColor.blueparto,
                                    fontWeight: FontWeight.bold),
                                textScaleFactor: 0.9,
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${_item.description}',
                              style: TextStyle(
                                  color: PColor.blueparto.shade300,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${getPersianDate(_item.transactDate)}-${_item.transactDate.hour}:${_item.transactDate.minute}:${_item.transactDate.second}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: PColor.orangeparto),
                              textScaleFactor: 0.8,
                            ),
                            _item.creditAmount > 0
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${getMoneyByRial(_item.creditAmount.toInt())} ریال',
                                        style: TextStyle(
                                            color: Colors.green.shade700),
                                      ),
                                      Icon(
                                        Icons.arrow_circle_up,
                                        color: Colors.green.shade600,
                                      )
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${getMoneyByRial((_item.creditAmount * -1).toInt())} ریال',
                                        style: TextStyle(
                                            color: Colors.red.shade700),
                                      ),
                                      Icon(
                                        Icons.arrow_circle_down,
                                        color: Colors.red.shade600,
                                      )
                                    ],
                                  ),
                          ],
                        ),
                        Container(
                          width: 20,
                        ),
                      ],
                    ))
                  ],
                ));
          },
        ));
  }

  TransactionType getTransactionType(int id) {
    switch (id) {
      case 6:
        return TransactionType(color: Colors.blue, name: 'شارژ کیف پول');
        break;
      case 0:
        return TransactionType(color: Colors.green, name: 'شارژ موبایل');
        break;
      default:
        return TransactionType(color: PColor.blueparto, name: 'تراکنش مدل $id');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MasterTemplateWithoutFooter(

            // inProgress: _inprogress,
            wchild: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 15)),
            Text(
              'مدیریت کیف پول',
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
            ),
            Text(
              'عملیات و گزارشات کیف پول',
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
            Divider(
              color: PColor.orangeparto,
              thickness: 2,
            ),
            Container(
              padding: EdgeInsets.all(1),
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
                    'عملیات مورد نظر را انتخاب کنید',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    color: PColor.orangeparto,
                    indent: 5,
                    endIndent: 5,
                    height: 0,
                    thickness: 2,
                  ),
                  WalletOperationTypes(),
                ],
              ),
            ),

            // بخش مربوط به اطلاعات اصلی
            Expanded(
                child: _selectedWalletOperation == 0
                    ? ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Container(
                              //height: 50,
                              padding: EdgeInsets.all(1),
                              margin: EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: PColor.orangeparto,
                                    width: 2,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(12),
                                color: PColor.orangepartoAccent,
                              ),
                              child:
                                  //بخش مربوط به شارژ کیف
                                  Column(
                                children: [
                                  Text(
                                    'مبلغ شارژ مد نظر برای کیف پول را انتخاب کنید',
                                    textScaleFactor: 0.9,
                                  ),
                                  ChargeAmountSelector(),
                                  PreDefinedAmountSelector()
                                ],
                              )),
                          //بخش مربوط به گزارش

                          Container(
                            height: 90,
                          ),
                        ],
                      )
                    : MakeListOfTrans()),
            isLoading
                ? Container(
                    height: 10,
                    child: LinearProgressIndicator(),
                  )
                : Container(
                    height: 0,
                  )
          ],
        )),
        _progressing
            ? Progress()
            : _selectedWalletOperation == 0
                ? Positioned(
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
                              label: 'پرداخت',
                              onClick: () {
                                _payWalletCharge();
                              },
                              minWidth: 150,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 0,
                  ),
      ],
    );
  }

  @override
  void dispose() {
    this.dispose();
  }

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
}

class TransactionType {
  String name;
  Color color;

  TransactionType({this.name, this.color});
}
