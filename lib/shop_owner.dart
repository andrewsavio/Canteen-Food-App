import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class ShopOwner extends StatefulWidget {
  const ShopOwner({super.key});

  @override
  State<ShopOwner> createState() => _ShopOwnerState();
}

class _ShopOwnerState extends State<ShopOwner> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _foodItems = [];
  bool _isLoading = false;
  bool _isAdding = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedCategory = 'Main Course';
  final List<String> _categories = ['Main Course', 'Snacks', 'Beverages', 'Desserts'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _fetchFoodItems();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchFoodItems() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('food_items')
          .select()
          .order('created_at', ascending: false);
      
      setState(() {
        _foodItems = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showSnackBar('Failed to fetch items: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addFoodItem() async {
    if (_foodNameController.text.isEmpty || _priceController.text.isEmpty) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showSnackBar('Please enter a valid price', isError: true);
      return;
    }

    setState(() => _isAdding = true);

    try {
      final newItem = {
        'name': _foodNameController.text.trim(),
        'price': price,
        'description': _descriptionController.text.trim(),
        // Persist the selected category so students can filter items.
        'category': _selectedCategory,
        'is_available': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('food_items')
          .insert(newItem)
          .select()
          .single();

      // Add to local list immediately
      setState(() {
        _foodItems.insert(0, response);
      });

      // Clear inputs
      _foodNameController.clear();
      _priceController.clear();
      _descriptionController.clear();

      _showSnackBar('Food item added successfully!');
    } catch (e) {
      _showSnackBar('Failed to add item: $e', isError: true);
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      await supabase.from('food_items').delete().eq('id', id);
      setState(() {
        _foodItems.removeWhere((item) => item['id'] == id);
      });
      _showSnackBar('Item deleted successfully');
    } catch (e) {
      _showSnackBar('Failed to delete item: $e', isError: true);
    }
  }

  Future<void> _toggleAvailability(String id, bool currentStatus) async {
    try {
      await supabase
          .from('food_items')
          .update({'is_available': !currentStatus})
          .eq('id', id);
      
      setState(() {
        final index = _foodItems.indexWhere((item) => item['id'] == id);
        if (index != -1) {
          _foodItems[index]['is_available'] = !currentStatus;
        }
      });
    } catch (e) {
      _showSnackBar('Failed to update availability: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _logout() {
    supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddFoodSection(),
                      const SizedBox(height: 24),
                      _buildFoodListSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Canteen dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add and manage dishes for students to see.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _logout,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB661),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_circle_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add New Food Item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Food Name
          _buildInputField(
            controller: _foodNameController,
            hint: 'Food Name',
            icon: Icons.fastfood,
          ),
          const SizedBox(height: 16),

          // Price
          _buildInputField(
            controller: _priceController,
            hint: 'Price (₹)',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Description
          _buildInputField(
            controller: _descriptionController,
            hint: 'Description (optional)',
            icon: Icons.description,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF050816),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: const Color(0xFF050816),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Add Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isAdding ? null : _addFoodItem,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isAdding
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB661), Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add food item',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.orange.shade400),
        filled: true,
        fillColor: const Color(0xFF252A40),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildFoodListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Food Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade400.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_foodItems.length} items',
                style: TextStyle(
                  color: Colors.teal.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          )
        else if (_foodItems.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _foodItems.length,
            itemBuilder: (context, index) {
              return _buildFoodCard(_foodItems[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 80,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'No food items yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first item above',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> item) {
    final isAvailable = item['is_available'] ?? true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF252A40),
            const Color(0xFF1E2235),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable 
              ? Colors.teal.shade400.withOpacity(0.3)
              : Colors.grey.shade700,
        ),
      ),
      child: Row(
        children: [
          // Food Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAvailable
                    ? [Colors.teal.shade400, Colors.cyan.shade600]
                    : [Colors.grey.shade600, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(item['category']),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Food Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.white : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${item['price']?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          color: Colors.orange.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['category'] ?? 'Uncategorized',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              // Toggle Availability
              IconButton(
                onPressed: () => _toggleAvailability(item['id'], isAvailable),
                icon: Icon(
                  isAvailable ? Icons.visibility : Icons.visibility_off,
                  color: isAvailable ? Colors.green.shade400 : Colors.grey.shade500,
                ),
              ),
              // Delete
              IconButton(
                onPressed: () => _showDeleteConfirmation(item['id'], item['name']),
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252A40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$name"?',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Main Course':
        return Icons.rice_bowl;
      case 'Snacks':
        return Icons.cookie;
      case 'Beverages':
        return Icons.local_cafe;
      case 'Desserts':
        return Icons.cake;
      default:
        return Icons.fastfood;
    }
  }
}
