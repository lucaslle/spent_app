import 'package:flutter/widgets.dart';

extension SeparatedChildren on List<Widget> {
  List<Widget> withGap(double gap, {bool horizontal = false}) => [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) SizedBox(width: horizontal ? gap : 0, height: horizontal ? 0 : gap),
          this[i],
        ],
      ];
}
