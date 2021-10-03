import 'dart:convert';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
import 'package:flutter/material.dart';
import 'package:pardakht_parto/Pages/wallet.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/classes/global_variables.dart';
import 'package:pardakht_parto/classes/profile.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:http/http.dart' as http;

class WalletWidget extends StatefulWidget {


  const WalletWidget({Key key}) : super(key: key);
  @override
  _WalletWidgetState createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> with TickerProviderStateMixin {
  Future<SharedPreferences> _prefs=SharedPreferences.getInstance();
  double _walletAmount=0;
  bool _flag = false;

  Future<void> setWalletAmount() async{
   // debugPrint('Start updating wallet amount====================================================');

    auth.checkAuth().then((value) async{
      if (value) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String _sign = _prefs.getString('sign');
        String _token = _prefs.get('token');
        var _body={
          "LocalDate": DateTime.now().toString(),
          "Sign": _sign,
          "UseWallet": true
        };
        var _jBody=json.encode(_body);
        var result = await http.post(
           Uri.parse( '${globalVars.srvUrl}/Api/Charge/GetOwnerInfo'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: _jBody
        );
        if (result.statusCode==401)
        {
          auth.retryAuth().then((value) {
            setWalletAmount();
          });
        }
        if(result.statusCode==200){
          //debugPrint(result.body);
          var jres=json.decode(result.body);
          if(jres['ResponseCode']==0){
            var x=profileInfoFromJson(result.body);


            //_prefs.setDouble('wallet_amount', x.deviceInfo.credit);
            globWalletAmount=x.deviceInfo.credit>0?getMoneyByRial((x.deviceInfo.credit/10).toInt()):"0" ;






          }

        }
      }
    });


  }
  @override
  Widget build(BuildContext context) {
    return
      Directionality(textDirection: TextDirection.rtl,
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.width/6,

                width: MediaQuery.of(context).size.width/6,

                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/wallet.png'),alignment: Alignment.center,fit: BoxFit.contain),

                ),

              ),
              Text('موجودی (تومان)',textScaleFactor: 0.7,),
              Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  border: Border.all(style: BorderStyle.solid,width: 2,color: Color.fromRGBO(224, 114, 67, 1)),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  /* boxShadow: [
                      BoxShadow(color: Color.fromRGBO(38, 63, 93, 1),offset: Offset(0,0),blurRadius: 3,spreadRadius: 3)
                    ],*/
                  color: Colors.white54,


                ),
                child: Row(
                  children: [
                    Expanded(child: Center(child: Text('$globWalletAmount'),)),
                    Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: PColor.orangeparto,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                              backgroundColor: PColor.blueparto,
                              radius: 13,


                              child: GestureDetector(
                                child: Icon(Icons.add,color: Colors.white,size: 16,),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => WalletPage(),));



                                },
                              )

                            //Icon(Icons.refresh,color: Colors.white,size: 18,),
                          ),
                          Padding(padding: EdgeInsets.only(left: 3),),
                          CircleAvatar(
                              backgroundColor: PColor.blueparto,
                              radius: 13,


                              child: GestureDetector(
                                child: isWalletAmountUpdating?CircularProgressIndicator():Icon(Icons.refresh,color: Colors.white,size: 16,),
                                onTap: () async{

                                  await setWalletAmount();
                                  setState(() {
                                    isWalletAmountUpdating=false;
                                  });

                                },
                              )

                            //Icon(Icons.refresh,color: Colors.white,size: 18,),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )



            ],
          )


      );
  }

}

