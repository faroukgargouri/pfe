import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visite.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.1.14:5274/api';

  // 🔐 Connexion
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Erreur de connexion'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  // 📋 VISITES
  static Future<List<Visite>> getVisitesByUser(int userId) async {
    final url = Uri.parse('$_baseUrl/visite/user/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Visite.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement des visites');
    }
  }

  static Future<bool> addVisite(Visite visite) async {
    final url = Uri.parse('$_baseUrl/visite');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(visite.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<void> updateVisite(int id, Visite visite) async {
    final url = Uri.parse('$_baseUrl/visite/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(visite.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur mise à jour visite');
    }
  }

  static Future<void> deleteVisite(int id) async {
    final url = Uri.parse('$_baseUrl/visite/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression visite');
    }
  }

  // 👥 CLIENTS
  static Future<List<Client>> getClientsByUser(int userId) async {
    final url = Uri.parse('$_baseUrl/client/user/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement clients');
    }
  }

  static Future<bool> addClient(Client client) async {
    final url = Uri.parse('$_baseUrl/client');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<void> updateClient(int id, Client client) async {
    final url = Uri.parse('$_baseUrl/client/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur mise à jour client');
    }
  }

  static Future<void> deleteClient(int id) async {
    final url = Uri.parse('$_baseUrl/client/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression client');
    }
  }

  // 🛍️ PRODUITS
  static Future<List<Product>> getProducts() async {
    final url = Uri.parse('$_baseUrl/product');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement produits');
    }
  }

  static Future<void> addProduct(Product product) async {
    final url = Uri.parse('$_baseUrl/product');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur ajout produit");
    }
  }

  static Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$_baseUrl/product/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression produit");
    }
  }

  // 🛒 PANIER
  static Future<void> addToCart(CartItem item) async {
    final url = Uri.parse('$_baseUrl/cart');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur ajout au panier');
    }
  }
}
