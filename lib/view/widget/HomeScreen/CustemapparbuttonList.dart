import 'package:Saleh/core/constant/Colorapp.dart';
import 'package:Saleh/view/widget/HomeScreen/CustemApparButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/NavigationBarcontroller.dart';

class CustemapparbuttonList extends StatelessWidget {
  const CustemapparbuttonList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavigationBarcontroller>(
      builder: (controller) => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // لون الظل
              blurRadius: 10, // مدى التمويه
              offset: const Offset(0, -4), // اتجاه الظل (سالب يعني للأعلى)
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          color: Theme.of(context).cardColor,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(controller.Screen.length, ((i) {
                  return Custemapparbutton(
                    onPressed: () {
                      controller.ChangePage(i);
                    },
                    icondata: controller.IconsScreen[i]["icon"],
                    active: controller.currentpage == i,
                  );
                })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
