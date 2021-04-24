import 'package:flutter/material.dart';
import 'package:academia_do_rock_app/src/academia_do_rock_app.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  timeago.setLocaleMessages('pt_BR_short', timeago.PtBrShortMessages());
  runApp(AcademiaDoRockApp());
}
// void main() => runApp(AcademiaDoRockApp());
