import 'package:flutter/material.dart';

class Custemsearch extends StatelessWidget {
  final String Search;
  final Function(String)? onChanged;
  const Custemsearch({super.key, required this.Search, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: TextFormField(
        onChanged: onChanged,
        decoration: InputDecoration(
            prefixIcon:
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            hintText: Search,
            hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey[200]),
      ),
    );
  }
}
