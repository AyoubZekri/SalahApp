import 'dart:io';

import 'package:Saleh/core/constant/Colorapp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Custemcartcat extends StatefulWidget {
  final String? imgitems;
  final String name;
  final bool image;
  final void Function()? onTap;
  final void Function()? onEdit;
  final void Function()? onDelete;

  const Custemcartcat({
    super.key,
    this.imgitems,
    required this.name,
    this.onTap,
    required this.image,
    this.onEdit,
    this.onDelete,
  });
  @override
  State<Custemcartcat> createState() => _CustemcartcatState();
}

class _CustemcartcatState extends State<Custemcartcat> {
  bool showActions = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (showActions) {
          setState(() {
            showActions = false;
          });
        } else {
          widget.onTap?.call();
        }
      },
      onLongPress: () {
        setState(() {
          showActions = !showActions;
        });
      },
      child: Stack(
        children: [
          if (showActions)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: widget.onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          AnimatedPadding(
            duration: Duration(milliseconds: 200),
            padding: Get.locale?.languageCode == 'en'
                ? EdgeInsets.only(right: showActions ? 100 : 0)
                : EdgeInsets.only(left: showActions ? 100 : 0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: widget.image == true ? 100 : 50,
                          width: widget.image == true ? 100 : 50,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 0.4,
                              color: AppColor.grey,
                            ),
                            image: DecorationImage(
                              image: (widget.imgitems?.isNotEmpty ?? false)
                                  ? FileImage(File(widget.imgitems!))
                                        as ImageProvider
                                  :NetworkImage(""),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: widget.image == true
                                ? Theme.of(context).textTheme.headlineSmall
                                : Theme.of(context).textTheme.headlineSmall!
                                      .copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
