import 'package:flutter/material.dart';
import 'package:novanote/models/category.dart';
import 'package:novanote/util/database_helper.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _showCategoryDialog([Category? category]) async {
    final nameController = TextEditingController(text: category?.name);
    final descriptionController =
        TextEditingController(text: category?.description);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'New Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              final newCategory = Category(
                id: category?.id,
                name: nameController.text,
                description: descriptionController.text,
              );

              if (category == null) {
                await _dbHelper.insertCategory(newCategory);
              } else {
                await _dbHelper.updateCategory(newCategory);
              }

              Navigator.pop(context);
              _loadCategories();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text(category.description ?? ''),
            onTap: () => _showCategoryDialog(category),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // Check if category has notes before deleting
                final hasNotes = await _dbHelper.categoryHasNotes(category.id!);
                if (hasNotes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete category with notes'),
                    ),
                  );
                  return;
                }
                await _dbHelper.deleteCategory(category.id!);
                _loadCategories();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showCategoryDialog(),
      ),
    );
  }
}
