import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/ThemeController.dart';
import '../../core/constant/Colorapp.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الإعدادات",
          style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Theme Section Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? AppColor.borderDark : AppColor.borderLight,
                ),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.brightness_6, size: 48, color: Color(0xFF800000)),
                    const SizedBox(height: 12),
                    Text(
                      "مظهر التطبيق",
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "تغيير مظهر التطبيق بين وضع الليل والنهار",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          themeController.toggleTheme(!themeController.isDarkMode);
                        },
                        icon: Icon(themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                        label: Text(
                          themeController.isDarkMode ? "التبديل إلى وضع النهار" : "التبديل إلى الوضع الليلي",
                          style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeController.isDarkMode ? Colors.orange : const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
