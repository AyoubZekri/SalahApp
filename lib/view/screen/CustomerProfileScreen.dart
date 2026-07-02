import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/CustomerProfileController.dart';
import '../../../core/class/Statusrequest.dart';
import '../../../core/constant/Colorapp.dart';
import '../widget/sales/InvoiceCard.dart';
import '../widget/CustomTextField.dart';
import 'sales/AddSaleScreen.dart';
import 'sales/InvoiceDetailsScreen.dart';
import '../../core/constant/routes.dart';
import '../../view/screen/sales/AddPurchaseScreen.dart';
import '../../core/functions/format_number.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerProfileController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Text(
          controller.customer.username ?? "ملف العميل",
          style: const TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      // Add Sale FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddSaleScreen(),
                  arguments: {"customer": controller.customer})
              ?.then((_) => controller.getInvoicesForCustomer());
        },
        backgroundColor: const Color(0xFF800000),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Customer Info & Summary Card
            Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child:
                  GetBuilder<CustomerProfileController>(builder: (controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              const Color(0xFF800000).withOpacity(0.1),
                          child: const Icon(Icons.person_rounded,
                              size: 32, color: Color(0xFF800000)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.customer.username ?? "عميل",
                                style: const TextStyle(
                                    fontFamily: "Cairo",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (controller.customer.phoneNumper != null &&
                                  controller.customer.phoneNumper!.isNotEmpty)
                                Text(
                                  controller.customer.phoneNumper!,
                                  style: const TextStyle(
                                      fontFamily: "Cairo",
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        if (controller.customer.phoneNumper != null &&
                            controller.customer.phoneNumper!.isNotEmpty)
                          InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  'tel:${controller.customer.phoneNumper}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                Get.snackbar(
                                    "خطأ", "لا يمكن فتح تطبيق الاتصال");
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.call_rounded,
                                  color: Colors.green),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Totals Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem("الإجمالي", controller.totalDebt,
                            const Color(0xFF800000), isDark),
                        Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.withOpacity(0.2)),
                        _buildStatItem("تم الدفع", controller.totalPaid,
                            Colors.green, isDark),
                        Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.withOpacity(0.2)),
                        _buildStatItem(
                            "المتبقي",
                            controller.totalRemaining,
                            controller.totalRemaining > 0
                                ? Colors.red
                                : Colors.grey,
                            isDark),
                      ],
                    ),
                    if (controller.totalRemaining != 0) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showPaymentDialog(context, controller, controller.totalRemaining > 0),
                          icon: Icon(
                              controller.totalRemaining > 0 
                                  ? Icons.payments_rounded 
                                  : Icons.outbox_rounded,
                              color: Colors.white),
                          label: Text(
                              controller.totalRemaining > 0 
                                  ? "دفع (العميل يدفع لي)" 
                                  : "تسديد (أدفع للمورد)",
                              style: const TextStyle(
                                  fontFamily: "Cairo",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.totalRemaining > 0 
                                ? Colors.green.shade600 
                                : Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.toNamed(Approutes.newSale,
                                  arguments: {"customer": controller.customer});
                            },
                            icon: const Icon(Icons.shopping_cart_checkout,
                                color: Colors.white, size: 20),
                            label: const Text("بيع",
                                style: TextStyle(
                                    fontFamily: "Cairo",
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => const AddPurchaseScreen(),
                                  arguments: {"customer": controller.customer});
                            },
                            icon: const Icon(Icons.add_shopping_cart,
                                color: Colors.white, size: 20),
                            label: const Text("شراء",
                                style: TextStyle(
                                    fontFamily: "Cairo",
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Type Tabs (Sales / Purchases)
                    const SizedBox(height: 16),
                    Container(
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
                    // Filter Tabs
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildFilterTab(
                            controller, 0, Icons.receipt_long_rounded),
                        _buildFilterTab(
                            controller, 1, Icons.check_circle_outline_rounded),
                        _buildFilterTab(
                            controller, 2, Icons.pending_actions_rounded),
                      ],
                    ),
                  ],
                );
              }),
            ),

            // Invoices List
            Expanded(
              child: GetBuilder<CustomerProfileController>(
                builder: (controller) {
                  if (controller.statusrequest == Statusrequest.loadeng) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF800000)));
                  }

                  if (controller.filteredInvoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 60, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            "لا توجد فواتير بهذا التصنيف",
                            style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 15,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16.0, 8.0, 16.0, 80.0), // Padding for FAB
                    itemCount: controller.filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final inv = controller.filteredInvoices[index];
                      return InvoiceCard(
                        invoice: inv,
                        isDark: isDark,
                        onTap: () {
                          Get.to(() => const InvoiceDetailsScreen(),
                                  arguments: inv)
                              ?.then(
                                  (_) => controller.getInvoicesForCustomer());
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

  void _showPaymentDialog(
      BuildContext context, CustomerProfileController controller, bool isCustomerPaying) {
    final TextEditingController amountController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.defaultDialog(
      title: isCustomerPaying ? "تسديد ديون العميل" : "تسديد ديون المورد",
      titleStyle: TextStyle(
          fontFamily: "Cairo",
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isDark ? Colors.white : (isCustomerPaying ? Colors.green.shade800 : Colors.blue.shade800)),
      backgroundColor: isDark ? AppColor.cardDark : Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  isCustomerPaying 
                      ? "سيتم تسديد فواتير البيع الأقدم تلقائياً" 
                      : "سيتم تسديد فواتير الشراء الأقدم تلقائياً",
                  style: const TextStyle(
                      fontFamily: "Cairo", fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              Text(
                "المبلغ (دج)",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: amountController,
                hintText: "أدخل مبلغ الدفع...",
                iconData: Icons.payments_rounded,
                keyboardType: TextInputType.number,
                themeColor: isCustomerPaying ? Colors.green.shade800 : Colors.blue.shade800,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isCustomerPaying ? Colors.green.shade800 : Colors.blue.shade800),
                      ),
                      onPressed: () => Get.back(),
                      child: Text("إلغاء",
                          style: TextStyle(
                              fontFamily: "Cairo",
                              color: isCustomerPaying ? Colors.green.shade800 : Colors.blue.shade800,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: isCustomerPaying 
                              ? [Colors.green.shade600, Colors.green.shade800]
                              : [Colors.blue.shade600, Colors.blue.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isCustomerPaying ? Colors.green : Colors.blue).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          double amount = double.tryParse(amountController.text) ?? 0;
                          if (amount > 0) {
                            if (isCustomerPaying) {
                              controller.payDebt(amount);
                            } else {
                              controller.paySupplierDebt(amount);
                            }
                            Get.back();
                          }
                        },
                        child: const Text(
                          "تأكيد الدفع",
                          style: TextStyle(
                              fontFamily: "Cairo",
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, double amount, Color color, bool isDark) {
    final String displayAmount = formatAmount(amount);
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              fontFamily: "Cairo", fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          "$displayAmount دج",
          style: TextStyle(
              fontFamily: "Cairo",
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color),
        ),
      ],
    );
  }

  Widget _buildFilterTab(
      CustomerProfileController controller, int index, IconData icon) {
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

  Widget _buildTypeTab(
      CustomerProfileController controller, int index, String title, bool isDark) {
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
}
