import 'package:flutter/material.dart';
import 'package:pardakht_parto/ui/cust_colors.dart';

class CSeletableImageGridBtn extends StatefulWidget {
  final double height;
  final Color selectedColor;
  final Color color;
  final int value;
  final Function(int tval) onPress;
  final int selectedValue;
  final double paddingHorizontal;
  final double paddingVertical;
  final double width;
  final String colorImage;
  final String grayImage;
  const CSeletableImageGridBtn({Key key, this.height=50,  this.selectedColor=PColor.blueparto,
    this.color=PColor.orangeparto,this.value=-1,
     this.onPress,
     this.selectedValue,
    this.paddingHorizontal=1,
    this.paddingVertical=1,
    this.width=50,
     this.colorImage,
     this.grayImage

  }) : super(key: key);

  @override
  _CSeletableImageGridBtnState createState() => _CSeletableImageGridBtnState();
}

class _CSeletableImageGridBtnState extends State<CSeletableImageGridBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:
      Container(height: widget.height,
          width: widget.width,
          padding: EdgeInsets.only(top: widget.paddingVertical,bottom: widget.paddingVertical,left: widget.paddingHorizontal,right: widget.paddingHorizontal),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: widget.selectedValue==widget.value?AssetImage(widget.colorImage):AssetImage(widget.grayImage),
              fit: BoxFit.cover
            ),

            color: widget.selectedValue==widget.value?widget.selectedColor:widget.color,
          ),
          margin: EdgeInsets.all(2),
      ),
      onTap: (){
        setState(() {
          widget.onPress(widget.value);
        });
      },

    );

  }
}
