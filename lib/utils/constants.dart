import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const grey = Color(0xFFEAEAEA);
const grey2 = Color(0xFF6D6D6D);
const black = Color(0xFF1C1C1C);
const black2 = Color(0xFF424242);
const white = Color.fromRGBO(255, 255, 255, 1);

var headerNotesStyle = GoogleFonts.roboto(
  textStyle: const TextStyle(
    color: black,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  ),
);
enum EditMode {
  // ignore: constant_identifier_names
  ADD,
  UPDATE,
}
var noNotesStyle = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 22.0,
    color: black2,
    fontWeight: FontWeight.w600,
  ),
);
var boldPlus = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 30.0,
    color: Color.fromRGBO(51, 85, 0, 1),
    fontWeight: FontWeight.bold,
  ),
);
var itemTitle = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 18.0,
    color: black,
    fontWeight: FontWeight.bold,
  ),
);
var itemDateStyle = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 11.0,
    color: grey2,
  ),
);
var itemContentStyle = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 15.0,
    color: grey2,
  ),
);
var viewTitleStyle = GoogleFonts.roboto(
  fontWeight: FontWeight.w900,
  fontSize: 28.0,
);
var viewContentStyle = GoogleFonts.roboto(
    letterSpacing: 0,
    fontSize: 20.0,
    height: 1.5,
    fontWeight: FontWeight.w400);
var createTitle = GoogleFonts.roboto(
    textStyle: const TextStyle(
  fontSize: 28.0,
  fontWeight: FontWeight.w900,
));
var createContent = GoogleFonts.roboto(
  textStyle: const TextStyle(
    letterSpacing: 1.0,
    fontSize: 20.0,
    height: 1.5,
    fontWeight: FontWeight.w400,
  ),
);
var shadow = [
  const BoxShadow(
    color: Color.fromRGBO(191, 191, 191, 1),
    blurRadius: 30,
    offset: Offset(0, 10),
  )
];



