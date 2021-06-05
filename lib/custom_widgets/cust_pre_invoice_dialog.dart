import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/classes/topup.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_buttonbar.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;


class PreInvoiceContainer extends StatefulWidget {
  final String title;
  final String subTitle;
  final double amount;
  final double walletAmount;
  final String paymentLink;
  final bool canUseWallet;
  bool readyToPayment;



   PreInvoiceContainer({ Key key, this.title='',this.subTitle='',this.amount=0,this.walletAmount=0,this.paymentLink='',this.canUseWallet=false,this.readyToPayment=false }):super(key: key) ;
  @override
  _PreInvoiceContainerState createState() => _PreInvoiceContainerState();
}

class _PreInvoiceContainerState extends State<PreInvoiceContainer> with TickerProviderStateMixin {

int _selectedPaymentType=-1;


Future<void> _payWithWallet() async{
  int _refIdIndex=widget.paymentLink.indexOf('?RefId=')+7;
  String _refId=widget.paymentLink.substring(_refIdIndex);

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
         Uri.parse( '${globalVars.srvUrl}/Api/Charge/TopUp'),
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
        debugPrint(result.body);
        var jres = json.decode(result.body);
}
      }
  });





}








  @override
  Widget build(BuildContext context) {
    return
    Directionality(textDirection: TextDirection.rtl,
        child:       AnimatedPositioned(
          duration: Duration(seconds: 2),
          child:
              Material(
                color: Colors.transparent,
                child:
                Container(
                  height: MediaQuery.of(context).size.height*0.7+30,
                  color: Colors.transparent,
                  child:           Stack(
                    alignment: Alignment.bottomCenter,
                    children: [

                      Container(
                        height: MediaQuery.of(context).size.height*0.7,
                        width: MediaQuery.of(context).size.width-30,
                        padding: EdgeInsets.only(top: 5,left: 15,right: 15),
                        decoration: BoxDecoration(
                            color: PColor.blueparto,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                            boxShadow: [
/*
                        BoxShadow(
                            color: PColor.orangeparto,
                            blurRadius: 3,
                            spreadRadius: 3,
                            offset: Offset(0,-1)
                        ),
*/
                            ]
                        ),
                        child:
                        Column(
                          crossAxisAlignment:CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ListView(
                                children: [
                                  Text('تایید اطلاعات تراکنش',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textScaleFactor: 1.3,textAlign: TextAlign.center,),
                                  Text('اطلاعات را مطالعه و پس از اطمینان پرداخت نمایید',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),textScaleFactor: 0.8,textAlign: TextAlign.center,),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    margin: EdgeInsets.only(top: 5,left: 0,right: 0),
                                    decoration: BoxDecoration(
                                      color: PColor.blueparto.shade900,
                                      borderRadius: BorderRadius.circular(15),

                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('نام محصول:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),textScaleFactor: 1,),
                                            Text('${widget.title}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),textScaleFactor: 1,),

                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('نوع محصول:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),textScaleFactor: 1,),
                                            Text('${widget.subTitle}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),textScaleFactor: 1,),

                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('مبلغ پرداخت:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),textScaleFactor: 1.2,),
                                            Text('${getMoneyByRial(widget.amount.toInt())} ریال',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),textScaleFactor: 1.2,),

                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                  Text('روش پرداخت',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textScaleFactor: 1.3,textAlign: TextAlign.center,),
                                  Text('یکی از روش های پرداخت را انتخاب نمایید',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),textScaleFactor: 0.8,textAlign: TextAlign.center,),
                                  Row(
                                    children: [
                                      CSelectedButton(
                                        label: 'کیف پول',
                                        height: 40,
                                        selectedColor: Colors.blue,
                                        selectedValue: _selectedPaymentType,
                                        value: 0,
                                        onPress: (v){
                                          setState(() {
                                            _selectedPaymentType=v;
                                          });
                                        },
                                      ),
                                      CSelectedButton(
                                        label: 'کارت بانکی',
                                        selectedValue: _selectedPaymentType,
                                        selectedColor: Colors.blue,
                                        height: 40,

                                        value: 1,
                                        onPress: (v){
                                          setState(() {
                                            _selectedPaymentType=v;
                                          });
                                        },
                                      )

                                    ],
                                  ),
                                  _selectedPaymentType==0?
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    margin: EdgeInsets.only(top: 5,left: 0,right: 0),
                                    decoration: BoxDecoration(
                                      color: PColor.blueparto.shade900,
                                      borderRadius: BorderRadius.circular(15),

                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('مانده کیف پول:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),textScaleFactor: 1,),
                                            Text('${getMoneyByRial(widget.walletAmount.toInt())} ریال',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),textScaleFactor: 1,),

                                          ],
                                        ),
                                        widget.walletAmount<widget.amount?
                                            Text('مبلغ ${getMoneyByRial(widget.amount.toInt())} ریال با کارت بانکی پرداخت شود',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.normal),textScaleFactor: 1,):
                                            Container(height: 0,),


                                      ],
                                    ),
                                  ):Container(height: 0,),


                                ],
                              ),
                            ),
                            Container(
                              height: 60,
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _selectedPaymentType==0 && widget.walletAmount>widget.amount?
                                  CButton(label: 'پرداخت با کیف پول',onClick: (){
                                    _payWithWallet();
                                  },color: Colors.blue,textColor: Colors.white,):
                                  CButton(label: 'پرداخت با درگاه بانکی',onClick: () async{
                                    if(await canLaunch(widget.paymentLink))
                                      launch(widget.paymentLink).then((value) {
                                        setState(() {
                                          widget.readyToPayment=false;
                                        });
                                      });
                                  },color: Colors.redAccent,textColor: Colors.white,),

                                  Column(
                                    children: [
                                      Text('مبلغ قابل پرداخت',style: TextStyle(color: Colors.white70),textScaleFactor: 0.9,),
                                      Text(' ${getMoneyByRial(widget.amount.toInt())} ریال',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),textScaleFactor: 1.2,)
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
                          child:
                          GestureDetector(
                            child:                     Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(150),
                                  color: PColor.orangeparto

                              ),
                              child: Icon(Icons.close,size: 35,color: Colors.white,),
                            ),
                            onTap: (){
                              setState(() {
                                widget.readyToPayment=false;
                              });
                            }
                            ,
                          )
                      )

                    ],
                  ),

                ),

              ),
          bottom: widget.readyToPayment? 0:(MediaQuery.of(context).size.height*0.7+30)*-1,
          right: 5,
          left: 5,
          curve: Curves.fastLinearToSlowEaseIn,




        )
    )
    ;

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    this.dispose();
  }
}