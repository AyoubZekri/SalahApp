import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/FinancialOverviewController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/format_number.dart';
import '../widget/financial_overview/FinancialGridCard.dart';
import '../widget/financial_overview/FinancialDetailCard.dart';

class FinancialOverviewScreen extends StatelessWidget {
  const FinancialOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Controller is initialized and data fetched before navigating here
    final ctrl = Get.find<FinancialOverviewController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColor.bgDark : AppColor.bgLight,
        appBar: AppBar(
          title: Text(
            "نظرة مالية عامة",
            style: TextStyle(
              color: AppColor.primaryApp,
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: isDark ? AppColor.cardDark : AppColor.cardLight,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: AppColor.primaryApp,
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: GetBuilder<FinancialOverviewController>(
            builder: (controller) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Date Range Text
                    Text(
                      controller.periodLabel,
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4 Grid Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          1.6, // Adjusted to fit RTL text beautifully
                      children: [
                        FinancialGridCard(
                          title: "المبيعات",
                          amount: formatAmount(controller.sales),
                          icon: Icons.shopping_cart_outlined,
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                        FinancialGridCard(
                          title: "الديون",
                          amount: formatAmount(controller.debts),
                          icon: Icons.money_off_outlined,
                          color: Colors.orange,
                          isDark: isDark,
                        ),
                        FinancialGridCard(
                          title: "المصاريف",
                          amount: formatAmount(controller.expenses),
                          icon: Icons.trending_down,
                          color: Colors.red,
                          isDark: isDark,
                        ),
                        FinancialGridCard(
                          title: "عدد الفواتير",
                          amount: "${controller.invoicesCount}",
                          icon: Icons.receipt_long_outlined,
                          color: Colors.purple,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Financial Details Header
                    Row(
                      children: [
                        const Icon(Icons.menu,
                            color: AppColor.primaryApp, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "التفاصيل المالية",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // List of Details Cards
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.detailedList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var item = controller.detailedList[index];
                        return FinancialDetailCard(item: item, isDark: isDark);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
