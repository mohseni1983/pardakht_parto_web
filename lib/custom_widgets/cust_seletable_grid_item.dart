import 'package:flutter/material.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';

class CSelectedGridItem extends StatefulWidget {
  final double height;
  final String  label;
  final Color selectedColor;
  final Color color;
  final Color textColor;
  final Color selectedTextColor;
  final int value;
  final Function(int tval) onPress;
  final int selectedValue;
  final double paddingHorizontal;
  final double paddingVertical;
  final double width;
  final double textScaleFactor;
  final double fontSize;
  const CSelectedGridItem({Key key, this.height=30,  this.selectedColor=PColor.blueparto,
    this.color=PColor.orangeparto,   this.label,this.value=-1,
    this.textColor=PColor.blueparto,this.selectedTextColor=Colors.white,
     this.onPress,
     this.selectedValue,
    this.paddingHorizontal=1,
    this.paddingVertical=1,
    this.width=80,
    this.textScaleFactor=1,
    this.fontSize=14

  }) : super(key: key);

  @override
  _CSelectedGridItemState createState() => _CSelectedGridItemState();
}

class _CSelectedGridItemState extends State<CSelectedGridItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:
      Container(height: widget.height,
          width: widget.width,
          padding: EdgeInsets.only(top: widget.paddingVertical,bottom: widget.paddingVertical,left: widget.paddingHorizontal,right: widget.paddingHorizontal),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),

            color: widget.selectedValue==widget.value?widget.selectedColor:widget.color,
          ),
          margin: EdgeInsets.all(2),
          child: Center(
            child: Text(widget.label,style: TextStyle(
                color: widget.selectedValue==widget.value?widget.selectedTextColor:widget.textColor,fontSize: widget.fontSize,fontWeight: widget.selectedValue==widget.value?FontWeight.bold:FontWeight.normal,

            ),
              textScaleFactor: widget.textScaleFactor,
            ) ,
          )
      ),
      onTap: (){
        setState(() {
          widget.onPress(widget.value);
        });
      },

    );

  }
}
