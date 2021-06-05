import 'package:flutter/material.dart';
class OperatorBtn extends StatefulWidget {
  final AssetImage colorImage;
  final AssetImage grayImage;
  final VoidCallback onClick;

  const OperatorBtn({Key key,  this.colorImage,  this.grayImage,  this.onClick}) : super(key: key);

  @override
  _OperatorBtnState createState() => _OperatorBtnState();
}

class _OperatorBtnState extends State<OperatorBtn> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
