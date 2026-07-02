import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/InvoicesController.dart';
import '../../../core/class/Statusrequest.dart';
import '../../../core/constant/Colorapp.dart';
import '../../widget/CustomTextField.dart';
import '../../widget/sales/InvoiceCard.dart';
import 'InvoiceDetailsScreen.dart';

class ShowInvoices extends StatelessWidget {
  const ShowInvoices({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InvoicesController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          "سجل الفواتير",
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search Input Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                controller: controller.searchController,
                hintText: "ابحث برقم الفاتورة أو اسم العميل...",
                iconData: Icons.search_rounded,
                onChanged: (val) => controller.filterInvoices(val),
              ),
            ),
            // Filter Tabs
            GetBuilder<InvoicesController>(
              builder: (controller) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColor.cardDark : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildTypeTab(controller, 0, "مبيعات", isDark),
                          _buildTypeTab(controller, 1, "مشتريات", isDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildFilterTab(controller, 0, Icons.receipt_long_rounded),
                        _buildFilterTab(controller, 1, Icons.check_circle_outline_rounded),
                        _buildFilterTab(controller, 2, Icons.pending_actions_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Invoices List
            Expanded(
              child: GetBuilder<InvoicesController>(
                builder: (controller) {
                  if (controller.statusrequest == Statusrequest.loadeng) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF800000)),
                    );
                  }

                  if (controller.filteredInvoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            "لا توجد فواتير مطابقة للبحث",
                            style: TextStyle(
                              fontFamily: "Cairo",
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: controller.filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final inv = controller.filteredInvoices[index];
                      return InvoiceCard(
                        invoice: inv,
                        isDark: isDark,
                        onTap: () {
                          Get.to(() => const InvoiceDetailsScreen(),
                              arguments: inv);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(
      InvoicesController controller, int index, String title, bool isDark) {
    bool isSelected = controller.invoiceTypeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTypeTab(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF800000) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(
      InvoicesController controller, int index, IconData icon) {
    bool isSelected = controller.currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 26,
            color: isSelected
                ? const Color(0xFF800000)
                : Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
