import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_page.dart';
import 'login_page.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _foodItems = [];
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Main Course', 'Snacks', 'Beverages', 'Desserts'];

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('food_items')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);
      setState(() => _foodItems = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      _showSnackBar('Failed to fetch items: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((i) => i['id'] == item['id']);
      if (existingIndex != -1) {
        _cartItems[existingIndex]['quantity'] = (_cartItems[existingIndex]['quantity'] ?? 1) + 1;
      } else {
        _cartItems.add({...item, 'quantity': 1});
      }
    });
    _showSnackBar('${item['name']} added to cart!');
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 'All') return _foodItems;
    return _foodItems.where((item) => (item['category'] ?? 'Main Course') == _selectedCategory).toList();
  }

  int get _cartItemCount => _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 1));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _filteredItems.isEmpty
                        ? _buildEmptyState()
                        : _buildFoodGrid(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      cartItems: _cartItems,
                      onCartUpdate: (c) => setState(() => _cartItems = c),
                    ),
                  ),
                );
              },
              backgroundColor: colorScheme.primary,
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              label: Text(
                'Cart ($_cartItemCount)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover today\'s menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fresh dishes, quick pickup from canteen.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _fetchFoodItems,
                icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
                tooltip: 'Refresh menu',
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B)),
                tooltip: 'Logout',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [colorScheme.primary, colorScheme.secondary])
                    : null,
                color: isSelected ? null : const Color(0xFF111827),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.06),
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            'No items available right now',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade300, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back in a bit. The canteen might be updating today\'s menu.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) => _buildFoodCard(_filteredItems[index]),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> item) {
    final Color accent = _getCategoryColor(item['category']);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.25), accent.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(item['category']),
                  size: 42,
                  color: accent,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['category'] ?? 'Uncategorised',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent, accent.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '₹${(item['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(item),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB661), Color(0xFFFF6B6B)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? cat) => {'Main Course': Colors.orange.shade400, 'Snacks': Colors.purple.shade400, 'Beverages': Colors.blue.shade400, 'Desserts': Colors.pink.shade400}[cat] ?? Colors.teal.shade400;
  IconData _getCategoryIcon(String? cat) => {'Main Course': Icons.rice_bowl, 'Snacks': Icons.cookie, 'Beverages': Icons.local_cafe, 'Desserts': Icons.cake}[cat] ?? Icons.fastfood;
}
