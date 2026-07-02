import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../core/constant/Colorapp.dart';
import 'package:auto_size_text/auto_size_text.dart';


class Custemcartabbreviation extends StatelessWidget {
  final String title;
  final IconData iconData;
  final double? width;
  final double? height;

  final void Function()? onTap;

  const Custemcartabbreviation(
      {super.key,
      required this.title,
      required this.iconData,
      this.onTap,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height == null ? 100 : height,
        padding: const EdgeInsets.all(10),
        width: width == null ? (Get.width / 3) - 17 : width,
        decoration: BoxDecoration(
          color: const Color.fromARGB(23, 53, 45, 201),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(180),
                color: AppColor.backgroundcolor,
              ),
              child: FaIcon(
                iconData,
                size: 20,
                color: AppColor.white,
              ),
            ),
            const SizedBox(height: 5),
            AutoSizeText(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              minFontSize: 13, // أقل حجم مسموح
              stepGranularity: 1,
              style: const TextStyle(
                fontSize: 16, // الحجم الافتراضي
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
