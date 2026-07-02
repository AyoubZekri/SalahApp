import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/NavigationBarcontroller.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/functions/format_number.dart';
import '../widget/Home/StatCard.dart';
import '../widget/Home/QuickActionButton.dart';
import '../widget/Home/WeeklySalesChart.dart';
import '../widget/Home/ActivityCard.dart';
import '../../core/constant/routes.dart';
import '../../view/screen/SettingsScreen.dart';
import '../../view/screen/sales/AddPurchaseScreen.dart';
import '../../view/screen/StatisticsScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBarController = Get.isRegistered<NavigationBarcontroller>()
        ? Get.find<NavigationBarcontroller>()
        : Get.put(NavigationBarcontroller());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0.5,
        title: Text(
          "الصفحة الرئيسية",
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF800000),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                "مرحباً بعودتك",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "نظرة عامة على إدارة الماشية والعمليات المالية اليوم.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: isDark ? AppColor.textDarkSub : AppColor.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Grid (2x2)
              GetBuilder<NavigationBarcontroller>(
                builder: (controller) => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    StatCard(
                      title: "مبيعات اليوم",
                      value: "${formatAmount(controller.todaySales)} دج",
                      subtitle: "مبيعات فعلية",
                      icon: Icons.monetization_on_outlined,
                    ),
                    StatCard(
                      title: "المبالغ غير المحصلة اليوم",
                      value: "${formatAmount(controller.uncollectedToday)} دج",
                      subtitle: "ديون جديدة",
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    StatCard(
                      title: "إجمالي العملاء",
                      value: "${controller.totalCustomers}",
                      subtitle: "عميل مسجل",
                      icon: Icons.people_outline,
                    ),
                    StatCard(
                      title: "عدد فواتير اليوم",
                      value: "${controller.invoicesToday}",
                      subtitle: "فاتورة مسجلة",
                      icon: Icons.description_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Section
              Text(
                "أزرار سريعة",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // New Sell & New Purchase Buttons
              Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      label: "بيع جديد",
                      icon: Icons.shopping_cart,
                      isLarge: true,
                      onTap: () {
                        Get.toNamed(Approutes.newSale);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      label: "شراء جديد",
                      icon: Icons.add_business,
                      isLarge: true,
                      onTap: () {
                        Get.to(() => const AddPurchaseScreen());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick Actions Sub-grid (3x2)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  QuickActionButton(
                    label: "العملاء",
                    icon: Icons.people_alt_outlined,
                    onTap: () => Get.toNamed(Approutes.client),
                  ),
                  QuickActionButton(
                    label: "المنتجات",
                    icon: Icons.inventory_2_outlined,
                    onTap: () => Get.toNamed(Approutes.item),
                  ),
                  QuickActionButton(
                    label: "الفواتير",
                    icon: Icons.receipt_long_outlined,
                    onTap: () => Get.toNamed(Approutes.shwoinvoice),
                  ),
                  QuickActionButton(
                    label: "التقارير",
                    icon: Icons.bar_chart_outlined,
                    onTap: () => Get.toNamed(Approutes.statisticereports),
                  ),
                  QuickActionButton(
                    label: "الفئات",
                    icon: Icons.category_outlined,
                    onTap: () => Get.toNamed(Approutes.shwocat),
                  ),
                  QuickActionButton(
                    label: "الإعدادات",
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Get.to(() => const SettingsScreen());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
