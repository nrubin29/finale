import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

const spotifyGreen = Color.fromRGBO(30, 215, 96, 1);

SvgPicture getLastfmIcon(Color color) => SvgPicture.asset(
      'assets/images/lastfm.svg',
      color: color,
      width: 24,
    );

String formatScrobbles(int playCount) => Intl.plural(playCount,
    one: '$playCount scrobble', other: '$playCount scrobbles');

final numberFormat = NumberFormat();
final dateFormat = DateFormat('d MMM');
final dateFormatWithYear = DateFormat('d MMM yyyy');
final timeFormat = DateFormat.jms();
final dateTimeFormat = DateFormat('d MMM').add_jm();
final dateTimeFormatWithYear = DateFormat('d MMM yyyy').add_jm();
