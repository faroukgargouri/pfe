import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final int? id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final String reference;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.reference,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'reference': reference,
    };
  }
}

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  List<Product> products = [];
  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final referenceCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('http://192.168.1.14:5274/api/product');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        products = decoded.map((json) => Product.fromJson(json)).toList();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur chargement produits")),
      );
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _addProduct() async {
    final product = Product(
      name: nameCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      price: double.tryParse(priceCtrl.text.trim()) ?? 0,
      imageUrl: imageUrlCtrl.text.trim(),
      category: categoryCtrl.text.trim(),
      reference: referenceCtrl.text.trim(),
    );

    try {
      final url = Uri.parse('http://192.168.1.14:5274/api/product');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        nameCtrl.clear();
        descriptionCtrl.clear();
        priceCtrl.clear();
        imageUrlCtrl.clear();
        categoryCtrl.clear();
        referenceCtrl.clear();
        await _loadProducts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produit ajouté avec succès")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur backend : ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur serveur : $e")),
      );
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      final url = Uri.parse('http://192.168.1.14:5274/api/product/$id');
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        await _loadProducts();
      } else {
        throw Exception("Erreur suppression produit");
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur suppression")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Produits"), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Ajouter un produit", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nom")),
            TextField(controller: descriptionCtrl, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Prix")),
            TextField(controller: imageUrlCtrl, decoration: const InputDecoration(labelText: "Image URL")),
            TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Catégorie")),
            TextField(controller: referenceCtrl, decoration: const InputDecoration(labelText: "Référence")), // Ajouté
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text("Ajouter"),
            ),
            const Divider(height: 32),
            const Text("Liste des produits", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return ListTile(
                          leading: Image.network(p.imageUrl, height: 40, width: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                          title: Text(p.name),
                          subtitle: Text("${p.category} - ${p.price.toStringAsFixed(3)} TND\nRef: ${p.reference}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(p.id!),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}