import 'package:flutter/material.dart';
import '../../../../core/functions/valiedinput.dart';
import '../CustomTextField.dart';

class CategoryFormDialogContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController textController;
  final String labelText;
  final String confirmBtnText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CategoryFormDialogContent({
    super.key,
    required this.formKey,
    required this.textController,
    required this.labelText,
    required this.confirmBtnText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelText,
                style: TextStyle(
                  fontFamily: "Cairo", 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13, 
                  color: isDark ? Colors.white : Colors.black87
                ),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: textController,
                hintText: "أدخل اسم الفئة هنا",
                iconData: Icons.category_rounded,
                validator: (val) => validInput(val!, 50, 2, "text"),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? Colors.white54 : const Color(0xFF800000)),
                      ),
                      onPressed: onCancel,
                      child: Text(
                        "إلغاء", 
                        style: TextStyle(
                          fontFamily: "Cairo", 
                          color: isDark ? Colors.white : const Color(0xFF800000), 
                          fontWeight: FontWeight.bold
                        )
                      ),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: onConfirm,
                        child: Text(
                          confirmBtnText, 
                          style: const TextStyle(
                            fontFamily: "Cairo", 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          )
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
}
