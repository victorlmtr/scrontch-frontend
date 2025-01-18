import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../api/api_service.dart';
import '../models/ingredient.dart';
import '../models/ingredient_category.dart';

class AddIngredientScreen extends StatefulWidget {
  final int userId;
  final Ingredient? editingIngredient;

  const AddIngredientScreen({
    Key? key,
    required this.userId,
    this.editingIngredient,
  }) : super(key: key);

  @override
  _AddIngredientScreenState createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _aliasController;
  late TextEditingController _descriptionController;

  File? _imageFile;
  String? _imageUrl;
  IngredientCategory? _selectedCategory;
  List<IngredientCategory> _categories = [];
  bool _isFemale = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingIngredient?.name ?? '');
    _aliasController = TextEditingController(text: widget.editingIngredient?.alias ?? '');
    _descriptionController = TextEditingController(text: widget.editingIngredient?.description ?? '');
    _imageUrl = widget.editingIngredient?.image;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await _apiService.fetchCategories();
      setState(() {
        _categories = categoriesData
            .map((json) => IngredientCategory.fromJson(json))
            .toList();
        if (widget.editingIngredient != null) {
          _selectedCategory = _categories.firstWhere(
                (category) => category.id == widget.editingIngredient!.categoryId,
          );
        }
      });
    } catch (e) {
      _showError('Error loading categories: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('https://images.victorl.xyz/upload');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'files',
          _imageFile!.path,
        ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final urls = json.decode(responseData)['urls'] as List;
        setState(() {
          _imageUrl = urls[0] as String;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      _showError('Error uploading image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ingredientData = {
        if (widget.editingIngredient != null) 'id': widget.editingIngredient!.id,
        'name': _nameController.text,
        'alias': _aliasController.text,
        'description': _descriptionController.text,
        'image': _imageUrl ?? '',
        'categoryid': _selectedCategory!.id,
        'isFemale': _isFemale,
      };

      if (widget.editingIngredient != null) {
        await _apiService.updateIngredient(widget.editingIngredient!.id, ingredientData);
      } else {
        await _apiService.createIngredient(ingredientData);
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showError('Failed to save ingredient: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingIngredient != null
            ? 'Edit Ingredient'
            : 'Add New Ingredient'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(
                  labelText: 'Alias',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IngredientCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) =>
                value == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Upload Image'),
              ),
              if (_imageUrl != null) ...[
                const SizedBox(height: 8),
                Image.network(
                  _imageUrl!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Is Female?'),
                value: _isFemale,
                onChanged: (value) {
                  setState(() => _isFemale = value ?? false);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.editingIngredient != null
                    ? 'Update Ingredient'
                    : 'Add Ingredient'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}