import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pardakht_parto/classes/notification.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/custom_widgets/cust_alert_dialog.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pardakht_parto/classes/auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}
class _NotificationsPageState extends State<NotificationsPage> {
  bool _progressing=false;
  Widget _activeWidget=Container(height: 0,);
  List<OwnerAlert> _notifications=[];
  Future<void> getNotifications() async {
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
            Uri.parse('${globalVars.srvUrl}/Api/Charge/GetOwnerAlerts'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jBody);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            getNotifications();
          });
        }
        if (result.statusCode == 200) {
          debugPrint(result.body);
          var jres = json.decode(result.body);
          debugPrint(jres.toString());
          if (jres["ResponseCode"] == 0)
          {
            if(jres['OwnerAlerts'] != null) {
              var data=notificationsFromJson(result.body).ownerAlerts;
              setState(() {
                _notifications=data;
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


  Future<void> setReadAsTrue(int id) async{
    auth.checkAuth().then((value) async {
      if (value) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String _token = _prefs.getString('token');
        var _body = {
        "AlertId":id,
          "LocalDate": DateTime.now().toString(),
          "Sign": _prefs.getString('sign'),
          "UseWallet": true
        };
        var jBody = json.encode(_body);
        var result = await http.post(
            Uri.parse('${globalVars.srvUrl}/Api/Charge/ChangeAlert'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json'
            },
            body: jBody);
        if (result.statusCode == 401) {
          auth.retryAuth().then((value) {
            setReadAsTrue(id);
          });
        }
        if (result.statusCode == 200) {
          debugPrint(result.body);
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
  Future<bool> _singleNotification(int Id) async{
    var item=_notifications.firstWhere((element) => element.id==Id);
   var res=await showDialog<bool>(context: context, builder: (context) {
      return CAlertDialog(
        content: item.title,
        subContent: item.body,
        buttons: [CButton(label: 'خواندم',onClick: (){
          setReadAsTrue(item.ownerAlertId).then((value) {
            getNotifications().then((value) {
              setState(() {

              });
              Navigator.of(context).pop(true);

            });
          });

          },)],
      );
    },);
return res;

  }

  Widget _notificationList(){
    if(_notifications.length>0){
      return ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
        return           GestureDetector(
          onTap: (){
            setState(() {
              _singleNotification(_notifications[index].id).then((value) {
                if(value){
                  setState(() {
                    _notifications[index].isRead=true;
                  });
                }

              });
            });
          },
          child:
          Card(
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
                        margin: EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: Colors.grey,width: 0.7))
                        ),
                        child:
                        _notifications[index].isRead?Icon(Icons.mark_email_read_rounded,color: Colors.green,):Icon(Icons.mail_rounded,color: Colors.deepOrange,),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_notifications[index].title}',style: TextStyle(color: PColor.orangeparto,fontWeight: FontWeight.bold),textScaleFactor: 1.2,),
                          Text('${_notifications[index].createdOn}',style: TextStyle(color: Colors.grey),textScaleFactor: 0.7,),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        },);
    }else
      return Text('پیامی وجود ندارد');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
        MasterTemplateWithoutFooter(

        // inProgress: _inprogress,
        wchild: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 10)),
            Text(
              'لیست پیامها',
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
            ),
            Divider(
              color: PColor.orangeparto,
              thickness: 2,
            ),
            Expanded(
                child:_notificationList()
            )
          ],
        )),
          _progressing?Progress():Container(height: 0,)
        ]

    );
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();
  }

}
