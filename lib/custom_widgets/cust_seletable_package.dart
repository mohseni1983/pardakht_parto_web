import 'package:flutter/material.dart';
import 'package:pardakht_parto/classes/convert.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';

class CSelectedPackage extends StatefulWidget {
  final double height;
  final String  label;
  final Color selectedColor;
  final Color color;
  final Color textColor;
  final Color selectedTextColor;
  final int value;
  final Function(int tval) onPress;
  final int selectedValue;
  final double costWithTax;
  final double costWithoutTax;
  
  const CSelectedPackage({Key key, this.height=60,  this.selectedColor=PColor.blueparto,
    this.color=PColor.orangeparto,   this.label,this.value=-1,
    this.textColor=PColor.blueparto,this.selectedTextColor=Colors.white,
     this.onPress,
     this.selectedValue,
     this.costWithoutTax,
     this.costWithTax
    
  }) : super(key: key);

  @override
  _CSelectedPackageState createState() => _CSelectedPackageState();
}

class _CSelectedPackageState extends State<CSelectedPackage> {
  @override
  Widget build(BuildContext context) {
    return    GestureDetector(
      child:
      Container(
        //height: 60,
       // height: widget.height,
        margin: EdgeInsets.all(2),
        //padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
        decoration: BoxDecoration(
          borderRadius:BorderRadius.circular(8) ,
            border: Border.all(color: widget.color,width: 2,style: BorderStyle.solid),
            color: widget.selectedValue==widget.value?PColor.orangeparto:PColor.orangepartoAccent
        ),
        child:
        Column(
          children: [
            Container(

              //margin: EdgeInsets.only(left: 5,right: 5),
              height: 40,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 5,left: 5),
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
                color: widget.color,

              ),
              child:                Text(widget.label.trim(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),textAlign: TextAlign.start,softWrap: true,),

            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.all(2),
                  width: 120,
                  child: Column(
                    children: [
                      Text('قیمت بدون مالیات',textScaleFactor: 0.7,style: TextStyle(color: widget.textColor),),
                      Text('${getMoneyByRial(widget.costWithoutTax.toInt())}ریال',textScaleFactor: 0.7,style: TextStyle(color: widget.textColor),)
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  //color: Colors.white,
                  child: Column(
                    children: [
                      Text('قیمت با مالیات',textScaleFactor: 0.7,style: TextStyle(color: widget.textColor),),
                      Text('${getMoneyByRial(widget.costWithTax.toInt())}ریال',textScaleFactor: 0.7,style: TextStyle(color: widget.textColor),)
                    ],
                  ),
                )

              ],
            )
          ],
        )



        ,
      ),
      onTap: (){
        setState(() {
          widget.onPress(widget.value);
        });
      },

    );

  }
}
