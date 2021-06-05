import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class MainIcons extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Pinned.fromSize(
          bounds: Rect.fromLTWH(8.0, 7.0, 150.0, 150.0),
          size: Size(158.0, 157.0),
          pinLeft: true,
          pinRight: true,
          pinTop: true,
          pinBottom: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29.0),
              color: const Color(0xfff8a886),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(0.0, 0.0, 127.0, 118.0),
          size: Size(158.0, 157.0),
          pinLeft: true,
          pinTop: true,
          fixedWidth: true,
          fixedHeight: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.0),
              color: const Color(0x4026445d),
            ),
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(39.0, 126.0, 88.0, 22.0),
          size: Size(158.0, 157.0),
          pinBottom: true,
          fixedWidth: true,
          fixedHeight: true,
          child: Text(
            'شارژ تلفن همراه',
            style: TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 14,
              color: const Color(0xff26445d),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(6.0, 0.0, 114.0, 114.0),
          size: Size(158.0, 157.0),
          pinLeft: true,
          pinTop: true,
          fixedWidth: true,
          fixedHeight: true,
          child:
              // Adobe XD layer: 'simCharge' (shape)
              Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/sim-card.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
