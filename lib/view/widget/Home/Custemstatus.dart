import 'package:Saleh/core/constant/Colorapp.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Custemstatus extends StatelessWidget {
  final void Function()? onPressed;
  final String NameItems;
  final bool isActive;
  final bool isLoading;

  const Custemstatus({
    super.key,
    required this.NameItems,
    this.onPressed,
    required this.isActive,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: (MediaQuery.of(context).size.width - 40) / 3,
      decoration: BoxDecoration(
        color: isActive ? const Color.fromARGB(8, 78, 70, 229) : AppColor.white,
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(color: AppColor.backgroundcolor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                NameItems,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColor.backgroundcolor : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: content,
        ),
      );
    }

    return content;
  }
}
