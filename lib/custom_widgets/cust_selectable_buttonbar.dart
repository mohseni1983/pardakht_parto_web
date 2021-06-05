import 'package:flutter/material.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';

class CSelectedButton extends StatefulWidget {
  final double height;
  final String  label;
  final Color selectedColor;
  final Color color;
  final Color textColor;
  final Color selectedTextColor;
  final int value;
  final Function(int tval) onPress;
  final int selectedValue;
  const CSelectedButton({Key key, this.height=50,  this.selectedColor=PColor.blueparto,
    this.color=PColor.orangeparto,   this.label,this.value=-1,
    this.textColor=PColor.blueparto,this.selectedTextColor=Colors.white,
     this.onPress,
     this.selectedValue
  }) : super(key: key);

  @override
  _CSelectedButtonState createState() => _CSelectedButtonState();
}

class _CSelectedButtonState extends State<CSelectedButton> {
  @override
  Widget build(BuildContext context) {
    return             Expanded(child:
    Container(
      padding: EdgeInsets.only(left: 2,right: 2),
      child:     MaterialButton(

          height: widget.height,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),

          ),
          color: widget.selectedValue==widget.value?widget.selectedColor:widget.color,
          elevation: widget.selectedValue==widget.value?5:0,
          child: Center(
            child:
            Text(widget.label,style: TextStyle(
                color: widget.selectedValue==widget.value?widget.selectedTextColor:widget.textColor, fontSize:widget.label.length<15? 12:8,fontWeight: widget.selectedValue==widget.value?FontWeight.bold:FontWeight.normal
            ),textAlign: TextAlign.center,),
          ),


          onPressed: (){
            setState(() {
              widget.onPress(widget.value);
            });
          }
      )
      ,
    )

    );

  }
}
