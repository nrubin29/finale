// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const spotifyGreen = Color.fromRGBO(30, 215, 96, 1);

SvgPicture getLastfmIcon(Color color) => SvgPicture.asset(
      'assets/images/lastfm.svg',
      color: color,
      width: 24,
    );
