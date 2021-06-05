import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:pardakht_parto/classes/topup.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;


class PreInvoice extends StatefulWidget {
  final String title;
  final String subTitle;
  final double amount;
  final double walletAmount;
  final String paymentLink;
  final bool canUseWallet;



  const PreInvoice({ Key key,  this.title, this.subTitle, this.amount,this.walletAmount=0, this.paymentLink, this.canUseWallet }):super(key: key) ;
  @override
  _PreInvoiceState createState() => _PreInvoiceState();
}

class _PreInvoiceState extends State<PreInvoice> {
  String _errorText='';


  Future<SharedPreferences> _prefs=SharedPreferences.getInstance();

  Future<void> _payChargeWithCard(TopUp topUp) async{
    if(await auth.checkAuth())
      {
        SharedPreferences _p=await SharedPreferences.getInstance();
        String _token=_p.getString('token');
        var sss=topUpToJson(topUp);
        var result=await http.post(Uri.parse('${globalVars.srvUrl}/Api/Charge/TopUp'),

            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'

            },
            body: topUpToJson(topUp)
        );
        if(result.statusCode==200){
          var jres=json.decode(result.body);
          if(jres['ResponseCode']==0){
            var _url=jres['Url'];
            if(await canLaunch(_url))
              await launch(_url);
            else
             setState(() {
               _errorText=jres['ResponseMessage'];
             });
          }else{
            setState(() {
              _errorText=jres['ResponseMessage'];
            });

          }
        }



      }
    else
      CAlertDialog(
        content: 'خطا در ارتباط با سرور', buttons: [],

      );



  }



  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl,
        child:
        Dialog(
            elevation: 55,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),



            ),
            backgroundColor: Colors.transparent,
            //backgroundColor: PColor.orangeparto,
            //insetPadding: EdgeInsets.all(15),
            child:
            Stack(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width/4*3,
                    height: MediaQuery.of(context).size.height-350,
                    //height: 200,
                    decoration: BoxDecoration(
                        color: PColor.orangeparto.shade400,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: PColor.blueparto,width: 3)
                    ),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(top: 35,bottom: 25),
                    child:ListView(
                      children: [
                        Text('اطلاعات پرداخت',textScaleFactor: 1.3,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                        Divider(color: Colors.white,thickness: 2,height: 4,indent: 5,endIndent: 5,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('نوع پرداخت',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.normal),),
                            Text('${widget.title}',style: TextStyle(color: PColor.blueparto,fontSize: 14,fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('نوع تراکنش',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.normal),),

                            Text('${widget.subTitle}',style: TextStyle(color: PColor.blueparto,fontSize: 14,fontWeight: FontWeight.bold),)
                          ],

                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('مبلغ تراکنش',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.normal),),
                            Text('${widget.amount}ریال',style: TextStyle(color: PColor.blueparto,fontSize: 14,fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Divider(color: Colors.white,thickness: 2,height: 4,indent: 5,endIndent: 5,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('مبلغ قابل پرداخت',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.normal),),
                            Text('${(widget.amount).toInt()}ریال',style: TextStyle(color: PColor.blueparto,fontSize: 16,fontWeight: FontWeight.bold),),


                          ],
                        ),
                        Divider(color: Colors.white,thickness: 2,height: 4,indent: 5,endIndent: 5,),
                        widget.canUseWallet?Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('موجودی کیف پول',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.normal),),
                            Text('${(widget.walletAmount).toInt()}ریال',style: TextStyle(color: PColor.blueparto,fontSize: 16,fontWeight: FontWeight.bold),),


                          ],
                        ):
                            Container(height: 0,),





                        _errorText.isNotEmpty?
                            Container(
                              margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
                              padding: EdgeInsets.all(5),
                              color: Colors.red.shade900,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.yellow,
                                    foregroundColor: Colors.red,
                                    child: Icon(Icons.error_outline_rounded,size: 40,),
                                  ),
                                  Text(_errorText,style: TextStyle(color: Colors.white),softWrap: true,)
                                ],
                              ),
                            ):
                            Container(height: 0,)







                      ],
                    )
                ),
                Positioned(
                  //top: -15,
                    right: MediaQuery.of(context).size.width/4*3/2-25,
                    child:
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: PColor.blueparto,
                        child: Icon(Icons.close_rounded,size: 30,color: Colors.white,),

                      ),

                    )
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children:
                      widget.canUseWallet?[
                        CButton(
                        label: 'پرداخت با درگاه بانکی',
                          onClick: () async{
                          if(await canLaunch(widget.paymentLink))
                            await launch(widget.paymentLink);
                          else
                            setState(() {
                              _errorText='امکان باز کردن لینک پرداخت وجود ندارد';
                            });



                          },


                      ) ,

                          CButton(
                            label: 'پرداخت با کیف پول', onClick: () {  },
                          )
                      ]:[
                        CButton(
                          label: 'پرداخت با درگاه بانکی',
                          onClick: () async{
                            if(await canLaunch(widget.paymentLink))
                              await launch(widget.paymentLink);
                            else
                              setState(() {
                                _errorText='امکان باز کردن لینک پرداخت وجود ندارد';
                              });



                          },


                        ) ,

                      ]
                    )
                )


              ],

            )

        )
    );
  }
}