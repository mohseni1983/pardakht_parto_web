import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:pardakht_parto/components/maintemplate_withoutfooter.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:url_launcher/url_launcher.dart';
class SupportPage extends StatefulWidget {
  const SupportPage({Key key}) : super(key: key);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  //method for grab app version
  String _version = '';
 Future<void> getInfo() async {
    final PackageInfo _info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${_info.version}.${_info.buildNumber}';
    });
  }


  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Widget build(BuildContext context) {
    return         Stack(
      alignment: Alignment.center,
      children: [
        MasterTemplateWithoutFooter(
          wchild: Center(
            child: Container(
              padding: EdgeInsets.all(6),
              child:             Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('اپلیکیشن پرداخت پرتو',textScaleFactor: 1.3,style: TextStyle(color: PColor.blueparto,fontWeight: FontWeight.w900),),
                  Text('نسخه: $_version',textScaleFactor: 0.8,),
                  Divider(endIndent: 5,indent: 5,thickness: 0.8,),
                  Text('پرتو، چکیده ای از کلیه خدمات پرداخت ها و خدمات بانکی در دستان شماست.',softWrap: true,),
                  Text('از طریق اپلیکیشن پرتو به راحتی می توانید گستره ایده آلی از خدمات پرداخت را با اطمینان کامل از حفظ محرمانگی اطلاعات شخصی و مالی خود، انجام دهید.',softWrap: true,),
                  Divider(endIndent: 5,indent: 5,thickness: 0.8,),
                  GestureDetector(
                    child: Text('www.partopay.app',style: TextStyle(color: Colors.blue,fontStyle: FontStyle.italic),),
                    onTap: () async{
                      await launch('https://partopay.app');
                    },
                  )


//https://partopay.app/
                ],
              ),

            )
          ),

        ),

      ],
    );

  }

}
