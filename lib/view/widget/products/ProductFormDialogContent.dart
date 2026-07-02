import 'package:flutter/material.dart';
import '../CustomDropdown.dart';
import '../CustomTextField.dart';
import '../../../data/model/Categoris_Model.dart';
import '../../../core/functions/valiedinput.dart';

class ProductFormDialogContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final List<Catdata> categories;
  final String? initialCatUuid;
  final String? initialGender;
  final String confirmBtnText;
  final void Function(String? catUuid, String? gender) onConfirm;
  final VoidCallback onCancel;

  const ProductFormDialogContent({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.priceController,
    required this.categories,
    required this.confirmBtnText,
    required this.onConfirm,
    required this.onCancel,
    this.initialCatUuid,
    this.initialGender,
  });

  @override
  State<ProductFormDialogContent> createState() =>
      _ProductFormDialogContentState();
}

class _ProductFormDialogContentState extends State<ProductFormDialogContent> {
  String? selectedCatUuid;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedCatUuid = widget.initialCatUuid;
    selectedGender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name Label
              Text(
                "اسم المنتج",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: widget.nameController,
                hintText: "أدخل اسم المنتج",
                iconData: Icons.shopping_bag_rounded,
                validator: (val) => validInput(val!, 50, 2, "text"),
              ),
              const SizedBox(height: 14),

              // Price Label
              Text(
                "سعر المنتج",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: widget.priceController,
                hintText: "0.00 دج",
                iconData: Icons.monetization_on_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => validInput(val!, 20, 1, "decimal"),
              ),
              const SizedBox(height: 14),

              // Category Label
              Text(
                "تصنيف المنتج (الفئة)",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomDropdown<String>(
                value: selectedCatUuid,
                items: widget.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.uuid,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(cat.categorisName ?? "",
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87)),
                    ),
                  );
                }).toList(),
                hintText: "اختر فئة المنتج",
                validator: (val) => val == null ? "الرجاء اختيار فئة" : null,
                onChanged: (val) {
                  setState(() {
                    selectedCatUuid = val;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Gender Label
              Text(
                "تحديد الجنس",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomDropdown<String>(
                value: selectedGender,
                items: [
                  DropdownMenuItem<String>(
                    value: "ذكر",
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("ذكر",
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87)),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "أنثى",
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("أنثى",
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87)),
                    ),
                  ),
                ],
                hintText: "اختر الجنس",
                validator: (val) => val == null ? "الرجاء اختيار الجنس" : null,
                onChanged: (val) {
                  setState(() {
                    selectedGender = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Confirm and Cancel buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF800000)),
                      ),
                      onPressed: widget.onCancel,
                      child: Text("إلغاء",
                          style: TextStyle(
                              fontFamily: "Cairo",
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF800000),
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF800000), Color(0xFFB30000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF800000).withOpacity(0.25),
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
                          widget.onConfirm(selectedCatUuid, selectedGender);
                        },
                        child: Text(widget.confirmBtnText,
                            style: const TextStyle(
                                fontFamily: "Cairo",
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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
}
