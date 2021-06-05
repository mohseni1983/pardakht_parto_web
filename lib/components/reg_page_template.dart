import 'package:flutter/material.dart';

import 'reg_header.dart';
class RegPageTemplate extends StatefulWidget  {
  final List<Widget> children;

  const RegPageTemplate({ Key key,  this.children}):super(key: key) ;
  @override
  _RegPageTemplateState createState() => _RegPageTemplateState();
}

class _RegPageTemplateState extends State<RegPageTemplate>
with TickerProviderStateMixin
{
  @override
  Widget build(BuildContext context) {
    var _screenSize=MediaQuery.of(context).size;

    //debugPrint('Image Loc: ${(145.0*_screenSize.width/375.0)}');
    //debugPrint('Image Height: ${(145.0*_screenSize.width/375.0)}');
    //debugPrint('Container Height: ${ _screenSize.height-(193.0*_screenSize.width/375.0)+30}');

    return
      Directionality(textDirection: TextDirection.rtl,

        child: Scaffold(
          body:
          Stack(
            children: [
              //Bottom Image
              Transform.translate(
                offset: Offset(0.0,(588*_screenSize.height/812)),
                child:
                Container(
                  width: _screenSize.width,//375.0,
                  height: (145.0*_screenSize.width/375.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                      const AssetImage('assets/images/RegisterFooterImg.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              Container(
                width:_screenSize.width ,
                height: _screenSize.height-(193.0*_screenSize.width/375.0),
                margin: EdgeInsets.only(top: (193.0*_screenSize.width/375.0)-25),
                padding: EdgeInsets.only(left: 35,right: 35),
                //color: Colors.green,
                child: ListView(
                  children: widget.children,
                ),
              ),

              //Header for Register Pages
              SizedBox(
                width: _screenSize.width,
                height: (193.0*_screenSize.width/375.0),
                child: RegPageHeader(),
              ),


            ],
          )
          ,
        )
    );
  }
}
