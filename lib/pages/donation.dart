import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:barcode_scan_fork/barcode_scan_fork.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pardakht_parto/classes/charities.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/classes/wallet.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_buttonbar.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_image_grid_btn.dart';
import 'package:pardakht_parto/custom_widgets/cust_seletable_grid_item.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  bool _progressing = false;
  bool _isSetAmountPage=false;
  List<FinancingInfoList>_charities=[];

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

  Future<void> getListOfCharities() async {
    setState(() {
      _progressing=true;
    });
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String _token = _prefs.getString('token');
        var _body = {
          "LocalDate": DateTime.now().toString(),
          "Sign": _prefs.getString('sign'),
          "UseWallet": true
        };
        var jBody = json.encode(_body);

        var result = await http.post(
            Uri.parse('${globalVars.srvUrl}/Api/Charge/GetCharityInfo'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jBody);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            getListOfCharities();
          });
        }
        if (result.statusCode == 200) {
          debugPrint(result.body);

          var jres = json.decode(result.body);
          debugPrint(jres.toString());
             if (jres["ResponseCode"] == 0)
             {
               var data=charitiesFromJson(result.body);
               setState(() {
                 _charities=data.charityTerminals.financingInfoLists;
                 _progressing=false;
               });


             }
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

  Future<void> getPaymentLink() async{
    setState(() {
      _progressing=true;
    });
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String _token = _prefs.getString('token');
        var _body = {
          "Amount": double.parse(_amountTxt.text.replaceAll(',', '')),
          "PspId": _charityPSid,
          "TermId": _charityTerminalId,
        "TerminalId": _selectedCharity,
          "LocalDate": DateTime.now().toString(),
          "Sign": _prefs.getString('sign'),
          "UseWallet": true
        };
        var jBody = json.encode(_body);

        var result = await http.post(
            Uri.parse('${globalVars.srvUrl}/Api/Charge/Charity'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jBody);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            getPaymentLink();
          });
        }
        if (result.statusCode == 200) {
          setState(() {
            _progressing=false;
          });

          var jres = json.decode(result.body);
          debugPrint(jres.toString());
          if (jres["ResponseCode"] == 0)
          {
            setState(() {
              _paymentLink=jres['Url'];
              _readyToPay=true;

            });
/*
            var data=charitiesFromJson(result.body);
            setState(() {
              _charities=data.charityTerminals.financingInfoLists;
              _progressing=false;
            });
*/


          }
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

  int _selectedCharity=-1;
  int _charityPSid=-1;
  String _charityTerminalId='';
  String _charityName='';
 Widget CharityList(){
    List<Widget> _list=[];
    _charities.forEach((element) {
      _list.add(
          CSelectedGridItem(
        selectedValue: _selectedCharity,
        value: element.id,
        label: element.title,
        paddingHorizontal: 3,
        paddingVertical: 3,
        height:40,
        width: MediaQuery.of(context).size.width,
        onPress: (t){
          setState(() {
            _selectedCharity=t;
            _charityTerminalId=element.termId;
            _charityPSid=element.pspId;
            _charityName=element.title;

          });
        },
      )
      );
    });
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(top: 10)),
          Text(
            'نیکوکاری',
            style: Theme.of(context).textTheme.headline1,
            textAlign: TextAlign.center,
          ),
          Divider(
            color: PColor.orangeparto,
            thickness: 2,
          ),

          Text(
            'یکی از خیریه های زیر را انتخاب نمائید',
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
          Divider(
            color: PColor.orangeparto,
            thickness: 2,
          ),
          Expanded(child:
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _charities.length,
            itemBuilder: (context, index) {
              var element=_charities[index];
              return
                CSelectedGridItem(
                selectedValue: _selectedCharity,
                value: element.id,
                label: element.title,
                paddingHorizontal: 3,
                paddingVertical: 3,
                height:40,
                width: MediaQuery.of(context).size.width,
                onPress: (t){
                  setState(() {
                    _selectedCharity=t;
                    _charityTerminalId=element.termId;
                    _charityPSid=element.pspId;
                    _charityName=element.title;

                  });
                },
              );

            },)),
          Container(height: 60,)


          // بخش مربوط به اطلاعات اصلی
        ],
      );



  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getListOfCharities();
    _amountTxt.text="0";
  }

  TextEditingController _amountTxt=new TextEditingController();
  Widget AmountWidget()=>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(top: 10)),
          Text(
            'نیکوکاری',
            style: Theme.of(context).textTheme.headline1,
            textAlign: TextAlign.center,
          ),
          Divider(
            color: PColor.orangeparto,
            thickness: 2,
          ),

  Container(
  decoration: BoxDecoration(
  border: Border.all(color: PColor.orangeparto),
  color: PColor.orangepartoAccent,
  borderRadius: BorderRadius.circular(12)
  ),
  padding: EdgeInsets.all(15),
  child: Column(
  children: [
  Text(
  'مبلغ مورد نظر را به ریال وارد نمائید',
  style: Theme.of(context).textTheme.subtitle1,
  textAlign: TextAlign.center,
  ),
  Divider(
  color: PColor.orangeparto,
  thickness: 2,
  ),
  TextField(
  decoration: InputDecoration(
  border: OutlineInputBorder(
  borderRadius:
  BorderRadius.circular(10),
  gapPadding: 2,
  ),
  suffixIcon: Icon(
  MdiIcons.label,
  color: PColor.orangeparto,
  ),
  fillColor: Colors.white,
  counterText: '',
  hintText: 'مبلغ به ریال'
  ),
  keyboardType: TextInputType.number,
  inputFormatters: [ThousandsSeparatorInputFormatter()],
  maxLength: 14,

  controller: _amountTxt,

  textAlign: TextAlign.center,
  ),
/*
  Text(
  'به لحاظ محدودیت های بانکی حداقل تراکنش هزار تومان است',
  style: Theme.of(context).textTheme.subtitle1,
  textAlign: TextAlign.center,
  ),
*/



  ],
  ),
  )


          // بخش مربوط به اطلاعات اصلی
        ],
      );




  bool  _readyToPay=false;
  String _paymentLink='';

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
                                          'نیکوکاری',
                                          style: TextStyle(
                                            color: PColor.orangeparto,
                                            fontWeight: FontWeight.bold,fontSize: 12,),
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
                                        Text(
                                          'کمک به  $_charityName',
                                          style: TextStyle(
                                              color: PColor.orangeparto,
                                              fontWeight: FontWeight.bold,fontSize: _charityName.length>40?9:12),
                                          textScaleFactor: 1,
                                          softWrap: true,
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
                                          '${getMoneyByRial(double.parse(_amountTxt.text.replaceAll(',', '')).toInt())} ریال',
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
                            ],
                          ),
                        ),
                        Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                   CButton(
                                label: 'پرداخت با درگاه بانکی',
                                onClick: () async {
                                  launch(_paymentLink).then((value) {
                                    setState(() {
                                      _readyToPay = false;
                                    });
                                    Navigator.of(context).popUntil(ModalRoute.withName('/'));

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
                                    ' ${getMoneyByRial(double.parse(_amountTxt.text.replaceAll(',', '')).toInt())} ریال',
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



  @override
  Widget build(BuildContext context) {
    return         Stack(
      alignment: Alignment.center,
      children: [
        MasterTemplateWithoutFooter(

          // inProgress: _inprogress,
            wchild:
            !_isSetAmountPage?
            CharityList():
            AmountWidget()
        ),
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
              child:
              _isSetAmountPage?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CButton(
                    label: 'بعدی',
                    onClick: () {
                      if(!_isSetAmountPage && _selectedCharity>-1)
                        setState(() {
                          _isSetAmountPage=true;
                        });
                      else if(_selectedCharity==-1)
                        showDialog(context: context,
                        builder: (context) => CAlertDialog(
                          content: 'خطا',
                          subContent: 'یکی از خیره ها را انتخاب کنید',
                          buttons: [
                            CButton(
                              label: 'بستن',
                              onClick: ()=>Navigator.of(context).pop(),
                            )
                          ],
                        ),
                        );
                      else if(_isSetAmountPage && _amountTxt.text.isNotEmpty) {
                        if (double.parse(_amountTxt.text.replaceAll(',', '')) >=
                            0)
                          getPaymentLink();
                        else

                      showDialog(context: context,
                      builder: (context) => CAlertDialog(
                      content: 'خطا',
                      subContent: 'مبلغ باید بیش از هزار تومان باشد',
                      buttons: [
                      CButton(
                      label: 'بستن',
                      onClick: ()=>Navigator.of(context).pop(),
                      )
                      ],
                      ),
                      );

                      }
                      else
                        showDialog(context: context,
                          builder: (context) => CAlertDialog(
                            content: 'خطا',
                            subContent: 'مبلغ خالی است',
                            buttons: [
                              CButton(
                                label: 'بستن',
                                onClick: ()=>Navigator.of(context).pop(),
                              )
                            ],
                          ),
                        );


                      //    _sendToPayment();

                    },
                    minWidth: 120,
                  ),

                  CButton(
                    label: 'قبلی',
                    onClick: () {
                      setState(() {
                        _isSetAmountPage=false;
                      });

                    },
                    minWidth: 120,
                  )

                ],
              ):
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CButton(
                    label: 'بعدی',
                    onClick: () {
                      if(!_isSetAmountPage && _selectedCharity>-1)
                        setState(() {
                          _isSetAmountPage=true;
                        });
                      else if(_selectedCharity==-1)
                        showDialog(context: context,
                          builder: (context) => CAlertDialog(
                            content: 'خطا',
                            subContent: 'یکی از خیره ها را انتخاب کنید',
                            buttons: [
                              CButton(
                                label: 'بستن',
                                onClick: ()=>Navigator.of(context).pop(),
                              )
                            ],
                          ),
                        );
                      else if(_isSetAmountPage && _amountTxt.text.isNotEmpty) {
/*                        if (double.parse(_amountTxt.text.replaceAll(',', '')) >=
                            10000)*/
                          getPaymentLink();
/*                        else

                          showDialog(context: context,
                            builder: (context) => CAlertDialog(
                              content: 'خطا',
                              subContent: 'مبلغ باید بیش از هزار تومان باشد',
                              buttons: [
                                CButton(
                                  label: 'بستن',
                                  onClick: ()=>Navigator.of(context).pop(),
                                )
                              ],
                            ),
                          );*/

                      }
                      else
                        showDialog(context: context,
                          builder: (context) => CAlertDialog(
                            content: 'خطا',
                            subContent: 'مبلغ خالی است',
                            buttons: [
                              CButton(
                                label: 'بستن',
                                onClick: ()=>Navigator.of(context).pop(),
                              )
                            ],
                          ),
                        );


                      //    _sendToPayment();

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
    );

  }

}
