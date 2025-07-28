import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;
  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController _codeCtrl;
  late TextEditingController _raisonCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _villeCtrl;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.client.codeClient);
    _raisonCtrl = TextEditingController(text: widget.client.raisonSociale);
    _telCtrl = TextEditingController(text: widget.client.telephone);
    _villeCtrl = TextEditingController(text: widget.client.ville);
  }

  Future<void> _updateClient() async {
    final updated = widget.client.copyWith(
      codeClient: _codeCtrl.text.trim(),
      raisonSociale: _raisonCtrl.text.trim(),
      telephone: _telCtrl.text.trim(),
      ville: _villeCtrl.text.trim(),
    );

    try {
      await ApiService.updateClient(widget.client.id!, updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client modifié avec succès.")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError("Erreur : $e");
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier Client"), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _codeCtrl, decoration: const InputDecoration(labelText: "Code Client")),
              const SizedBox(height: 12),
              TextField(controller: _raisonCtrl, decoration: const InputDecoration(labelText: "Raison Sociale")),
              const SizedBox(height: 12),
              TextField(controller: _telCtrl, decoration: const InputDecoration(labelText: "Téléphone")),
              const SizedBox(height: 12),
              TextField(controller: _villeCtrl, decoration: const InputDecoration(labelText: "Ville")),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _updateClient,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer les modifications"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
