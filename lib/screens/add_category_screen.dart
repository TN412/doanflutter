import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/expense_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  final bool isIncome;
  const AddCategoryScreen({super.key, required this.isIncome});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  late Color _selectedColor;
  late IconData _selectedIcon;

  // Modern Color Palette
  final List<Color> _colors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFF45B7D1), // Cyan
    const Color(0xFFFFA502), // Orange
    const Color(0xFFA55EEA), // Purple
    const Color(0xFF26DE81), // Green
    const Color(0xFF2D98DA), // Blue
    const Color(0xFFFD9644), // Peach
    const Color(0xFFFC5C65), // Coral
    const Color(0xFF778BEB), // Pastel Blue
  ];

  // Common Icons
  final List<IconData> _icons = [
    Icons.shopping_bag_outlined,
    Icons.restaurant_menu,
    Icons.directions_car,
    Icons.home_work_outlined,
    Icons.sports_esports,
    Icons.medical_services_outlined,
    Icons.school_outlined,
    Icons.pets,
    Icons.card_giftcard,
    Icons.flight_takeoff,
    Icons.fitness_center,
    Icons.music_note,
    Icons.local_cafe_outlined,
    Icons.movie_outlined,
    Icons.wifi,
    Icons.phone_iphone,
    Icons.bolt,
    Icons.water_drop_outlined,
    Icons.savings_outlined,
    Icons.category_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors[0];
    _selectedIcon = _icons[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
      );
      return;
    }
    
    final newCategory = CategoryModel(
      name: _nameController.text.trim(),
      isIncome: widget.isIncome,
      iconCodePoint: _selectedIcon.codePoint,
      colorValue: _selectedColor.value,
    );

    Provider.of<ExpenseProvider>(context, listen: false).addCategory(newCategory);
    
    if (mounted) {
       Navigator.pop(context);
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm danh mục mới')),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm danh mục ${widget.isIncome ? 'Thu nhập' : 'Chi tiêu'}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Preview Section
             Center(
               child: Column(
                 children: [
                   Container(
                     width: 80, height: 80,
                     decoration: BoxDecoration(
                       color: _selectedColor.withOpacity(0.2),
                       shape: BoxShape.circle,
                       border: Border.all(color: _selectedColor, width: 2),
                     ),
                     child: Icon(_selectedIcon, color: _selectedColor, size: 40),
                   ),
                   const SizedBox(height: 12),
                   Text(
                     _nameController.text.isEmpty ? 'Tên danh mục' : _nameController.text,
                     style: TextStyle(
                       fontSize: 18, 
                       fontWeight: FontWeight.bold,
                       color: _selectedColor
                     ),
                   )
                 ],
               ),
             ),
             const SizedBox(height: 32),

             // Name Input
             TextField(
               controller: _nameController,
               onChanged: (value) => setState(() {}),
               decoration: InputDecoration(
                 labelText: 'Tên danh mục',
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                 prefixIcon: const Icon(Icons.label_outline),
               ),
             ),
             const SizedBox(height: 24),

             // Color Picker
             const Text('Chọn màu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 12),
             Wrap(
               spacing: 12,
               runSpacing: 12,
               children: _colors.map((color) => _buildColorItem(color)).toList(),
             ),
             const SizedBox(height: 24),

             // Icon Picker
             const Text('Chọn Icon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 12),
             Container(
               height: 200,
               decoration: BoxDecoration(
                 color: Colors.grey.shade50,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey.shade200),
               ),
               child: GridView.builder(
                 padding: const EdgeInsets.all(12),
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 5,
                   crossAxisSpacing: 12,
                   mainAxisSpacing: 12,
                 ),
                 itemCount: _icons.length,
                 itemBuilder: (context, index) => _buildIconItem(_icons[index]),
               ),
             ),
             const SizedBox(height: 32),

             // Save Button
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 onPressed: _saveCategory,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: _selectedColor,
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 child: const Text('Lưu danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildIconItem(IconData icon) {
    final isSelected = _selectedIcon == icon;
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: _selectedColor, width: 2) : null,
        ),
        child: Icon(icon, color: isSelected ? _selectedColor : Colors.grey.shade600),
      ),
    );
  }
}
