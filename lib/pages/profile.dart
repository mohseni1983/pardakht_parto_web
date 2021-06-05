import 'dart:async';
import 'dart:convert';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
import 'package:flutter/material.dart';
import 'package:pardakht_parto/classes/profile.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/custom_widgets/cust_textfield.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:persian_datepicker/persian_datepicker.dart';
import 'package:persian_datepicker/persian_datetime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DeviceInfo _info=new DeviceInfo();
  bool _isEditing=false;
  int _selectedGender=0;
  TextEditingController _fname=new TextEditingController();
  TextEditingController _lname=new TextEditingController();
  TextEditingController _birth=new TextEditingController();



  void getProfile() async{
    setState(() {
      _getingData=true;
    });
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
            getProfile();
          });
        }
        if(result.statusCode==200){
          debugPrint(result.body);
          var jres=json.decode(result.body);
          if(jres['ResponseCode']==0){
            var x=profileInfoFromJson(result.body);
            setState(() {
              _info=x.deviceInfo;
            });
            setState(() {
              if(_info.name.isNotEmpty && _info.name!='نام')
                _fname.text=_info.name;
              if(_info.family.isNotEmpty && _info.family!='نام خانوادگی')
                _lname.text=_info.family;
              _getingData=false;

            });



          }

        }
      }
    });
    return null;


  }
  bool _getingData=false;
  bool _hasError=true;
   PersianDatePickerWidget persianDatePicker;




  @override
  void initState() {
    persianDatePicker = PersianDatePicker(
      controller: _birth,
//      datetime: '1397/06/09',
    ).init();

    getProfile();
    // TODO: implement initState
    super.initState();
  }

  Future<void> saveProfile() async{
    setState(() {
      _getingData=true;
    });
    auth.checkAuth().then((value) async{
      if (value)
        try {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          String _sign = _prefs.getString('sign');
          String _token = _prefs.get('token');
          var _body = {
            "LocalDate": DateTime.now().toString(),
            "Sign": _sign,

            "BirthDate": PersianDateTime(jalaaliDateTime: _birth.text)
                .toGregorian(),
            "Family": _lname.text,
            "Gender": _selectedGender,
            "Name": _fname.text,

          };
          var _jBody = json.encode(_body);
          var result = await http.post(
              Uri.parse('${globalVars.srvUrl}/Api/Charge/ChangeProfile'),
              headers: {
                'Authorization': 'Bearer $_token',
                'Content-Type': 'application/json'
              },
              body: _jBody
          ).timeout(Duration(seconds: 20));
          if (result.statusCode == 200) {
            setState(() {
              _getingData = false;
            });
            getProfile();
            setState(() {
              _isEditing = false;
            });
          }
        }
        on TimeoutException catch(e){
          showDialog(
            context: context,
            builder: (context) =>
                CAlertDialog(
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
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterTemplateWithoutFooter(
      wchild:
        _getingData?
            Center(
              child: Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),

            ):
            !_isEditing?
            Stack(
              children: [
                Column(

                  children: [
                    Padding(padding: EdgeInsets.only(top: 15)),
                    CircleAvatar(
                      minRadius: 30,
                      maxRadius: 40,
                      backgroundColor: PColor.orangeparto,
                      child: Icon(Icons.person_outline_rounded,color: Colors.white,size: 35,),
                    ),
                    Text(
                      'اطلاعات پروفایل کاربری',
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
                    Expanded(child: ListView(
                      padding: EdgeInsets.zero,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text('نام:',style: TextStyle(color: PColor.blueparto),),
                            _info.name!='نام'?Text('${_info.name}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),):Container(width: 0,height: 0,)
                          ],
                        ),
                        Divider(thickness: 0.5,color: PColor.blueparto.shade200,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text('نام خانوادگی:',style: TextStyle(color: PColor.blueparto),),
                            _info.family!='نام خانوادگی'?Text('${_info.family}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),):Container(width: 0,height: 0,)
                          ],
                        ),
                        Divider(thickness: 0.5,color: PColor.blueparto.shade200,),



                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text('شماره تلفن همراه:',style: TextStyle(color: PColor.blueparto),),
                            Text('0${_info.cellNumber}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Divider(thickness: 0.5,color: PColor.blueparto.shade200,),



                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text('جنسیت:',style: TextStyle(color: PColor.blueparto),),
                            Container(height: 30,width: 30,decoration:
                            BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: PColor.orangepartoAccent,
                              image: DecorationImage(
                                image: AssetImage(
                                 _info.gender==0? 'assets/images/man.png':'assets/images/woman.png',

                                ),
                                fit: BoxFit.cover
                              )
                            ),)
                          ],
                        ),
                        Divider(thickness: 0.5,color: PColor.blueparto.shade200,),



                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text('تاریخ تولد:',style: TextStyle(color: PColor.blueparto),),
                            Text('${PersianDateTime.fromGregorian(gregorianDateTime: _info.birthDate.toString().substring(0,10))}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),)
                          ],
                        ),

                        Divider(thickness: 0.5,color: PColor.blueparto.shade200,),



                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text('امتیاز:',style: TextStyle(color: PColor.blueparto),),
                            Text('${_info.point??0}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),)
                          ],
                        ),




                      ],
                    )),
                    GestureDetector(
                      child: Container(
                        height: 45,
                        width: 120,
                        decoration: BoxDecoration(
                            color: PColor.blueparto,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: PColor.orangepartoAccent,width: 2),
                            boxShadow: [
                              BoxShadow(color: PColor.blueparto.shade200,offset: Offset(0,-1),spreadRadius: 2,blurRadius: 5)
                            ]
                        ),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('ویرایش',style: TextStyle(color: Colors.white),),
                            Icon(Icons.edit,color: Colors.white,)
                          ],
                        ),
                      ),
                      onTap: (){
                        setState(() {
                          _isEditing=true;
                        });
                      },
                    )

                  ],
                ),

              ],
            )
                :
            Column(

              children: [
                Padding(padding: EdgeInsets.only(top: 15)),
                CircleAvatar(
                  minRadius: 30,
                  maxRadius: 40,
                  backgroundColor: PColor.orangeparto,
                  child: Icon(Icons.person_outline_rounded,color: Colors.white,size: 45,),
                ),
                Text(
                  'اطلاعات پروفایل کاربری',
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
                Expanded(child: ListView(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('نام:',style: TextStyle(color: PColor.blueparto),),
                        Container(width: MediaQuery.of(context).size.width-100,child:
                        CTextField(textAlign: TextAlign.center,maxLenght: 25,keyboardType: TextInputType.text,controller: _fname,),)
                      ],
                    ),
                    Divider(thickness: 0.5,color: PColor.blueparto.shade200,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('نام خانوادگی:',style: TextStyle(color: PColor.blueparto),),
                        Container(width: MediaQuery.of(context).size.width-100,child:
                        CTextField(textAlign: TextAlign.center,maxLenght: 25,keyboardType: TextInputType.text,controller: _lname,),)
                      ],
                    ),
                    Divider(thickness: 0.5,color: PColor.blueparto.shade200,),



                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('جنسیت:',style: TextStyle(color: PColor.blueparto),),
                        Container(
                            width: 100,
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CSelectableGender(
                                  genderId: 0,
                                  image: AssetImage('assets/images/man.png'),
                                  selectedGender:_selectedGender ,
                                  onPress: (v){
                                    setState(() {
                                      _selectedGender=v;
                                    });
                                  },
                                ),
                                CSelectableGender(
                                  genderId: 1,
                                  image: AssetImage('assets/images/woman.png'),
                                  selectedGender:_selectedGender ,
                                  onPress: (v){
                                    setState(() {
                                      _selectedGender=v;
                                    });
                                  },
                                ),

                              ],
                            )

                        )
                      ],
                    ),
                    Divider(thickness: 0.5,color: PColor.blueparto.shade200,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('تاریخ تولد:',style: TextStyle(color: PColor.blueparto),),
                        Container(width: MediaQuery.of(context).size.width-100,child:
                        TextField(
                          decoration: InputDecoration(
                              counter: Offstage(),
                              counterText: ''
                          ),

                          controller: _birth,
                          textAlign: TextAlign.center,
                          //maxLength: widget.maxLenght,
                          onTap: () {
                            FocusScope.of(context).requestFocus(new FocusNode()); // to prevent opening default keyboard
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                      height: MediaQuery.of(context).size.height/1.7,
                                      child: Column(
                                        children: [
                                          persianDatePicker,
                                          CButton(
                                            label: 'بستن',
                                            onClick: (){
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      )
                                  );
                                });
                          },
                        ))
                      ],
                    ),

                  ],
                )),
                GestureDetector(
                  child: Container(
                    height: 45,
                    width: 120,
                    decoration: BoxDecoration(
                        color: PColor.blueparto,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: PColor.orangepartoAccent,width: 2),
                        boxShadow: [
                          BoxShadow(color: PColor.blueparto.shade200,offset: Offset(0,-1),spreadRadius: 2,blurRadius: 5)
                        ]
                    ),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('ذخیره',style: TextStyle(color: Colors.white),),
                        Icon(Icons.save,color: Colors.white,)
                      ],
                    ),
                  ),
                  onTap: (){
                    if(_fname.text.isNotEmpty && _lname.text.isNotEmpty && _birth.text.isNotEmpty)
                    saveProfile();
                    else
                      showDialog(context: context,
                      builder: (context) => CAlertDialog(
                        content: 'خطا در اطلاعات',
                        subContent: 'اطلاعات را تکمیل کنید',
                        buttons: [CButton(
                          label: 'بستن',
                          onClick: (){
                            Navigator.of(context).pop();
                          },
                        )],
                      ),
                      );
                  },

                )

              ],
            ),







    );
  }
}

class CSelectableGender extends StatefulWidget {
  final int selectedGender;
  final int genderId;
  final AssetImage image;
  final Function(int) onPress;

  const CSelectableGender({Key key,  this.selectedGender,  this.genderId,  this.image,  this.onPress}) : super(key: key);
  @override
  _CSelectableGenderState createState() => _CSelectableGenderState();
}

class _CSelectableGenderState extends State<CSelectableGender> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:
      Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: widget.selectedGender==widget.genderId?PColor.blueparto:PColor.orangepartoAccent,
          borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
                image: widget.image,
                fit: BoxFit.cover
            )



        ),
      ),

      onTap: (){
        widget.onPress(widget.genderId);
      },
    );
  }
}



