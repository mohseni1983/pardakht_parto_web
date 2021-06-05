import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegPageHeaderBack extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return
      Stack(
      children: <Widget>[
        Pinned.fromSize(
          bounds: Rect.fromLTWH(0.0, 0.0, 375.0, 193.0),
          size: Size(375.0, 193.0),
          pinLeft: true,
          pinRight: true,
          pinTop: true,
          pinBottom: true,
          child: SvgPicture.string(
            _svg_d4f59c,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(0.0, 0.0, 279.0, 189.7),
          size: Size(375.0, 193.0),
          pinLeft: true,
          pinTop: true,
          pinBottom: true,
          fixedWidth: true,
          child: SvgPicture.string(
            _svg_r0ksmp,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(0.0, 0.0, 246.3, 140.0),
          size: Size(375.0, 193.0),
          pinLeft: true,
          pinTop: true,
          fixedWidth: true,
          fixedHeight: true,
          child: SvgPicture.string(
            _svg_tz1j4a,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}

const String _svg_d4f59c =
    '<svg viewBox="0.0 0.0 375.0 193.0" ><path transform="translate(3501.0, 2926.0)" d="M -3125.999755859375 -2733.00048828125 L -3126.000732421875 -2733.00048828125 L -3126.001708984375 -2733.00048828125 C -3126.000732421875 -2739.1337890625 -3128.395263671875 -2744.90673828125 -3132.744384765625 -2749.255859375 C -3137.09326171875 -2753.604736328125 -3142.8662109375 -2755.999755859375 -3149.000244140625 -2755.999755859375 L -3477.999755859375 -2755.999755859375 C -3490.516845703125 -2755.999755859375 -3500.833740234375 -2745.819091796875 -3500.998046875 -2733.3056640625 L -3501 -2926 L -3125.999755859375 -2926 L -3125.999755859375 -2733.00048828125 Z" fill="#e07243" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_r0ksmp =
    '<svg viewBox="0.0 0.0 279.0 189.7" ><path transform="translate(3501.0, 2926.0)" d="M -3500.998046875 -2736.2919921875 L -3501 -2736.2919921875 L -3501 -2926 L -3227.62158203125 -2926 C -3223.89111328125 -2911.21142578125 -3222 -2895.9033203125 -3222 -2880.50048828125 C -3222 -2857.307861328125 -3226.22607421875 -2834.686279296875 -3234.56103515625 -2813.263916015625 C -3238.576171875 -2802.944580078125 -3243.559814453125 -2792.91845703125 -3249.373779296875 -2783.464599609375 C -3255.12548828125 -2774.111572265625 -3261.75732421875 -2765.2080078125 -3269.0849609375 -2757.000732421875 L -3479.99951171875 -2757.000732421875 C -3491.42138671875 -2757.000732421875 -3500.84130859375 -2747.7109375 -3500.998046875 -2736.2919921875 Z" fill="#ffffff" fill-opacity="0.2" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_tz1j4a =
    '<svg viewBox="0.0 0.0 246.3 140.0" ><path transform="translate(3400.0, 2740.0)" d="M -3326.5 -2600.000244140625 C -3352.758056640625 -2600.000244140625 -3377.66259765625 -2605.41796875 -3400.000244140625 -2615.12158203125 L -3400.000244140625 -2739.999755859375 L -3153.7236328125 -2739.999755859375 C -3165.68896484375 -2660.869384765625 -3238.48486328125 -2600.000244140625 -3326.5 -2600.000244140625 Z" fill="#ffffff" fill-opacity="0.2" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
