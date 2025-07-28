// ✅ Liste des clients avec boutons Modifier / Supprimer

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../services/api_service.dart';
import 'visit_screen.dart';
import 'add_client_screen.dart';
import 'Edit_Client_Screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    try {
      final result = await ApiService.getClientsByUser(userId);
      setState(() {
        clients = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de chargement des clients")),
      );
    }
  }

  void _selectClient(Client client) async {
    final prefs = await SharedPreferences.getInstance();
    final codeSage = prefs.getString('codeSage') ?? '';
    final fullName = prefs.getString('fullName') ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisitScreen(
          codeClient: client.codeClient,
          raisonSociale: client.raisonSociale,
          codeSage: codeSage,
          fullName: fullName,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer client"),
        content: const Text("Voulez-vous vraiment supprimer ce client ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.deleteClient(id);
              _loadClients();
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des Clients"), backgroundColor: Colors.indigo),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text("${client.codeClient} - ${client.raisonSociale}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📞 ${client.telephone}"),
                        Text("📍 ${client.ville}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditClientScreen(client: client),
                              ),
                            );
                            if (result == true) _loadClients();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, client.id!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () => _selectClient(client),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddClientScreen()),
          );
          if (result == true) _loadClients();
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
