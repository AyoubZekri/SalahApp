import 'package:Saleh/view/screen/HomeScreen.dart';
// import 'package:Saleh/view/screen/NavigationBar.dart';
import 'package:Saleh/view/screen/ShwoCat.dart';
import 'package:Saleh/view/screen/products/ShwoProducts.dart';
import 'package:Saleh/view/screen/sales/AddSaleScreen.dart';
import 'package:Saleh/view/screen/sales/ShowInvoices.dart';
import 'package:Saleh/core/constant/routes.dart';
import 'package:get/get.dart';

import 'view/screen/ShwoCustomers.dart';
import 'package:Saleh/view/screen/StatisticsScreen.dart';

List<GetPage<dynamic>> routes = [
  GetPage(name: "/", page: () => const HomeScreen     ()),
  GetPage(name: Approutes.shwocat, page: () => const ShwoCat()),
  GetPage(name: Approutes.client, page: () => const ShwoCustomers()),
  GetPage(name: Approutes.item, page: () => const ShwoProducts()),
  GetPage(name: Approutes.newSale, page: () => const AddSaleScreen()),
  GetPage(name: Approutes.shwoinvoice, page: () => const ShowInvoices()),
  GetPage(name: Approutes.statisticereports, page: () => const StatisticsScreen()),
];
