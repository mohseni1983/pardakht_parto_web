import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
//import 'package:barcode_scan_fork/barcode_scan_fork.dart';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pardakht_parto/classes/bill.dart';
import 'package:pardakht_parto/classes/bill_bookmark.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/classes/profile.dart';
import 'package:pardakht_parto/classes/wallet.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_buttonbar.dart';
import 'package:pardakht_parto/custom_widgets/cust_selectable_image_grid_btn.dart';
//import 'package:pardakht_parto/pages/barcode.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BillsPage extends StatefulWidget {
  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  bool _progressing = false;
  TextEditingController _billId=new TextEditingController();
  TextEditingController _paymentId=new TextEditingController();
  double _billPrice=0;
  String rawBillId='';
  bool _goToBillInfo=false;
  String _mobile='09353619190';
  Future<SharedPreferences> _prefs= SharedPreferences.getInstance();

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
  
String getOrg(int id){
  switch(id){
    case 1:
      return 'قبض آب';
      break;
    case 3:
      return 'قبض گاز';
      break;
    case 2:
      return 'قبض برق';
      break;
    case 4:
      return 'قبض تلفن ثابت';
      break;
    case 5:
      return 'قبض تلفن همراه';
      break;
    case 6:
    case 7:
      return 'قبض عوارض شهرداری';
      break;
    case 8:
      return 'قبض مالیات';
      break;
    case 9:
      return 'قبض جریمه رانندگی';
      break;
    default:
      return 'دیگر قبوض';
      break;


  }
}

  Future scan() async {
    String barcode=await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
    if(barcode=='no barcode'){
      return;
    }
  this._billId.text=barcode.substring(0,13);
  this._paymentId.text=barcode.substring(17);
  double f=double.parse(barcode.substring(13,21));
  this._billPrice=(f*1000) ;
  this._selectedItem=int.parse(barcode.substring(11,12));

/*
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        this._billId.text=barcode.substring(0,13);
        this._paymentId.text=barcode.substring(17);
      double f=double.parse(barcode.substring(13,21));
       this._billPrice=(f*1000) ;
       this._selectedItem=int.parse(barcode.substring(11,12));
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        showDialog(context: context,
        builder: (context) => CAlertDialog(
          content: 'خطا در دوربین',
          subContent: 'اپلیکیشن اجازه دسترسی به دوربین را ندارد',
          buttons: [
            CButton(
              label: 'بستن',
              onClick: (){
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        );
      } else {
        showDialog(context: context,
          builder: (context) => CAlertDialog(
            content: 'خطای ناشناخته',
            subContent: 'در فرآیند خطایی رخ داده است',
            buttons: [
              CButton(
                label: 'بستن',
                onClick: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );      }
    } on FormatException{
      showDialog(context: context,
        builder: (context) => CAlertDialog(
          content: 'خطا در خواندن',
          subContent: 'قبل از خواندن قبض دکمه برگشت زده شده است',
          buttons: [
            CButton(
              label: 'بستن',
              onClick: (){
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );    } catch (e) {
      showDialog(context: context,
        builder: (context) => CAlertDialog(
          content: 'خطای بارکد',
          subContent: 'بارکد اسکن شده معتبر نیست',
          buttons: [
            CButton(
              label: 'بستن',
              onClick: (){
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );        }
*/
  }

  Future<void> saveToFavorite(String billId,String description,int billGroup) async{
    setState(() {
      //  _readyToPay = false;
      _progressing = true;
    });

    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String _token = _prefs.getString('token');
        var _body = {
          "BillGroup": billGroup,
          "BillData":"${billId},$description",
          "LocalDate": DateTime.now().toString(),
          "Sign": _prefs.getString('sign'),
          "UseWallet": true
        };
        var jBody = json.encode(_body);

        var result = await http.post(
            Uri.parse( '${globalVars.srvUrl}/Api/Charge/BillBookmark'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jBody);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            getBillInfo();
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
          debugPrint(jres.toString());

          if (jres["ResponseCode"] == 0)

          {


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

  Widget PayWithBarcode(){
    return
      Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
            color: PColor.orangeparto,
            width: 2,
            style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
        color: PColor.orangepartoAccent,
      ),
      child: Column(
        children: [
          //Padding(padding: EdgeInsets.only(top: 20)),
          Text(
            'اطلاعات قبض',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Divider(
            color: PColor.orangeparto,
            indent: 5,
            endIndent: 5,
            thickness: 2,
          ),
          Row(
            children: [
              Expanded(child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(children: [
                    Container(
                      child:                     Text('شناسه قبض'),
                      width: MediaQuery.of(context).size.width/3.3,
                        ),
                    Expanded(child:
                    Container(height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PColor.blueparto,
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
                    ),
                    child: Text('${_billId.text}',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    )),
                    GestureDetector(
                      child: Container(width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                        color: PColor.blueparto,
                      ),
                        child: Icon(Icons.star,color: PColor.orangeparto,),
                      ),
                      onTap: () async{
                        TextEditingController _desc=new TextEditingController();
                        showDialog(context: context, builder: (context) {
                          return Directionality(textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                title: Text('عنوان قبض منتخب'),
                                content: TextField(
                                  controller: _desc,

                                ),
                                actions: [
                                  CButton(onClick: (){
                                    saveToFavorite(rawBillId, _desc.text, _selectedItem).then((value) => Navigator.of(context).pop());

                                  },label: 'ذخیره',),
                                  CButton(
                                    label:'انصراف',
                                    onClick: (){
                                    Navigator.of(context).pop();
                                  },)
                                ],
                              )
                          );
                        },
                        );
                      },
                    )

                  ],),
                  Padding(padding: EdgeInsets.only(top: 2)),
                  Row(children: [
                    Container(child:                     Text('شناسه پرداخت'),
                      width: MediaQuery.of(context).size.width/3.3,
                    ),
                    Expanded(child:
                    Container(height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: PColor.blueparto,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child:_billPrice>0? Text('${_paymentId.text}',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),):
                      Text('پرداخت شده',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ))

                  ],),
                  Padding(padding: EdgeInsets.only(top: 2)),

                  Row(children: [
                    Container(child:
                    Text('مبلغ'),
                      width: MediaQuery.of(context).size.width/3.3,
                    ),
                    Expanded(child:
                    Container(height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: PColor.blueparto,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child:_billPrice>0? Text('${getMoneyByRial(_billPrice.toInt())}ریال',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),):
                      Text('پرداخت شده',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),

                    ))

                  ],),
                  Padding(padding: EdgeInsets.only(top: 2)),

                  Row(children: [
                    Container(child:                     Text('نوع قبض'),
                      width: MediaQuery.of(context).size.width/3.3,
                    ),
                    Expanded(child:
                    Container(height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: PColor.blueparto,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Text('${getOrg(_selectedItem)}',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ))

                  ],),


                ],
              )),
            ],
          )
        ],
      ),
    );

  }

  int _selectedItem=-1;
  Widget PayWithOpetions(){
    return                   Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            BillInfoWidget(_selectedItem),

            Container(height: 220,
            child: GridView.count(crossAxisCount: 4,
            mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              children: [
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/logo/Ab-color.jpg',
                  grayImage: 'assets/images/logo/Ab-gray.jpg',
                  value: 1,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                      _billId.text='';
                      _selectedOption=-1;

                    });
                  },
                ),
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/logo/gaz-color.jpg',
                  grayImage: 'assets/images/logo/gaz-gray.jpg',
                  value: 3,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                      _billId.text='';
                      _selectedOption=-1;
                    });
                  },
                ),
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/logo/Bargh-color.jpg',
                  grayImage: 'assets/images/logo/Bargh-gray.jpg',
                  value: 2,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                      _billId.text='';
                      _selectedOption=-1;
                    });
                  },
                ),
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/mci-color.jpg',
                  grayImage: 'assets/images/mci-gray.jpg',
                  value: 5,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                     // _billId.text=_mobile;

                      _selectedOption=-1;
                    });
                  },
                ),
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/logo/mokhaberat-color.jpg',
                  grayImage: 'assets/images/logo/mokhaberat-grayr.jpg',
                  value: 4,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                      _billId.text='';
                      _selectedOption=-1;
                    });
                  },
                ),
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/logo/maliat-color.jpg',
                  grayImage: 'assets/images/logo/maliat-gray.jpg',
                  value: 8,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                      _billId.text='';
                      _selectedOption=-1;
                    });
                  },
                ),
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/logo/shahrdary-color.jpg',
                  grayImage: 'assets/images/logo/shahrdary-gray.jpg',
                  value: 7,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                      _billId.text='';
                      _selectedOption=-1;


                    });
                  },
                ),
                CSeletableImageGridBtn(
                  colorImage: 'assets/images/logo/rahvar-color.jpg',
                  grayImage: 'assets/images/logo/rahvar-gray2.jpg',
                  value: 9,
                  selectedValue: _selectedItem,
                  onPress: (t){
                    setState(() {
                      _selectedItem=t;
                      _billId.text='';
                      _selectedOption=-1;

                    });
                  },
                ),




              ],


            ),
            ),
            Container(
              height: 90,
            ),
          ],
        ));

  }

  Future<String> getContact() async {
    final ContactPicker _contactPicker = new ContactPicker();
    String _phoneNumber=' +*-';
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


  Future<List<BillBookmark>> getFavorite() async{
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String _token = _prefs.getString('token');

        var _body = {

          "LocalDate": DateTime.now().toString(),
          "Sign": _prefs.getString('sign'),
          'BillGroup':_selectedItem

        };
        var jBody = json.encode(_body);


        var result = await http.post(
            Uri.parse( '${globalVars.srvUrl}/Api/Charge/GetBillBookmarks'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
          body: jBody
        );

        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            getFavorite();
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
          //debugPrint(jres.toString());

          if (jres["ResponseCode"] == 0)
          {
            var data=jres['BillBookmarks'];
            if(data!=null) {
              List<BillBookmark> response = billBookmarkFromJson(json.encode(data));
              return showFavoriteDialoge(response);
            }
            return null;
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

  Future<String> getItemFromFavorite(int BillGroupSelected) {
    var res= getFavorite().then((value) =>
        debugPrint(value.toString()));

/*    getFavorite().
    then((res) {
      if(res.length>0){
        return showDialog(context: context, builder: (context) {
          return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
            title: Text('موارد منتخب'),
            content: Container(height: 300,
              child: ListView.builder(
                itemCount: res.length,
                itemBuilder: (context, index) {
                  return CButton(
                    label: '${res[index].title} - ${res[index].code}',
                    onClick: (){
                      return res[index].code;
                    },
                  );
                },),
            ),
          ));
        },);
      }
    });*/
    //res=res.where((element) => element.code==BillGroupSelected);

  }

  void showFavoriteDialoge(List<BillBookmark> data) async{
    return showDialog(context: context, builder: (context) {
      return Directionality(textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('از لیست علاقه مندی ها انتخاب کنید',textScaleFactor: 0.8,),
            content:
            SizedBox(
              height: 300,
              width: 300,
              child:
              ListView.builder(
                itemCount: data.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        color: PColor.orangepartoAccent
                      ),
                      child: Row(children: [
                        Text('${data[index].title}:  '),
                        Text(' ${data[index].code}')
                      ],),
                    ),//Text('${data[index].title} : ${data[index].code}'),
                    onTap: (){
                      setState(() {
                        _billId.text=data[index].code;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },),
            ),
            actions: [CButton(
              label: 'انصراف',
              minWidth: 60,
              onClick: ()=>Navigator.of(context).pop(),
            )],

          ));
    },);
  }

  int _selectedOption=-1;
  Widget BillInfoWidget(int selectedOption){
    switch(selectedOption){
      case 1:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شناسه قبض آب را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
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
                            hintText: 'شناسه 13 رقمی'
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 13,

                        controller: _billId,

                        textAlign: TextAlign.center,
                        onChanged: (v){
                          if(v.length==13)
                            FocusScope.of(context).unfocus();

                        },
                      )
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                     await getFavorite();

                    },
                  ),

                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.barcodeScan,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      scan();
                    },
                  )
                ],
              ),

            ],
          ),
        );
        break;
      case 2:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شناسه قبض برق را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
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
                            hintText: 'شناسه 13 رقمی'
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 13,

                        controller: _billId,

                        textAlign: TextAlign.center,
                        onChanged: (v){
                          if(v.length==13)
                            FocusScope.of(context).unfocus();

                        },

                      )
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await getFavorite();

                    },
                  ),

                  GestureDetector(
                    child: Container(

                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.barcodeScan,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      scan();

                    },
                  )
                ],
              ),

            ],
          ),
        );
        break;
      case 3:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شماره بدنه کنتور گاز را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
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
                            hintText: 'شماره 12 رقمی'
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 12,

                        controller: _billId,

                        textAlign: TextAlign.center,
                        onChanged: (v){
                          if(v.length==12)
                            FocusScope.of(context).unfocus();

                        },

                      )
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await getFavorite();

                    },
                  ),

                  GestureDetector(
                    child: Container(

                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.barcodeScan,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      scan();

                    },
                  )
                ],
              ),

            ],
          ),
        );
        break;
      case 4:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شماره تلفن ثابت با کد شهر را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
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
                            hintText: 'مثال:02187654321'
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 11,

                        controller: _billId,

                        textAlign: TextAlign.center,
                        onChanged: (v){
                          if(v.length==11)
                            FocusScope.of(context).unfocus();

                        },

                      )
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await getFavorite();

                    },
                  ),

                  GestureDetector(
                    child: Container(

                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.contacts,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      getContact().then((value) {
                        setState(() {
                          _billId.text=value;
                        });
                      });

                    },
                  )
                ],
              ),
              Row(
                children: [
                  CSelectedButton(
                    height: 40,
                    selectedValue: _selectedOption,
                    value: 1,
                    label: 'میان دوره',
                    onPress: (t){
                      setState(() {
                        _selectedOption=t;
                      });
                    },
                  ),
                  CSelectedButton(
                    height: 40,
                    selectedValue: _selectedOption,
                    value: 2,
                    label: 'پایان دوره',
                    onPress: (t){
                      setState(() {
                        _selectedOption=t;
                      });
                    },
                  )


                ],
              )

            ],
          ),
        );
        break;
      case 5:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شماره تلفن همراه را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                              gapPadding: 2,
                            ),
                            suffixIcon:
                            GestureDetector(
                              child:  Icon(
                                Icons.sim_card,
                                color: PColor.orangeparto,
                              ),
                              onTap: (){
                                _prefs.then((value) {
                                  setState(() {
                                    _billId.text=value.getString('cellNumber');
                                  });
                                });
                              },
                            ),

                            fillColor: Colors.white,
                            counterText: '',
                            hintText: 'مثال:09123456789'
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 11,

                        controller: _billId,

                        textAlign: TextAlign.center,
                        onChanged: (v){
                          if(v.length==11)
                            FocusScope.of(context).unfocus();

                        },

                      )
                  ),

                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                      var title=await getItemFromFavorite(_selectedItem);
                      setState(() {
                        _billId.text=title;
                      });
                    },
                  ),
                  GestureDetector(
                    child: Container(

                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.contacts,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      getContact().then((value) {
                        setState(() {
                          _billId.text=value;
                        });
                      });

                    },
                  )
                ],
              ),
              Row(
                children: [
                  CSelectedButton(
                    height: 40,
                    selectedValue: _selectedOption,
                    value: 1,
                    label: 'میان دوره',
                    onPress: (t){
                      setState(() {
                        _selectedOption=t;
                      });
                    },
                  ),
                  CSelectedButton(
                    height: 40,
                    selectedValue: _selectedOption,
                    value: 2,
                    label: 'پایان دوره',
                    onPress: (t){
                      setState(() {
                        _selectedOption=t;
                      });
                    },
                  )


                ],
              )

            ],
          ),
        );
        break;
      case 6:
      case 7:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شناسه قبض و پرداخت عوارض شهرداری را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
                      Column(
                        children: [
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
                                hintText: 'شناسه قبض'
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 14,

                            controller: _billId,

                            textAlign: TextAlign.center,
                            onChanged: (v){
                              if(v.length==14)
                                FocusScope.of(context).unfocus();

                            },

                          ),
                          Padding(
                            padding: EdgeInsets.only(top:2),
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
                                hintText: 'شناسه پرداخت'
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 14,

                            controller: _paymentId,

                            textAlign: TextAlign.center,
                            onChanged: (v){
                              if(v.length==14)
                                FocusScope.of(context).unfocus();

                            },

                          ),


                        ],
                      )
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await getFavorite();

                    },
                  ),

                  GestureDetector(
                    child: Container(

                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.barcodeScan,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      scan();

                    },
                  )
                ],
              ),

            ],
          ),
        );
        break;
      case 8:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شناسه قبض و شناسه پرداخت مالیات را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
                      Column(
                        children: [
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
                                hintText: 'شناسه قبض'
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 14,

                            controller: _billId,

                            textAlign: TextAlign.center,
                            onChanged: (v){
                              if(v.length==14)
                                FocusScope.of(context).unfocus();

                            },

                          ),
                          Padding(
                            padding: EdgeInsets.only(top:2),
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
                                hintText: 'شناسه پرداخت'
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 14,

                            controller: _paymentId,

                            textAlign: TextAlign.center,
                            onChanged: (v){
                              if(v.length==14)
                                FocusScope.of(context).unfocus();

                            },

                          ),


                        ],
                      )

                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await getFavorite();

                    },
                  ),

                  GestureDetector(
                    child: Container(

                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.barcodeScan,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      scan();

                    },
                  )
                ],
              ),

            ],
          ),
        );
        break;
      case 9:
        return Container(
          decoration: BoxDecoration(
            color: PColor.orangepartoAccent,
            border: Border.all(color: PColor.orangeparto,width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(3),
          child: Column(
            children: [
              Text('شناسه قبض و  پرداخت جریمه رانندگی را وارد کنید'),
              Row(
                children: [
                  Expanded(
                      child:
                      Column(
                        children: [
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
                                hintText: 'شناسه قبض'
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 14,

                            controller: _billId,

                            textAlign: TextAlign.center,
                            onChanged: (v){
                              if(v.length==14)
                                FocusScope.of(context).unfocus();

                            },

                          ),
                          Padding(
                            padding: EdgeInsets.only(top:2),
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
                                hintText: 'شناسه پرداخت'
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 14,

                            controller: _paymentId,

                            textAlign: TextAlign.center,
                            onChanged: (v){
                              if(v.length==14)
                                FocusScope.of(context).unfocus();

                            },

                          ),


                        ],
                      )
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.star,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await getFavorite();

                    },
                  ),

                  GestureDetector(
                    child: Container(

                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.barcodeScan,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                    onTap: () {
                      scan();

                    },
                  )
                ],
              ),

            ],
          ),
        );
        break;



      default:
        return Container(height: 0,);
        break;




    }

  }

  @override
  void initState() {

/*
    _prefs.then((value) => {
      setState((){
        _mobile=value.getString('cellNumber');
      })
    });
*/

    // TODO: implement initState
    super.initState();

  }

  String createBillData() {
    switch(_selectedItem){
      case 1:
      case 2:
      case 3:
      case 6:
      case 7:
      case 8:
      case 9:
        {
/*        if(_billId.text.isEmpty || _billId.text.length<13)
          {
            showDialog(context: context,
              builder: (context) => CAlertDialog(
                content: 'خطا در شناسه',
                subContent: 'شناسه قبض صحیح نیست',
                buttons: [CButton(
                  label: 'بستن',
                  onClick: ()=>Navigator.of(context).pop(),
                )],
              ),
            );
            return '';

          }*/
    //    else{

          setState(() {
            rawBillId=_billId.text;
          });
          //getMobile().then((value) {
            return '$_selectedItem,${_billId.text},$_mobile';
         // });


    //    }

      }
        break;
      case 4:
        if(_billId.text.isEmpty || _billId.text.length<11 || !_billId.text.startsWith('0'))
          {
            showDialog(context: context,
              builder: (context) => CAlertDialog(
                content: 'خطا در شماره',
                subContent: 'شماره تلفن صحیح نیست',
                buttons: [CButton(
                  label: 'بستن',
                  onClick: ()=>Navigator.of(context).pop(),
                )],
              ),
            );
            return '';

          }
        else if(_selectedOption<1)
          {
            showDialog(context: context,
              builder: (context) => CAlertDialog(
                content: 'خطا در انتخاب دوره',
                subContent: 'یک دوره را برای قبض انتخاب کنید',
                buttons: [CButton(
                  label: 'بستن',
                  onClick: ()=>Navigator.of(context).pop(),
                )],
              ),
            );
            return '';

          }
        else
{
  setState(() {
    rawBillId=_billId.text;
  });


  return '4,${_billId.text},${_selectedOption}';
}
        break;
      case 5:
        if(_billId.text.isEmpty || _billId.text.length<11 || !_billId.text.startsWith('09'))
          {
            showDialog(context: context,
              builder: (context) => CAlertDialog(
                content: 'خطا در شماره',
                subContent: 'شماره همراه صحیح نیست',
                buttons: [CButton(
                  label: 'بستن',
                  onClick: ()=>Navigator.of(context).pop(),
                )],
              ),
            );
            return '';

          }
        else if(_selectedOption<1)
          {
            showDialog(context: context,
              builder: (context) => CAlertDialog(
                content: 'خطا در انتخاب دوره',
                subContent: 'یک دوره را برای قبض انتخاب کنید',
                buttons: [CButton(
                  label: 'بستن',
                  onClick: ()=>Navigator.of(context).pop(),
                )],
              ),
            );
            return '';

          }
        else
          {
            setState(() {
              rawBillId=_billId.text;
            });

            return '5,${_billId.text},${_selectedOption}';
          }


        break;




      default:
        showDialog(context: context,
          builder: (context) => CAlertDialog(
            content: 'خطا در انتخاب',
            subContent: 'یک قبض را برای پرداخت انتخاب کنید',
            buttons: [CButton(
              label: 'بستن',
              onClick: ()=>Navigator.of(context).pop(),
            )],
          ),
        );
        setState(() {
          rawBillId=_billId.text;
        });
        return '';
        break;

    }
  }
  Future<void> getMobile() async{
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
            Uri.parse('${globalVars.srvUrl}/Api/Charge/GetOwnerInfo'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: _jBody
        );
        if (result.statusCode==401)
        {
          auth.retryAuth().then((value) {
            getMobile();
          });
        }
        if(result.statusCode==200){
          debugPrint(result.body);
          var jres=json.decode(result.body);
          if(jres['ResponseCode']==0){
            var x=profileInfoFromJson(result.body);
            setState(() {
              _mobile=  '0${x.deviceInfo.cellNumber}';

            });
          }
        }
      }
    });


  }

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
                                          'پرداخت قبض',
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
                                          '${getOrg(_selectedItem)}',
                                          style: TextStyle(
                                              color: PColor.orangeparto,
                                              fontWeight: FontWeight.bold,fontSize: 12),
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
                                          '${getMoneyByRial(_billPrice.toInt())}ریال',
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
                                    '${getMoneyByRial(_billPrice.toInt())}ریال',
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

  Future<void> getBillInfo () async{
    String _billInfo=createBillData();
    if(_billInfo.isNotEmpty)
    {
      setState(() {
        //  _readyToPay = false;
        _progressing = true;
      });
      auth.checkAuth().then((value) async {
        if (value) {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          String _token = _prefs.getString('token');
          var _body = {
            "BillData": _billInfo,
            "LocalDate": DateTime.now().toString(),
            "Sign": _prefs.getString('sign'),
            "UseWallet": true
          };
          var jBody = json.encode(_body);

          var result = await http.post(
             Uri.parse( '${globalVars.srvUrl}/Api/Charge/BillInquiry'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Content-Type': 'application/json'
              },
              body: jBody);
          if (result.statusCode == 401) {
            auth.retryAuth().then((value) {
              getBillInfo();
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
            debugPrint(jres.toString());

            if (jres["ResponseCode"] == 0)

            {
              setState(() {
                _paymentId.text='';

              });
              if(_selectedItem==5 ) {
                var res = billFromJson(result.body);
                var bill=billItemsFromJson(res.bills);

               setState(() {
                  _billId.text = bill.billId;
                  _paymentId.text = bill.paymentId;
                  _billPrice = bill.amount.toDouble();
                  _goToBillInfo = true;
                });
              }else{
                var res=billOtherFromJson(result.body);
                var bill=billOtherItemFromJson(res.bills);
                setState(() {
                  _billId.text=bill.billId;
                  _paymentId.text=bill.payId;
                  _billPrice=bill.amount.toDouble() ;
                  _goToBillInfo=true;
                });
              }
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
          "BillId": _billId.text,
          "PayId": _paymentId.text,
          "LocalDate": DateTime.now().toString(),
          "Sign": _prefs.getString('sign'),
          "UseWallet": true
        };
        var jBody = json.encode(_body);

        var result = await http.post(
           Uri.parse( '${globalVars.srvUrl}/Api/Charge/Bill'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Stack(
        children: [
          MasterTemplateWithoutFooter(

            // inProgress: _inprogress,
              wchild: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 10)),
                  //    Padding(padding: EdgeInsets.only(top: 5)),
                  Text(
                    'پرداخت قبوض',
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    color: PColor.orangeparto,
                    thickness: 2,
                  ),

                  _goToBillInfo?
                      PayWithBarcode():
                      PayWithOpetions(),
                  // بخش مربوط به اطلاعات اصلی
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
                        if(!_goToBillInfo)
                          if(_selectedItem<6)
                          getBillInfo();
                          else
                            setState(() {
                              _billPrice=double.parse(_paymentId.text.substring(0,4))*1000;
                              _goToBillInfo=true;

                            });
                        else if(_goToBillInfo)
                          if(_billPrice>0)
                          getPaymentLink();
                          else
                            showDialog(
                              context: context,
                              builder: (context) => CAlertDialog(
                                content: 'عملیات غیرممکن',
                                subContent: 'قبض قبلا پرداخت شده است',
                                buttons: [
                                  CButton(
                                    label: 'بستن',
                                    onClick: () => Navigator.of(context).pop(),
                                  )
                                ],
                              ),
                            );




                        //    _sendToPayment();

                      },
                      minWidth: 120,
                    ),
                    !_goToBillInfo?
                    CButton(
                      label: 'پرداخت با بارکد',
                      onClick: () {
                        scan();
                        setState(() {
                          _goToBillInfo=true;
                          _billId.text='';
                          _paymentId.text='';

                        });

                        },
                      minWidth: 120,
                    ):
                    CButton(
                      label: 'قبلی',
                      onClick: () {
                       // scan();
                        setState(() {
                          _goToBillInfo=false;
                          _billId.text='';
                          _paymentId.text='';
                        });

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
      )

    );
  }

}
