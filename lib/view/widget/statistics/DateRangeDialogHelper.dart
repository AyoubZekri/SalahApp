import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/constant/Colorapp.dart';
import '../../../controller/FinancialOverviewController.dart';
import '../../screen/FinancialOverviewScreen.dart';

class DateRangeDialogHelper {
  static void showDateRangeDialog(BuildContext context, bool isDark) {
    List<Map<String, dynamic>> options = [
      {
        "label": "اليوم",
        "action": () =>
            _navigateWithRange(DateTime.now(), DateTime.now(), "اليوم")
      },
      {
        "label": "أمس",
        "action": () {
          var d = DateTime.now().subtract(const Duration(days: 1));
          _navigateWithRange(d, d, "أمس");
        }
      },
      {
        "label": "آخر 7 أيام",
        "action": () {
          var end = DateTime.now();
          var start = end.subtract(const Duration(days: 6));
          _navigateWithRange(start, end, "آخر 7 أيام");
        }
      },
      {
        "label": "آخر 30 يوم",
        "action": () {
          var end = DateTime.now();
          var start = end.subtract(const Duration(days: 29));
          _navigateWithRange(start, end, "آخر 30 يوم");
        }
      },
      {
        "label": "هذا الشهر",
        "action": () {
          var now = DateTime.now();
          var start = DateTime(now.year, now.month, 1);
          var end = DateTime(now.year, now.month + 1, 0); // Last day of month
          _navigateWithRange(start, end, "هذا الشهر");
        }
      },
      {
        "label": "الشهر الماضي",
        "action": () {
          var now = DateTime.now();
          var start = DateTime(now.year, now.month - 1, 1);
          var end = DateTime(now.year, now.month, 0);
          _navigateWithRange(start, end, "الشهر الماضي");
        }
      },
      {
        "label": "هذه السنة",
        "action": () {
          var now = DateTime.now();
          var start = DateTime(now.year, 1, 1);
          var end = DateTime(now.year, 12, 31);
          _navigateWithRange(start, end, "هذه السنة");
        }
      },
      {
        "label": "السنة الماضية",
        "action": () {
          var now = DateTime.now();
          var start = DateTime(now.year - 1, 1, 1);
          var end = DateTime(now.year - 1, 12, 31);
          _navigateWithRange(start, end, "السنة الماضية");
        }
      },
      {
        "label": "مخصص",
        "action": () {
          Get.back(); // close dialog first
          _showCustomDateRangePicker(context, isDark);
        }
      },
    ];

    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColor.cardDark : AppColor.cardLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "اختر الفترة",
            style: TextStyle(
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    options[index]["label"],
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    if (options[index]["label"] != "مخصص") {
                       Get.back(); // Close dialog
                    }
                    options[index]["action"]();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static void _navigateWithRange(DateTime start, DateTime end, String label) {
    if (!Get.isRegistered<FinancialOverviewController>()) {
      Get.put(FinancialOverviewController());
    }
    final ctrl = Get.find<FinancialOverviewController>();
    ctrl.initData(start, end, label);
    Get.to(() => const FinancialOverviewScreen(),
        transition: Transition.fadeIn);
  }

  static void _showCustomDateRangePicker(BuildContext context, bool isDark) {
    DateTime? startDate;
    DateTime? endDate;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: isDark ? AppColor.cardDark : AppColor.cardLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.all(24),
              title: Center(
                child: Text(
                  "تحديد فترة مخصصة",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _buildDatePickerCard(
                    title: "تاريخ البداية",
                    date: startDate,
                    isDark: isDark,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) =>
                            _buildDatePickerTheme(child!, isDark),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDatePickerCard(
                    title: "تاريخ النهاية",
                    date: endDate,
                    isDark: isDark,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? (startDate ?? DateTime.now()),
                        firstDate: startDate ?? DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) =>
                            _buildDatePickerTheme(child!, isDark),
                      );
                      if (picked != null) {
                        setState(() => endDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (startDate != null && endDate != null) {
                          Get.back(); // Close dialog
                          String label =
                              "${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}";
                          _navigateWithRange(startDate!, endDate!, label);
                        } else {
                          Get.snackbar("تنبيه",
                              "يرجى تحديد تاريخ البداية وتاريخ النهاية",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryApp,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "تأكيد وعرض التقرير",
                        style: TextStyle(
                            fontFamily: "Cairo",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildDatePickerCard(
      {required String title,
      required DateTime? date,
      required bool isDark,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isDark ? AppColor.bgDark : AppColor.borderLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColor.borderDark : AppColor.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null
                      ? DateFormat('yyyy-MM-dd').format(date)
                      : "اختر التاريخ",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: date != null
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            Icon(Icons.calendar_month, color: AppColor.primaryApp, size: 28),
          ],
        ),
      ),
    );
  }

  static Widget _buildDatePickerTheme(Widget child, bool isDark) {
    return Theme(
      data: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: isDark
            ? const ColorScheme.dark(
                primary: AppColor.primaryApp, surface: AppColor.cardDark)
            : const ColorScheme.light(
                primary: AppColor.primaryApp, surface: AppColor.cardLight),
        dialogBackgroundColor: isDark ? AppColor.cardDark : AppColor.cardLight,
      ),
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    );
  }
}
