import 'package:flutter/material.dart';

import '../../../core/constant/Colorapp.dart';

class Custemtitle extends StatelessWidget {
  final String title;
  const Custemtitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: AppColor.black,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
