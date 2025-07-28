import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> allProducts = [];
  List<Product> filtered = [];

  String selectedCategory = '';
  final Map<int, TextEditingController> qtyControllers = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getProducts();
      setState(() {
        allProducts = products;
        filtered = products;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement produits')),
      );
    }
  }

  void _filterProducts(String category) {
    setState(() {
      selectedCategory = category;
      filtered = category.isEmpty
          ? allProducts
          : allProducts.where((p) => p.category == category).toList();
    });
  }

  Future<void> _addToCart(Product product, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final item = CartItem(
      userId: userId,
      productId: product.id!, // ✅ cast forcé
      quantity: quantity,
    );

    try {
      await ApiService.addToCart(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${product.name} ajouté au panier")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Achat"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButton<String>(
              value: selectedCategory.isEmpty ? null : selectedCategory,
              hint: const Text("Filtrer par catégorie"),
              isExpanded: true,
              items: allProducts
                  .map((p) => p.category)
                  .toSet()
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                _filterProducts(value ?? '');
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final product = filtered[index];
                final qtyController =
                    qtyControllers.putIfAbsent(product.id!, () => TextEditingController());

                return Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      Image.network(product.imageUrl, height: 100, fit: BoxFit.contain),
                      const SizedBox(height: 8),
                      Text('ID: ${product.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(product.name,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      Text('${product.price.toStringAsFixed(3)} TND',
                          style: const TextStyle(color: Colors.indigo)),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "QTE",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          final qty = int.tryParse(qtyController.text) ?? 0;
                          if (qty <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Quantité invalide")),
                            );
                            return;
                          }
                          _addToCart(product, qty);
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("AJOUTER AU PANIER"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
