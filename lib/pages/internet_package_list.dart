import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:contact_picker/contact_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pardakht_parto/Pages/main_page.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/classes/global_variables.dart';
import 'package:pardakht_parto/classes/internet_package.dart';
import 'package:pardakht_parto/classes/wallet.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_buttonbar.dart';
import 'package:pardakht_parto/custom_widgets/cust_seletable_grid_item.dart';
import 'package:pardakht_parto/custom_widgets/cust_seletable_package.dart';
import 'package:pardakht_parto/pages/main_page.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:url_launcher/url_launcher.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
class InternetPackageListPage extends StatefulWidget {
  final int operatorId;
  final int simCardId;
  final String mobile;
  final bool repeat;

  const InternetPackageListPage({Key key, this.operatorId=-1, this.simCardId=-1, this.mobile='', this.repeat=false,}) : super(key: key);
  @override
  _InternetPackageListPageState createState() => _InternetPackageListPageState();
}



class _InternetPackageListPageState extends State<InternetPackageListPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _progressing = false;
  String _paymentLink = '';
  bool _inprogress = false;
  bool  _readyToPay=false;

  String _invoiceTitle='';
  String _invoiceSubTitle='';
  double _invoiceAmount=0;
  int _selectedPaymentType = 1;
  double _walletAmount = 0;
  String  _uniqCode='';
  bool _canUseWallet=false;

  //repeated
  String repeateMobile='';




//send to payment Api  *** most redefine

//payment with wallet
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
          Uri.parse(  '${globalVars.srvUrl}/Api/Charge/WalletApprove'),
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
          setState(() {
          });
          var jres = json.decode(result.body);
          if (jres["ResponseCode"] == 0)
            showDialog(
              context: context,
              builder: (context) => CAlertDialog(
                content: 'عملیات موفق',
                subContent: 'خرید بسته با موفقیت انجام شد، به زودی بسته خریداری شده فعال می‌شود. جهت اشتراک رسید به بخش تراکنش ها مراجعه نمایید. ',
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

//get payment info for payment
  Future<void> _payChargeWithCardAndSend() async {
    setState(() {
      _progressing=true;
    });
    auth.checkAuth().then((value) async {
      if (value) {
        try {
          var _dp=_dataPlans.firstWhere((element) => element.id==_selectedPackage);

          SharedPreferences _p = await SharedPreferences.getInstance();
          debugPrint('PACKAGE: ${_selectedPackage}');
          var body={
            "CellNumber": widget.mobile.substring(1,11),
            "ChargeType": _selectedPackage,
            "UniqCode": _dp.uniqCode,
            "LocalDate": DateTime.now().toString(),
            "Sign": _p.getString('sign')
          };
          //            "Operator": widget.simCardId,
          String _token = _p.getString('token');
          var jsonTopUp = json.encode(body);
          var result = await http.post(
             Uri.parse( '${globalVars.srvUrl}/Api/Charge/DataPlan'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Content-Type': 'application/json'
              },
              body: jsonTopUp).timeout(Duration(seconds: 20));
          if (result.statusCode == 401) {
            auth.retryAuth().then((value) {
              _payChargeWithCardAndSend();
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
                'بسته ${_operatorsWithLogo[widget.operatorId].name} ';
                _invoiceSubTitle =
                '${_dp.title}';
                _invoiceAmount = _dp.priceWithTax;
                _canUseWallet = jres['CanUseWallet'];
                _paymentLink = jres['Url'];
                _walletAmount = jres['Cash'];
                _readyToPay = true;
              });
            }

            else
              showDialog(
                context: context,
                builder: (context) =>
                    CAlertDialog(
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
        } on TimeoutException catch(e){
          setState(() {
            _progressing=false;
          });
          showDialog(
            context: context,
            builder: (context) =>
                CAlertDialog(
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
        }
      }

    });
  }


//

  //widget for payment
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
                        boxShadow: [
                        ]),
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
                                              fontWeight: FontWeight.bold,fontSize:12,),
                                          softWrap: true,
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
                                        Container(height: 40,
                                        width: MediaQuery.of(context).size.width/2,
                                        child:                                         Text(
                                          '${_invoiceSubTitle}',
                                          style: TextStyle(
                                              color: PColor.orangeparto,
                                              fontWeight: FontWeight.bold,fontSize:10),
                                          textScaleFactor: 1,
                                          softWrap: true,
                                        ),

                                        )
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
                                          '${widget.mobile.isNotEmpty?widget.mobile:repeateMobile}',
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
                                      Navigator.of(context).popUntil(ModalRoute.withName('/'));
                                     

                                    });

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

  int test=0;

  List<DataPlan> _listOfPlans;
  @override
  void initState() {


    // TODO: implement initState
    super.initState();

/*    if(widget.repeat){
      getLastPurchase().then((value) {

        setState(() {
          _progressing=false;
          _readyToPay=true;

        });

      });
    }
else*/
getDataPlans();


  }

  Future<void> getLastPurchase() async{
    setState(() {
      _progressing=true;
    });
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _p = await SharedPreferences.getInstance();
        String _token = _p.getString('token');
        var _body = {
          "RequestType":1,
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

          if (jres['ResponseCode'] == 0){
            setState(() {


              repeateMobile='0'+jres['CellNumber'];
              _invoiceTitle =
              'بسته ${_operatorsWithLogo[jres['Operator']].name} ';
              _invoiceSubTitle = jres['Title'];
            _invoiceAmount = (jres['PriceWithTax']);
              _canUseWallet = jres['CanUseWallet'];
              _paymentLink = jres['Url'];
              _walletAmount = jres['Cash'];


            });

          }
/*            showDialog(
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
            );*/
          else if (jres['ResponseCode'] == 5) {
            auth.retryAuth().then((value) {
             // getLastPurchase();
            });
          } else
            showDialog(
              context: context,
              builder: (context) => CAlertDialog(
                subContent: jres['ResponseMessage'],
                content: "",
                buttons: [
                  CButton(
                    label: 'بستن',
                    onClick: () => Navigator.of(context).pop(),
                  )
                ],
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


  // get the list of packages;
  List<DataPlan> _dataPlans=[];
  Future<void> getDataPlans() async{
    setState(() {
      _progressing=true;
    });
    auth.checkAuth().then((value) async{
      if(value){
        SharedPreferences _prefs=await SharedPreferences.getInstance();
        String _token=_prefs.getString('token');
        String _sign=_prefs.getString('sign');
        var _body=json.encode({
          "LocalDate": DateTime.now().toString(),
          "Sign": _sign,
        });
        try{
          var result=await http.post(
              Uri.parse('${globalVars.srvUrl}/Api/Charge/GetDataPlanList'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Content-Type': 'application/json'
              },
              body: _body
          ).timeout(Duration(seconds: 20));
          if(result.statusCode==401){
            auth.retryAuth().then((value) {
              getDataPlans();
            });
          }
          if(result.statusCode==200){
            setState(() {
              _progressing=false;
            });
            var jResult=json.decode(result.body);
            //debugPrint(jResult.toString());
            if(jResult['ResponseCode']==0){

               var s= internetPackageFromJson(result.body).dataPlans;
               setState(() {
                 _dataPlans= internetPackageFromJson(result.body).dataPlans;
               });
               //s.retainWhere((element) => element.dataPlanOperator==widget.operatorId && element.dataPlanType==widget.simCardId );
               //debugPrint('SIMCARD: ${widget.simCardId}');
               //debugPrint('OPERATOR: ${widget.operatorId}');

              s.forEach((dp) {
                _packs.forEach((pr) {
                  if (dp.period==pr.id && dp.dataPlanOperator==widget.operatorId && dp.dataPlanType==widget.simCardId)
                    setState(() {
                      pr.dataPlans.add(dp);
                    });
                });
              });

               _packs.forEach((element) {
                 //debugPrint('${element.name} ---- ${element.dataPlans.length}');
               });




            }else{
              showDialog(context: context,
                builder: (context) =>
                    CAlertDialog(content: 'خطا در دریافت اطلاعات',subContent: jResult['ResponseMessage'],buttons: [CButton(label: 'بستن',onClick: ()=>
                        Navigator.of(context).popUntil(ModalRoute.withName('/'))
                      ,)],) ,
              );
            }
          }
        }on TimeoutException catch(e){
          showDialog(context: context,
            builder: (context) => CAlertDialog(
              content: 'خطای ارتباط با سرور',
              subContent: 'سرور پاسخ نمی دهد، از اتصال اینترنت خود مطمئن شوید',
            ),
          );
        }catch (exception, stackTrace){
          await Sentry.captureException(
            exception,
            stackTrace: stackTrace,
          );
        }
      }
    });
  }


  List<NetPackage> _packs=[
    new NetPackage(id: 0,name: 'ساعتی',dataPlans: []),
    new NetPackage(id:1,name: 'روزانه',dataPlans: []),
    new NetPackage(id:2,name: 'هفتگی',dataPlans: []),
    new NetPackage(id: 3,name: 'ماهانه',dataPlans: []),
    new NetPackage(id:8,name: 'دو ماهه',dataPlans: []),
    new NetPackage(id: 9,name: 'سه ماهه',dataPlans: []),
    new NetPackage(id: 10,name: 'چهارماهه',dataPlans: []),
    new NetPackage(id: 4,name: 'شش ماهه',dataPlans: []),
    new NetPackage(id: 5,name: 'سالانه',dataPlans: [])
  ];






  int _selectedPackage=2;
  Widget Packages(){
    List<Widget> _list=[];
    var _loc=_packs.firstWhere((element) => element.id==_selectedPeriod);
    if(_loc!=null)
    _loc.dataPlans.forEach((element) {
      _list.add(
        CSelectedPackage(
          costWithoutTax: element.priceWithoutTax,
          costWithTax: element.priceWithTax,
          height: 90,
          value: element.id,
          label: element.title,
          color: _operatorsWithLogo[widget.operatorId].color,
          selectedValue: _selectedPackage,
          onPress: (v){
            setState(() {
              _selectedPackage=v;
              //_uniqCode=_packs[widget.]
            });
          },
        )
      );
    });
    return ListView(
      padding: EdgeInsets.zero,
      children: _list,
    );
  }

  ///////////////////////////////////////////////



// List of mobile operator with color and grayscale images
  List<InternetPackageOperators> _operatorsWithLogo = [
    new InternetPackageOperators(
        id: 0,
        name: 'ایرانسل',
        colorImage: 'assets/images/mtn-color.jpg',
        grayImage: 'assets/images/mtn-gray.jpg',
        color: Color(0xfffebe10),
        simTypes: [
          new SimCardTypes(id: 0,name: 'دائمی'),
          new SimCardTypes(id: 1,name: 'اعتباری'),
          new SimCardTypes(id: 2,name: 'اعتباری TDLte'),
          new SimCardTypes(id: 4,name: 'دایمی FDLte')
        ]
    ),
    new InternetPackageOperators(
        id: 1,
        name: 'همراه اول',
        colorImage: 'assets/images/mci-color.jpg',
        grayImage: 'assets/images/mci-gray.jpg',
        color: Color(0xff54c5d0),
        simTypes: [
          new SimCardTypes(id: 0,name: 'دائمی'),
          new SimCardTypes(id: 1,name: 'اعتباری')
        ]),
    new InternetPackageOperators(
        id: 3,
        name: 'رایتل',
        colorImage: 'assets/images/rightel-color.jpg',
        grayImage: 'assets/images/rightel-gray.jpg',
        color: Color(0xff941063),
        simTypes: [
          new SimCardTypes(id: 0,name: 'دائمی'),
          new SimCardTypes(id: 1,name: 'اعتباری'),
          new SimCardTypes(id: 3,name: 'دیتا')
        ]),
    new InternetPackageOperators(
        id: 4,
        name: 'شاتل موبایل',
        colorImage: 'assets/images/shatel-color.jpg',
        grayImage: 'assets/images/shatel-gray.jpg',
        color: Color(0xfff26322),
        simTypes: [
          new SimCardTypes(id: 1,name: 'اعتباری'),
        ]),
  ];

  //create list of  packages
  int _selectedPeriod=3;
  List<DataPlan> _plans=[];
  void filterList({ int operatorId, int simCardTypeId,int selectedPeriod=0, List<DataPlan> masterList})
  {
    getDataPlans();
    setState(() {
      _plans=masterList;
    });
    setState(() {
      _plans.retainWhere((element) => element.dataPlanOperator==operatorId && element.dataPlanType==simCardTypeId && element.period==_selectedPeriod);
      debugPrint(_listOfPlans.length.toString());

    });

  }



  //create list of periods
  Widget ListOfPeriods(){
    List<Widget> _list=[];
    _packs.forEach((element) {
      if(element.dataPlans.length>0)
      _list.add(

          CSelectedGridItem(
            height: 30,
            fontSize: 12,
            textScaleFactor: 0.9,
            paddingHorizontal: 10,
            paddingVertical: 5,
            label: element.name,
            value: element.id,
            selectedValue: _selectedPeriod,
            onPress: (v){
              setState(() {
                _selectedPeriod=v;
              });
            },
          )
      );
    });
    return

      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:        ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: Wrap(
              children: _list,
              direction: Axis.horizontal,
              spacing: 2,
            ),
          )
          ,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _inprogress,
        child: Stack(
          children: [
            MasterTemplateWithoutFooter(

              // inProgress: _inprogress,
                wchild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Padding(padding: EdgeInsets.only(top: 15)),
                    Text(
                      'بسته های اینترنت',
                      style: Theme.of(context).textTheme.headline1,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'یکی از بسته ها را انتخاب نمائید',
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.center,
                    ),
                    Divider(
                      color: PColor.orangeparto,
                      thickness: 2,
                    ),
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          //height: 80,
                          child: ListOfPeriods()
                        ),
                        Divider(
                          color: PColor.orangeparto,
                          thickness: 2,
                        ),


                        //بخش نمایش گزینه های زمانی قابل انجام برای هر اپراتور



                        // بخش نمایش مبالغ مربوط به گزینه تا آپ

                      ],
                    ),
                    Expanded(
                      child: Packages(),
                    ),

                    // بخش مربوط به اطلاعات اصلی
                    Container(height: 90,)
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

                          if (_selectedPackage<0) {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    CAlertDialog(
                                      content: 'خطا در انتخاب',
                                      subContent:
                                      'یک بسته اینترنتی انتخاب کنید',
                                      buttons: [
                                        CButton(
                                          label: 'بستن',
                                          onClick: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      ],
                                    ));
                          }

                          else {
                            _payChargeWithCardAndSend();
                          }

                        },
                        minWidth: 100,
                      ),

/*
                      CButton(
                        label: 'تکرار خرید قبلی',
                        onClick: () {},
                        minWidth: 100,
                      ),
*/
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

  @override
  void dispose() {
    this.dispose();
  }





}

class NetPackage{
  int id;
  String name;
  List<DataPlan> dataPlans;

  NetPackage({ this.id,  this.name,  this.dataPlans});
}
