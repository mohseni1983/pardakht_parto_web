import 'dart:ui';
import 'package:pardakht_parto/ui/cust_colors.dart';
import 'package:flutter/material.dart';

class CButton extends StatefulWidget {
  final VoidCallback onClick;
  final String label;
  final double minWidth;
  final Color color;
  final Color textColor;
  final double textScaleFactor;
  final double fontSize;

  const CButton({Key key, this.textScaleFactor=1,this.fontSize=14, this.onClick,  this.label, this.minWidth=40,this.color=PColor.blueparto,this.textColor=Colors.white,}) :super(key: key);
  @override
  _CButtonState createState() => _CButtonState();
}

class _CButtonState extends State<CButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(

      animationDuration: Duration(seconds: 1),
        color: widget.color,
        height: 45,
        minWidth: widget.minWidth,
        splashColor: widget.textColor,
        elevation: 2,
        textColor: widget.textColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: BorderSide(color: Colors.red)
        ),
        //textTheme: ButtonTextTheme.primary,
        child: Text(widget.label,style: TextStyle(fontWeight: FontWeight.w700,fontSize:widget.fontSize),textScaleFactor: widget.textScaleFactor,),
        onPressed: widget.onClick);
  }
}
