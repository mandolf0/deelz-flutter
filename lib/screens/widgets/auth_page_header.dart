import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPageHeader extends StatelessWidget {
  String headline = "Welcome";

  AuthPageHeader({
    Key? key,
    required this.headline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          //TODO! add logo
          Text(
            "Deelz",
            style: Theme.of(context).textTheme.headline1!.copyWith(
                fontFamily: GoogleFonts.aleoTextTheme().toString(),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white),
          ),
          const SizedBox(height: 52),
          Text(
            headline,
            style: Theme.of(context).textTheme.headline2!.copyWith(
                fontFamily: GoogleFonts.aleoTextTheme().toString(),
                color: Colors.white),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
