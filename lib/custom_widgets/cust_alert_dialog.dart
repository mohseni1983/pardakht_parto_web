

import 'package:flutter/material.dart';
import 'package:pardakht_parto/custom_widgets/cust_button.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';

class CAlertDialog extends StatefulWidget {
  final String content;
  final String subContent;
  final List<Widget> buttons;

  const CAlertDialog({ Key key,  this.content,   this.buttons, this.subContent=''}):super(key: key) ;
  @override
  _CAlertDialogState createState() => _CAlertDialogState();
}

class _CAlertDialogState extends State<CAlertDialog> {

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
                  height: 200,
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
                      Text(
                        '${widget.content}',
                        style: TextStyle(
                            color: PColor.blueparto,
                            fontWeight: FontWeight.w700,
                            fontSize: 16

                        ),
                        softWrap: true,
                      ),
                       widget.subContent !=null?
                      Text(
                        '${widget.subContent}',
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.white,),textAlign: TextAlign.center,
                      ):
                          Container(
                            height: 0,
                          )
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
                      children: widget.buttons ,
                    )
                )


              ],

            )

        )
    );
  }
}
