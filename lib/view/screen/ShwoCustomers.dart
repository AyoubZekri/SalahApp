import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/CustomersController.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/functions/showDeleteDialog.dart';
import '../widget/customers/CustomerStatCard.dart';
import '../widget/customers/CustomerCard.dart';
import '../widget/customers/CustomerFormDialog.dart';
import 'CustomerProfileScreen.dart';

class ShwoCustomers extends StatefulWidget {
  const ShwoCustomers({super.key});

  @override
  State<ShwoCustomers> createState() => _ShwoCustomersState();
}

class _ShwoCustomersState extends State<ShwoCustomers> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    Get.put(Customerscontroller());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          "إدارة العملاء",
          style: TextStyle(
            fontFamily: "Cairo", 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [AppColor.cardDark, AppColor.bgDark] 
                  : [Colors.white, const Color(0xFFF9FAFC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF800000),
        elevation: 4,
        onPressed: () => showCustomerFormDialog(context, isAddMode: true),
        label: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              "عميل جديد",
              style: TextStyle(
                fontFamily: "Cairo", 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<Customerscontroller>(
          builder: (controller) {
            // Filter customers list by name or phone
            final filteredList = controller.customers.where((cust) {
              final name = cust.username?.toLowerCase() ?? "";
              final phone = cust.phoneNumper?.toLowerCase() ?? "";
              final query = searchQuery.toLowerCase();
              return name.contains(query) || phone.contains(query);
            }).toList();

            return Column(
              children: [
                // Top Search Bar & Stat Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      // Stat Summary Card
                      CustomerStatCard(count: controller.customers.length),
                      const SizedBox(height: 14),
                      // Search TextField
                      TextField(
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                        style: const TextStyle(fontFamily: "Cairo", fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "ابحث عن عميل بالاسم أو الهاتف...",
                          hintStyle: const TextStyle(fontFamily: "Cairo", fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF800000)),
                          filled: true,
                          fillColor: isDark ? AppColor.cardDark : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Customers List
                Expanded(
                  child: controller.statusrequest == Statusrequest.loadeng
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF800000)))
                      : filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 80,
                                    color: isDark ? AppColor.textDarkSub : AppColor.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isEmpty ? "لا يوجد عملاء حالياً" : "لا توجد نتائج بحث تطابق استفسارك",
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final customer = filteredList[index];
                                return CustomerCard(
                                  customer: customer,
                                  onTap: () {
                                    Get.to(() => const CustomerProfileScreen(), arguments: customer);
                                  },
                                  onEdit: () {
                                    controller.initData(customer);
                                    showCustomerFormDialog(context, isAddMode: false, customer: customer);
                                  },
                                  onDelete: () {
                                    showDeleteDialog(
                                      itemName: "العميل: (${customer.username})",
                                      onConfirm: () {
                                        if (customer.uuid != null) {
                                          controller.deleteCustomer(customer.uuid!);
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
