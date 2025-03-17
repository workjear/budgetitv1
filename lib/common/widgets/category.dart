import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CategoryBottomSheet extends StatelessWidget {
  final String iconUrl;
  final TextEditingController _categoryController = TextEditingController();

  CategoryBottomSheet({super.key, required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.network(
                iconUrl,
                width: 40,
                height: 40,
                color: const Color(0xFF00BF6D),
              ),
              const SizedBox(width: 8),
              const Text(
                'Selected Icon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final categoryName = _categoryController.text.trim();
                  if (categoryName.isNotEmpty) {
                    print('Returning: categoryName=$categoryName');
                    Navigator.pop(context, {
                      'iconUrl': iconUrl,
                      'categoryName': categoryName,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category name is required')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BF6D)),
                child: const Text('Confirm'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}