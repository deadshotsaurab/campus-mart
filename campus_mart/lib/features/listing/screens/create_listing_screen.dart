import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/listing_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Books';
  final List<File> _imageFiles = [];
  bool _isLoading = false;
  bool _isForRent = false;
  String _selectedRentPeriod = 'day';

  static const List<String> _categories = [
    'Books', 'Electronics', 'Furniture', 'Clothing', 'Sports', 'Notes', 'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(limit: 5);
    if (picked.isNotEmpty) {
      setState(() {
        _imageFiles.clear();
        _imageFiles.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    final success = await context.read<ListingProvider>().createListing(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          imageFiles: _imageFiles,
          sellerId: currentUser?.uid ?? '',
          sellerName: currentUser?.name ?? 'User',
          sellerPhoto: currentUser?.photoUrl ?? '',
          isForRent: _isForRent,
          rentPeriod: _isForRent ? _selectedRentPeriod : null,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing posted! 🎉')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Photos',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE5E7EB), width: 2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: Color(0xFF1A1A5E), size: 32),
                            SizedBox(height: 4),
                            Text('Add Photos',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageFiles.length,
                        itemBuilder: (_, i) => Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_imageFiles[i]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _imageFiles.removeAt(i)),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Category *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories
                    .map((cat) => GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedCategory == cat
                                  ? const Color(0xFF1A1A5E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedCategory == cat
                                    ? const Color(0xFF1A1A5E)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(cat,
                                style: TextStyle(
                                  color: _selectedCategory == cat
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                )),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Type: ',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const Spacer(),
                  ChoiceChip(
                    label: const Text('Sell'),
                    selected: !_isForRent,
                    onSelected: (val) => setState(() => _isForRent = !val),
                    selectedColor: const Color(0xFF1A1A5E),
                    labelStyle: TextStyle(color: !_isForRent ? Colors.white : Colors.black),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Rent'),
                    selected: _isForRent,
                    onSelected: (val) => setState(() => _isForRent = val),
                    selectedColor: const Color(0xFF1A1A5E),
                    labelStyle: TextStyle(color: _isForRent ? Colors.white : Colors.black),
                  ),
                ],
              ),
              if (_isForRent) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRentPeriod,
                  decoration: const InputDecoration(labelText: 'Rent Period'),
                  items: const [
                    DropdownMenuItem(value: 'day', child: Text('Per Day')),
                    DropdownMenuItem(value: 'week', child: Text('Per Week')),
                    DropdownMenuItem(value: 'month', child: Text('Per Month')),
                  ],
                  onChanged: (val) => setState(() => _selectedRentPeriod = val!),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Engineering Mathematics Textbook'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe your item...'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Price (₹) *',
                    prefixIcon: Icon(Icons.currency_rupee)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  if (double.tryParse(v.trim()) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                    labelText: 'Location *',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'e.g. Block A, Campus'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Location is required'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Post Listing'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
