import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextAlign textAlign;
  final int maxLenght;
  final TextInputType keyboardType;
  final String hint;

  const CTextField({ Key key, this.controller,  this.textAlign=TextAlign.center,this.maxLenght=50,this.keyboardType=TextInputType.text,this.hint=''}):super(key: key) ;
  @override
  _CTextFieldState createState() => _CTextFieldState();
}

class _CTextFieldState extends State<CTextField> {
  @override
  Widget build(BuildContext context) {
    return
      TextField(
        decoration: InputDecoration(
          hintText: widget.hint,
            counter: Offstage(),
            counterText: ''
        ),
        onChanged: (v){
          if(v.length==widget.maxLenght)
            FocusScope.of(context).unfocus();

        },

        controller: widget.controller,
        textAlign: widget.textAlign,
        maxLength: widget.maxLenght,
        keyboardType: widget.keyboardType,
      );


  }
}
