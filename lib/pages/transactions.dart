import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pardakht_parto/classes/account_trans.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:persian_datepicker/persian_datepicker.dart';
import 'package:persian_datepicker/persian_datetime.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share/share.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  GlobalKey _globalKey = new GlobalKey();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _progressing=false;
  TextEditingController _startDatePicker=new TextEditingController();
  TextEditingController _endDatePicker=new TextEditingController();
   PersianDatePickerWidget _startPickerWidget;
   PersianDatePickerWidget _endPickerWidget;
  List<TxnInfoListElement> _transList=[];
  int _transCount=0;
  PersianDateTime getPersianDate(DateTime dateTime){
    intl.DateFormat formatter = intl.DateFormat('yyyy-MM-dd');
    PersianDateTime todayPersianDate=PersianDateTime.fromGregorian(gregorianDateTime: formatter.format(dateTime));
    return todayPersianDate;
  }

  @override
  void initState() {
    // TODO: implement initState


    _startPickerWidget=PersianDatePicker(
      controller: _startDatePicker,
      fontFamily: 'Dirooz',
      datetime: getPersianDate(DateTime.now().add(Duration(days: -1))).toString(),
      headerTodayBackgroundColor: PColor.orangeparto,
      farsiDigits: false,
      headerBackgroundColor: PColor.orangeparto,
      headerTodayIcon: Icon(Icons.today_rounded,color: PColor.blueparto,),
      selectedDayBackgroundColor: PColor.orangepartoAccent,
      weekCaptionsBackgroundColor: PColor.blueparto,
      rangeDatePicker: false,

    ).init();
    _endPickerWidget=PersianDatePicker(
      controller: _endDatePicker,
      fontFamily: 'Dirooz',
      farsiDigits: false,

      datetime: getPersianDate(DateTime.now()).toString(),
      headerTodayBackgroundColor: PColor.orangeparto,
      headerBackgroundColor: PColor.orangeparto,
      headerTodayIcon: Icon(Icons.today_rounded,color: PColor.blueparto,),
      selectedDayBackgroundColor: PColor.orangepartoAccent,
      weekCaptionsBackgroundColor: PColor.blueparto,
      rangeDatePicker: false,

    ).init();


    super.initState();
    setState(() {
      _progressing=true;
      getAcountTransactions(pageNumber: _currentPage,
          startDate: DateTime.now().add(Duration(days: -365)),
          endDate: DateTime.now(),
          pageSize: 15).then((value) {
            setState(() {

            });
      });


    });
  }
  //???????????? ???????????? ???? ???????? ?????? ???????????? ??????????????
  bool _inprogress = false;
  Widget Progress()=>
      Material(
        color: Colors.transparent,
        child:    Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: PColor.orangeparto.withOpacity(0.8),
          child: Center(
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(height: 30,width: 30,child: CircularProgressIndicator(),),
                Text('???? ?????? ???????????? ??????????????',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),textScaleFactor: 1.4,)
              ],
            ),
          ),
        ),

      );
  String getOrg(int id){
    switch(id){
      case 1:
        return '?????? ????';
        break;
      case 3:
        return '?????? ??????';
        break;
      case 2:
        return '?????? ??????';
        break;
      case 4:
        return '?????? ???????? ????????';
        break;
      case 5:
        return '?????? ???????? ??????????';
        break;
      case 6:
      case 7:
        return '?????? ?????????? ??????????????';
        break;
      case 8:
        return '?????? ????????????';
        break;
      case 9:
        return '?????? ?????????? ??????????????';
        break;
      default:
        return '???????? ????????';
        break;


    }
  }


  Widget _reportDialog(TxnInfoListElement _recipt) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),



      ),
      backgroundColor: PColor.blueparto,
      child:    Directionality(
        textDirection: TextDirection.rtl,
        child:       Material(
          color: Colors.transparent,
          child: Container(
            //height: MediaQuery.of(context).size.height * 0.7 + 30,
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  //width: MediaQuery.of(context).size.width - 30,
                  padding: EdgeInsets.only(top: 5, left: 5, right: 5),
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
                        child:
                        ListView(
                          children: [
                            Text(
                              '?????????????? ????????????',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textScaleFactor: 1.3,
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
                              child: RepaintBoundary(
                                key: _globalKey,
                                child:
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('?????? ????????????',style: TextStyle(color: Colors.white,fontSize: 12),),

                                      ],
                                    ),
                                    Container(
                                      child: Text('${_recipt.description}',style: TextStyle(color: PColor.orangepartoAccent,fontSize: 10),textAlign: TextAlign.right,),
                                    ),
                                    Divider(height: 1,thickness: 0.5,color: Colors.white,),

                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('?????? ????????????',style: TextStyle(color: PColor.blueparto,fontSize: 14,fontWeight: FontWeight.w900),),
                                          Text('${getTransactionType(_recipt.requestType).name}',style: TextStyle(color: PColor.blueparto,fontSize: 14,fontWeight: FontWeight.w900),),

                                        ],
                                      ),
                                    ),
                                    _recipt.requestType==0?
                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('?????????? ??????????',style: TextStyle(color: PColor.blueparto,fontSize: 14,fontWeight: FontWeight.w900),),
                                          Text('${_recipt.cellNumber}',style: TextStyle(color: PColor.blueparto,fontSize: 14,fontWeight: FontWeight.w900),),

                                        ],
                                      ),
                                    ):
                                    Container(height: 0,),
                                    _recipt.billGroup!=0?
                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('?????? ??????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),
                                          Text('${getOrg(_recipt.billGroup)}',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),

                                        ],
                                      ),
                                    ):
                                    Container(height: 0,),
                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('????????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),
                                          Text('${getMoneyByRial(_recipt.amount.toInt()) } ????????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),

                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('?????????? ??????????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),
                                          Text('${_recipt.requestDate}',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),textDirection: TextDirection.ltr,),

                                        ],
                                      ),
                                    ),
                                    _recipt.useWallet?
                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('?????? ????????????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),
                                          Text('???????????? ?????? ??????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),textDirection: TextDirection.ltr,),

                                        ],
                                      ),
                                    ):


                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('?????????? ????????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),
                                          Text('${_recipt.cardNumber}',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),textDirection: TextDirection.ltr,),

                                        ],
                                      ),
                                    ),
                                    _recipt.useWallet?
                                    Container(height: 0,):
                                    Container(
                                      padding:EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: PColor.orangepartoAccent,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('????????????',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),
                                          Text('${_recipt.traceNumber}',style: TextStyle(color: PColor.blueparto,fontSize: 12,fontWeight: FontWeight.w900),),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                              )
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
                              label: '???????????? ?????????? ??????',
                              fontSize: 10,
                              minWidth: 90,

                              color: PColor.orangeparto,
                              textColor: Colors.white,
                              onClick: () async{
                                var _msg='???????????????? ???????????? ????????' +'\r\n';
                                _msg+='????????: ${getMoneyByRial(_recipt.amount.toInt())}????????'+'\r\n';
                                _msg+='?????? ????????????: ${getTransactionType(_recipt.requestType).name}'+'\r\n';
                                _msg+='??????????: ${_recipt.requestDate}'+'\r\n';
                                if(_recipt.useWallet){
                                  _msg+='???????????? ???? ???????????? ?????? ??????';
                                }else
                                  {
                                    _msg+='????????: ${_recipt.cardNumber}'+'\r\n';
                                    _msg+='????????????: ${_recipt.traceNumber}'+'\r\n';

                                  }
                                _msg+='www.partopay.app';

                                Share.share(_msg);                              },


                            ),
                            CButton(
                              label: '???????????? ?????????? ??????',
                              fontSize: 10,
                              minWidth: 90,

                              color: PColor.orangeparto,
                              textColor: Colors.white,
                              onClick: () async{


    ShareFilesAndScreenshotWidgets().shareScreenshot(
    _globalKey,
    800,
    "Title",
    "Name.png",
    "image/png",
    text: '???????????????? ???????????? ????????\r\n www.partopay.app');
    }





                            ),


                          ],
                        ),

                        //  color: Colors.red,
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CButton(
                              label: '????????',
                              fontSize: 12,
                              minWidth: 90,
                              color: PColor.orangeparto,
                              textColor: Colors.white,
                              onClick: (){
                                Navigator.of(context).pop();


                              },
                            )

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      )

    )
    ;

  }





  //?????? ???????????? ???????? ???????????? ?????? ?????? ??????
  Future<void> getAcountTransactions({ int pageNumber, DateTime startDate, DateTime endDate, int pageSize}) async{
    setState(() {
      isLoading=true;

    });
    auth.checkAuth().then((value) async{
      if (value)
        try
        {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          String _sign = _prefs.getString('sign');
          String _token = _prefs.get('token');
          var _body={
            "LocalDate": DateTime.now().toString(),
            "Sign": _sign,
            "UseWallet": true,
            "CurrentPage": pageNumber,
            "DateFrom": startDate.toString(),
            "DateTo": endDate.toString(),
            "PageSize": pageSize,
            "UseWallet": true

          };
          var _jBody=json.encode(_body);
          var result = await http.post(
              Uri.parse('${globalVars.srvUrl}/Api/Charge/GetTxnInfo'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Content-Type': 'application/json'
              },
              body: _jBody
          ).timeout(Duration(seconds: 20));
          if (result.statusCode==401)
          {
            auth.retryAuth().then((value) {
              getAcountTransactions(pageNumber: pageNumber,startDate: startDate,endDate: endDate,pageSize: pageSize);
            });
          }
          if(result.statusCode==200){
            setState(() {
              _progressing=false;
              isLoading=false;
            });
            debugPrint(result.body);
            var jres=json.decode(result.body);
            debugPrint(jres.toString());


            if(jres['ResponseCode']==0){
              var _financeList=jres['TxnInfoList'];
              debugPrint(jres.toString());
              AcountTransTxnInfoList _list= AcountTransTxnInfoList.fromJson(_financeList);
              setState(() {
                _transCount=_list.totalCounts;
                _transList.addAll(_list.txnInfoLists);
              });
            }


          }
        }
        on TimeoutException catch(e){
          showDialog(
            context: context,
            builder: (context) =>
                CAlertDialog(
                  content: '???????? ????????????',
                  subContent: '???????????? ???? ???????? ???? ???????? ??????',
                  buttons: [
                    CButton(
                      label: '????????',
                      onClick: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
          );
        }
    });
  }

  bool isLoading=false;
  int pageSize=10;
  int _currentPage=1;
  Widget MakeListOfTrans(){
    return
      NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              // start loading data
              if(_currentPage<=(_transCount/pageSize).ceil())
              {
                setState(() {
                  _currentPage++;
                  isLoading = true;
                });
                getAcountTransactions(pageNumber: _currentPage,
                    startDate: DateTime.now().add(Duration(days: -365)),
                    endDate: DateTime.now(),
                    pageSize: pageSize);
              }
            }
            return true;
          },



          child:         ListView.builder(
            //shrinkWrap: true,

            itemCount: _transList.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              var _item=_transList[index];
              return
              GestureDetector(
                child:                 Container(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    //height: 100,
                    //color: Colors.green,
                    margin: EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                        color: PColor.orangepartoAccent,
                        borderRadius: BorderRadius.circular(12)

                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 4,
                          height: 67,
                          decoration: BoxDecoration(
                              color: _item.isCharge?Colors.green:Colors.red,
                              borderRadius: BorderRadius.horizontal(left:Radius.circular(12) )

                          ),

                        ),
                        Container(
                          width: 10,
                        ),
                        Expanded(child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [


                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _item.useWallet?
                                    Icon(Icons.account_balance_wallet,color: PColor.orangeparto):
                                    Icon(Icons.credit_card,color: PColor.orangeparto,),
                                    Text('${_item.requestTypeDetails}',textAlign: TextAlign.right,textScaleFactor: 0.9,style: TextStyle(fontWeight: FontWeight.bold,color: PColor.blueparto),),

                                  ],
                                ),


                                Container(

                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: PColor.orangeparto,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('??????????: ${_item.id}',style: TextStyle(color: PColor.blueparto,fontWeight: FontWeight.bold),textScaleFactor: 0.7,),
                                )

                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_item.requestDate}',style: TextStyle(fontWeight: FontWeight.bold,color: PColor.orangeparto),textScaleFactor: 0.8,),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${getMoneyByRial(_item.amount.toInt())} ????????',style: TextStyle(color: PColor.blueparto),),
                                    // Icon(Icons.check_circle,color: Colors.green.shade600,)
                                  ],
                                ),




                              ],
                            ),
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)

                              ),
                              //height: 60,
                              child: Row(
                                children: [
                                  Container(
                                    //width: 80,
                                    child: Column(
                                      children: [
                                        Text('?????????? ????????????',textScaleFactor: 0.7,),
                                        // Text('${_transList[index].requestType}',textScaleFactor: 0.7,),
                                        _item.isSettle?Icon(Icons.check,color: Colors.green,):Icon(Icons.block_flipped,color: Colors.red,)


                                      ],
                                    ),

                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.keyboard_arrow_left),
                                  ),
                                  Container(
                                    //width: 80,
                                    child: Column(
                                      children: [
                                        Text('?????????? ????????????',textScaleFactor: 0.7,),
                                        // Text('${_transList[index].requestType}',textScaleFactor: 0.7,),
                                        _item.isCharge?Icon(Icons.check,color: Colors.green,):Icon(Icons.block_flipped,color: Colors.red,)


                                      ],
                                    ),

                                  ),
                                  !_item.isCharge?
                                  Container(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.keyboard_arrow_left),
                                  )
                                      :
                                  Container(width: 0,),
                                  !_item.isCharge?
                                  Container(
                                    // width: 80,
                                    child: Column(
                                      children: [
                                        Text('?????????? ??????',textScaleFactor: 0.7,),
                                        //Text('${_item.payRollBackDate}',textScaleFactor: 0.7,),

                                        // Text('${_transList[index].requestType}',textScaleFactor: 0.7,),
                                        _item.isReverse?Icon(Icons.check,color: Colors.green,):Icon(Icons.block_flipped,color: Colors.red,)



                                      ],
                                    ),

                                  )
                                      :
                                  Container(width: 0,),



                                ],
                              ),
                            )
                          ],
                        )
                        ),
                        _item.isSettle?                        Container(
                          alignment: Alignment.center,
                          //width: 20,
                          child: Icon(
                            Icons.arrow_right_outlined,color: PColor.orangeparto,size: 20,
                          ),

                        )
                            :Container(width: 20,height: 0,)


                      ],
                    )
                )
                ,
                onTap: (){
                  showDialog(context: context,
                  builder: (context) => _reportDialog(_item),
                  );
                },
              )
              ;
            },
          )
      );
  }
/*                               GestureDetector(
                                child:
                                Container(
                                  width: 20,
                                  child: Icon(
                                      Icons.arrow_right_outlined
                                  ),

                                ),

                              )
*/
//???????????? ?????? ?? ?????? ?????? ????????????
  TransactionType getTransactionType(int id){
    switch(id){
      case 6:
        return TransactionType(color: Colors.blue,name: '???????? ?????? ??????');
        break;
      case 0:
        return TransactionType(color: Colors.green,name: '???????? ????????????');
        break;
      case 1:
        return TransactionType(color: Colors.green,name: '???????? ?????? ????????????????');
        break;
      case 2:
        return TransactionType(color: Colors.green,name: '???????????? ?????? ????????????');
        break;
      case 3:
        return TransactionType(color: Colors.green,name: '???????? ????????');
        break;
      case 4:
        return TransactionType(color: Colors.green,name: '?????????????? ?????? ????????????');
        break;
      case 14:
        return TransactionType(color: Colors.green,name: '????????????????');
        break;
      default:
        return TransactionType(color: PColor.blueparto,name: '???????????? ?????? $id');
        break;
    }
  }


Widget buttom=Container(height: 0,);


  @override
  Widget build(BuildContext context) {
    return
      Stack(
        children: [
          MasterTemplateWithoutFooter(

            // inProgress: _inprogress,
              wchild: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 15)),
                  Text(
                    '???????????? ?????? ????????',
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline1,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    ' ?????????? ???????????? ????',
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    color: PColor.orangeparto,
                    thickness: 2,
                  ),

                  // ?????? ?????????? ???? ?????????????? ????????
                  Expanded(child:
                  MakeListOfTrans()
                  ),
                  isLoading?
                  Container(
                    height: 10,
                    child: LinearProgressIndicator(),
                  ):
                  Container(height: 0,)



                ],
              )

          ),
          _progressing?
          Progress():Container(height: 0,),

          buttom,

        ],
      );

  }






  @override
  void dispose() {
    this.dispose();
  }




}

class TransactionType{

  String name;
  Color color;

  TransactionType({ this.name, this.color});
}

