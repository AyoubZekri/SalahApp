import 'package:Saleh/core/constant/Colorapp.dart';
import 'package:flutter/material.dart';

class Custemapparbutton extends StatelessWidget {
  final void Function()? onPressed;
  // final String textButton;
  final IconData icondata;
  final bool? active;
  const Custemapparbutton({
    super.key,
    required this.onPressed,
    required this.icondata,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icondata,
            color: active == true
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodySmall?.color ?? AppColor.grey,
            size: 35,
          ),
        ],
      ),
    );
  }
}
