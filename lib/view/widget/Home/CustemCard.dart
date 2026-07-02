import 'package:Saleh/core/constant/Colorapp.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Custemcard extends StatelessWidget {
  final IconData iconData;
  final String Title;
  final String Price;
  final Color color;
  const Custemcard({
    super.key,
    required this.iconData,
    required this.color,
    required this.Title,
    required this.Price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.all(10),
      width: (Get.width / 2) - 15,
      decoration: BoxDecoration(
        color: const Color.fromARGB(23, 53, 45, 201),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(180),
              color: color,
            ),
            child: FaIcon(iconData, size: 25, color: AppColor.white),
          ),
          SizedBox(width: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(truncateWithDots(Price, 14), textAlign: TextAlign.start),
              Text(Title),
            ],
          ),
        ],
      ),
    );
  }
}

String truncateWithDots(String text, int maxChars) {
  if (text.length <= maxChars) return text;
  return text.substring(0, maxChars) + '...';
}
