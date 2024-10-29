import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> _products = [];
  List<Map<String, String>> _filteredProducts = [];
  String _searchQuery = '';
  bool _isSearching = false;

  Future<void> _loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _products = (prefs.getStringList('products') ?? []).map((item) {
        final split = item.split('|');
        return {"name": split[0], "price": split[1]};
      }).toList();
      _filteredProducts = _products; // Initialize filtered products
    });
  }

  Future<void> _deleteProduct(String product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList('products') ?? [];
    products.remove(product);
    await prefs.setStringList('products', products);
    _loadProducts();
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredProducts = _products.where((product) {
        return product["name"]!.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _showAllProducts() {
    setState(() {
      _filteredProducts = _products; // Show all products
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.search),
                  ),
                ),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout),
                  ),
                ),
              ],
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: "Search Products"),
                onChanged: _filterProducts,
              ),
            ),
          // Shop Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hi -Fi Shop & Service",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Audio shop on Rustaveli Ave 57.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  "This shop offers both products and services",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Products",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${_filteredProducts.length}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showAllProducts,
                      child: const Text(
                        "Show all",
                        style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text("No Product Found"))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_filteredProducts[index]["name"] ?? ""),
                            Text("Price: ${_filteredProducts[index]["price"]}"),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteProduct(
                                    "${_filteredProducts[index]["name"]}|${_filteredProducts[index]["price"]}");
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddProductPage()),
        ).then((_) => _loadProducts()),
      ),
    );
  }
}
