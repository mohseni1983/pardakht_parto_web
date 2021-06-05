import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'reg_header_back.dart';

class RegPageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Pinned.fromSize(
          bounds: Rect.fromLTWH(0.0, 0.0, 375.0, 193.0),
          size: Size(375.0, 193.0),
          pinLeft: true,
          pinRight: true,
          pinTop: true,
          pinBottom: true,
          child: RegPageHeaderBack(),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(282.0, 82.0, 59.0, 51.0),
          size: Size(375.0, 193.0),
          pinRight: true,
          fixedWidth: true,
          fixedHeight: true,
          child: Text(
            'ورود ',
            style: TextStyle(
              fontFamily: 'IRANSans(FaNum)',
              fontSize: 22,
              color: const Color(0xffffffff),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(248.0, 125.0, 88.0, 31.0),
          size: Size(375.0, 193.0),
          pinRight: true,
          fixedWidth: true,
          fixedHeight: true,
          child: Text(
            'پرتو پرداخت',
            style: TextStyle(
              fontFamily: 'IRANSans(FaNum)',
              fontSize: 18,
              color: const Color(0xffffffff),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
