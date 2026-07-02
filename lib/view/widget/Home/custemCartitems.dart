// import 'dart:io';

// import 'package:Saleh/LinkApi.dart';
// import 'package:Saleh/core/constant/Colorapp.dart';
// import 'package:Saleh/core/constant/imageassets.DART';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';

// class Custemcartitems extends StatelessWidget {
//   final String? imgitems;
//   final String Title;
//   final String Body;
//   final String Price;
//   final bool image;
//   final void Function()? onTap;
//   final bool isLoading;

//   const Custemcartitems({
//     super.key,
//     this.imgitems,
//     required this.Title,
//     required this.Body,
//     required this.Price,
//     this.onTap,
//     required this.image,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Widget content = Container(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 0),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             // الصورة
//             Container(
//               height: image ? 100 : 50,
//               width: image ? 100 : 50,
//               margin: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(width: 0.4, color: AppColor.grey),
//                 image: isLoading
//                     ? null
//                     : DecorationImage(
//                         image: (imgitems?.isNotEmpty ?? false)
//                             ? FileImage(File(imgitems!)) as ImageProvider
//                             : const AssetImage(Appimageassets.test2)
//                                   as ImageProvider,
//                         fit: BoxFit.contain,
//                       ),
//                 color: isLoading ? Colors.white : null,
//               ),
//             ),

//             const SizedBox(width: 10),

//             // التفاصيل
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // العنوان الرئيسي بدون حاوية
//                   isLoading
//                       ? Container(height: 16, width: 150, color: Colors.white)
//                       : Text(
//                           Title,
//                           style: image
//                               ? Theme.of(context).textTheme.headlineSmall!
//                                     .copyWith(fontSize: 20)
//                               : Theme.of(context).textTheme.headlineSmall!
//                                     .copyWith(fontSize: 22),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                   const SizedBox(height: 5),

//                   isLoading
//                       ? Container(height: 16, width: 100, color: Colors.white)
//                       : Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.backgroundcolor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Quantity:".tr,
//                                 style: const TextStyle(
//                                   color: AppColor.black,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 Body,
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.headlineLarge,
//                               ),
//                             ],
//                           ),
//                         ),
//                   const SizedBox(height: 5),

//                   if (image)
//                     isLoading
//                         ? Container(
//                             height: 16,
//                             width: double.infinity,
//                             color: Colors.white,
//                           )
//                         : Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.backgroundcolor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   "Price:".tr,
//                                   style: const TextStyle(
//                                     color: AppColor.black,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   "$Price",
//                                   style: Theme.of(
//                                     context,
//                                   ).textTheme.headlineLarge,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   "DA".tr,
//                                   style: Theme.of(
//                                     context,
//                                   ).textTheme.headlineLarge,
//                                 ),
//                               ],
//                             ),
//                           ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//     return isLoading
//         ? Shimmer.fromColors(
//             baseColor: Colors.grey.shade300,
//             highlightColor: Colors.grey.shade100,
//             child: content,
//           )
//         : InkWell(onTap: onTap, child: content);
//   }
// }
