import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/class/Statusrequest.dart';
import '../core/functions/Snacpar.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/Sales_data.dart';
import '../data/model/Customers_Model.dart';
import '../data/model/Products_Model.dart';

class SalesController extends GetxController {
  final SalesData salesData = SalesData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  List<CustomerData> customers = [];
  List<ProductData> products = [];

  // Selected customer for this sale (null represents general guest customer / زبون عابر)
  CustomerData? selectedCustomer;
  double customerOldDebt = 0.0;

  Future<void> fetchCustomerDebt(String customerUuid) async {
    try {
      final res = await salesData.getInvoices();
      final customerInvoices = res.where((inv) => inv["Customers_uuid"] == customerUuid).toList();
      
      double totalDebt = 0;
      double totalPaid = 0;
      for (var inv in customerInvoices) {
        final isPurchase = inv["type"] == "purchases";
        final netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        final paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        
        if (isPurchase) {
          totalPaid += (netTotal - paid);
        } else {
          totalDebt += netTotal;
          totalPaid += paid;
        }
      }
      customerOldDebt = totalDebt - totalPaid;
      update();
    } catch (e) {
      print("❌ fetchCustomerDebt error: $e");
    }
  }

  // Items added to invoice cart
  // Layout: { "uuid": String, "name": String, "price": double, "quantity": double }
  List<Map<String, dynamic>> cartItems = [];

  final discountController = TextEditingController();
  final paidAmountController = TextEditingController();

  // Controllers for quick customer dialog
  final quickCustomerNameController = TextEditingController();
  final quickCustomerPhoneController = TextEditingController();
  final quickCustomerFormKey = GlobalKey<FormState>();

  // Fetch initial customers and products
  Future<void> loadInitialData() async {
    update();
    try {
      final custRes = await salesData.getCustomers();
      customers = custRes.map((e) => CustomerData.fromJson(e)).toList();

      final prodRes = await salesData.getProducts();
      products = prodRes.map((e) => ProductData.fromJson(e)).toList();

      if (Get.arguments != null && Get.arguments["customer"] != null) {
        final custArg = Get.arguments["customer"];
        selectedCustomer = customers.firstWhereOrNull((c) => c.uuid == custArg.uuid) ?? custArg;
        if (selectedCustomer != null) {
          fetchCustomerDebt(selectedCustomer!.uuid!);
        }
      }

      statusrequest = Statusrequest.success;
    } catch (e) {
      print("❌ SalesController.loadInitialData error: $e");
      statusrequest = Statusrequest.serverfailure;
    }
    update();
  }

  // Add customer directly and select them
  Future<void> addCustomerDirectly(String name, String phone) async {
    if (name.trim().isEmpty || phone.trim().isEmpty) return;

    update();
    final res = await salesData.quickCreateCustomer(name, phone);
    if (res != null) {
      final newCustomer = CustomerData.fromJson(res);
      customers.add(newCustomer);
      selectedCustomer = newCustomer;
      customerOldDebt = 0.0; // new customer has no debt
      showSnackbar(
          "نجاح", "تم إنشاء العميل وتحديده للفاتورة بنجاح", Colors.green);
    } else {
      showSnackbar("خطأ", "فشل إضافة العميل", Colors.red);
    }
    statusrequest = Statusrequest.success;
    update();
  }

  // Cart operations
  void addProductToCart(ProductData product, double quantity, double price) {
    // Check if product is already in the cart
    int index =
        cartItems.indexWhere((element) => element["uuid"] == product.uuid);
    if (index >= 0) {
      cartItems[index]["quantity"] = cartItems[index]["quantity"] + quantity;
    } else {
      cartItems.add({
        "uuid": product.uuid,
        "name": product.name,
        "price": price, // uses custom overridden price
        "quantity": quantity,
      });
    }
    update();
  }

  void updateCartItemQuantity(int index, double quantity) {
    if (quantity <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems[index]["quantity"] = quantity;
    }
    update();
  }

  void updateCartItemPrice(int index, double price) {
    if (price >= 0) {
      cartItems[index]["price"] = price;
    }
    update();
  }

  void removeProductFromCart(int index) {
    cartItems.removeAt(index);
    update();
  }

  // Invoice calculations
  double get subtotal {
    double total = 0.0;
    for (var item in cartItems) {
      total += (item["price"] as double) * (item["quantity"] as double);
    }
    return total;
  }

  double get discountAmount {
    return double.tryParse(discountController.text) ?? 0.0;
  }

  double get netTotal {
    double net = subtotal - discountAmount;
    return net < 0 ? 0.0 : net;
  }

  double get paidAmount {
    if (paidAmountController.text.trim().isEmpty) {
      return 0.0;
    }
    return double.tryParse(paidAmountController.text) ?? 0.0;
  }

  // Save transaction to DB
  Future<void> checkout() async {
    if (selectedCustomer == null) {
      showSnackbar("تنبيه", "الرجاء اختيار العميل لإتمام الفاتورة",
          Colors.amber.shade800);
      return;
    }
    if (cartItems.isEmpty) {
      showSnackbar("تنبيه", "سلة المشتريات فارغة! اختر بعض المنتجات للبيع",
          Colors.amber.shade800);
      return;
    }

    update();

    final success = await salesData.saveInvoice(
      customerUuid: selectedCustomer?.uuid,
      netTotal: netTotal,
      discount: discountAmount,
      items: cartItems,
    );

    if (success) {
      statusrequest = Statusrequest.success;

      // Distribute payment from oldest to newest unpaid invoice
      if (paidAmount > 0 && selectedCustomer != null) {
        try {
          final allInvoices = await salesData.getInvoices();
          final customerInvoices = allInvoices.where((inv) => inv["Customers_uuid"] == selectedCustomer!.uuid).toList();
          
          List<Map<String, dynamic>> unpaidInvoices = customerInvoices.where((inv) {
            if (inv["type"] == "purchases") return false;
            double invoiceNet = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
            double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
            return (invoiceNet - paid) > 0;
          }).toList();

          // Sort oldest first (ascending by id)
          unpaidInvoices.sort((a, b) => (a["id"] as int? ?? 0).compareTo(b["id"] as int? ?? 0));

          double remainingAmountToPay = paidAmount;

          for (var inv in unpaidInvoices) {
            if (remainingAmountToPay <= 0) break;

            double invoiceNet = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
            double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
            double invoiceDebt = invoiceNet - paid;

            double paymentForThisInvoice = remainingAmountToPay > invoiceDebt ? invoiceDebt : remainingAmountToPay;
            
            await salesData.addPayment(inv["uuid"], paymentForThisInvoice);
            
            remainingAmountToPay -= paymentForThisInvoice;
          }
        } catch (e) {
          print("Error distributing payment: $e");
        }
      }

      cartItems.clear();
      discountController.clear();
      paidAmountController.clear();
      customerOldDebt = 0.0;
      selectedCustomer = null;
      Get.back();
      if (Get.isRegistered<RefreshService>()) {
        Get.find<RefreshService>().fire();
      }
      showSnackbar("نجاح", "تم تسجيل وحفظ الفاتورة بنجاح", Colors.green);
    } else {
      statusrequest = Statusrequest.failure;
      showSnackbar("خطأ", "فشل حفظ الفاتورة بقاعدة البيانات", Colors.red);
    }
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }
}
