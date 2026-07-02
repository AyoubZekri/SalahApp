import 'dart:io';

import 'package:Saleh/core/constant/Colorapp.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Compresses an image file if it exceeds 1MB.
/// Iteratively reduces quality until the file is under 1MB.
Future<File> compressImageIfNeeded(File file) async {
  final int oneMB = 1024 * 1024;
  int fileSize = await file.length();

  if (fileSize <= oneMB) return file;

  final dir = await getTemporaryDirectory();
  final targetPath =
      '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

  int quality = 80;

  while (quality > 10) {
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: 1024,
      minHeight: 1024,
    );

    if (result != null) {
      final compressedFile = File(result.path);
      final compressedSize = await compressedFile.length();
      if (compressedSize <= oneMB) {
        return compressedFile;
      }
    }
    quality -= 15;
  }

  // Last attempt with minimum quality
  final XFile? finalResult = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 10,
    minWidth: 800,
    minHeight: 800,
  );

  if (finalResult != null) {
    return File(finalResult.path);
  }

  return file;
}

imageuploadcamera() async {
  final XFile? file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 90,
  );
  if (file != null) {
    return await compressImageIfNeeded(File(file.path));
  } else {
    return null;
  }
}

fileuploadGallery([isvg = true]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: isvg
        ? ["svg", "SVG"]
        : ["png", "PNG", "jpg", "JPG", "jpeg", "gif"],
  );

  if (result != null) {
    File pickedFile = File(result.files.single.path!);
    // Only compress non-SVG image files
    if (!isvg) {
      return await compressImageIfNeeded(pickedFile);
    }
    return pickedFile;
  } else {
    return null;
  }
}

showbottom(imageuploadcamera(), fileuploadGallery()) {
  Get.bottomSheet(
    backgroundColor: AppColor.white,
    Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "choose_image".tr,
                style: const TextStyle(
                  fontSize: 22,
                  color: AppColor.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            ListTile(
              onTap: () {
                imageuploadcamera();
                Get.back();
              },
              leading: const Icon(Icons.camera, size: 40),
              title: Text(
                "from_camera".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                fileuploadGallery();
                Get.back();
              },
              leading: const Icon(Icons.image, size: 40),
              title: Text(
                "from_gallery".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

showfile() {
  fileuploadGallery(false);
}

showBottomAddProductOrScanner(
  int catid,
  String uuid,
  void Function(int catid, String uuid) onAddProduct,
  VoidCallback onOpenScanner,
  VoidCallback onOpenScannerfile,
) {
  Get.bottomSheet(
    backgroundColor: AppColor.white,
    Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "choose_action".tr,
              style: const TextStyle(
                fontSize: 22,
                color: AppColor.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () {
                Get.back();
                onAddProduct(catid, uuid);
                // Future.delayed(Duration(milliseconds: 200), onAddProduct);
              },
              leading: const Icon(Icons.add_box_outlined, size: 40),
              title: Text(
                "add_product_manual".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.back();
                onOpenScanner();
                // Future.delayed(Duration(milliseconds: 200), onOpenScanner);
              },
              leading: const Icon(Icons.qr_code_scanner, size: 40),
              title: Text(
                "open_camera_scanner".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.back();
                onOpenScannerfile();
                // Future.delayed(Duration(milliseconds: 200), onOpenScanner);
              },
              leading: const Icon(Icons.upload_file, size: 40),
              title: Text(
                "choose_from_files".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
