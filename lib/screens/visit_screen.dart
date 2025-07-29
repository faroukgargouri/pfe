import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'visit_list_screen.dart';

class VisitScreen extends StatefulWidget {
  final String codeClient;
  final String raisonSociale;
  final String? codeSage;
  final String? fullName;

  const VisitScreen({
    super.key,
    required this.codeClient,
    required this.raisonSociale,
    required this.codeSage,
    this.fullName,
  });

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  late TextEditingController _dateController;
  final TextEditingController _codeClientController = TextEditingController();
  final TextEditingController _raisonSocialeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late String codeVisite;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    _codeClientController.text = widget.codeClient;
    _raisonSocialeController.text = widget.raisonSociale;

    final code = (widget.codeSage ?? 'XXX').padRight(3, 'X').substring(0, 3).toUpperCase();
    final dateCode = DateFormat('ddMMyy').format(DateTime.now());
    codeVisite = "$code$dateCode";
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('dd/MM/yyyy').parse(_dateController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<bool> _verifierClientExiste(String codeClient) async {
    final url = Uri.parse('http://192.168.54.252:5274/api/client/check/$codeClient');
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  Future<void> _saveVisit() async {
    final codeClient = _codeClientController.text.trim();
    final clientExiste = await _verifierClientExiste(codeClient);

    if (!clientExiste) {
      _showError("Ce client n'existe pas. Veuillez l'ajouter d'abord.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final url = Uri.parse('http://192.168.54.252:5274/api/visite');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "codeVisite": codeVisite,
          "dateVisite": _dateController.text.trim(),
          "codeClient": codeClient,
          "raisonSociale": _raisonSocialeController.text.trim(),
          "compteRendu": _noteController.text.trim(),
          "userId": userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Visite sauvegardée avec succès.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VisitListScreen()),
        );
      } else {
        String errorMessage = "Erreur inconnue";
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (_) {
          errorMessage = response.body;
        }
        _showError(errorMessage);
      }
    } catch (e) {
      _showError("Erreur de connexion : $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Visite client"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${widget.fullName ?? 'Utilisateur'} | ${widget.codeSage ?? 'XXX'}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Code Visite: $codeVisite",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),
                  _buildLabeledField("Date Visite", _dateController, readOnly: true, onTap: _selectDate),
                  _buildLabeledField("Code Client", _codeClientController),
                  _buildLabeledField("Raison Sociale", _raisonSocialeController),
                  _buildLabeledField("Compte Rendu", _noteController, maxLines: 4),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _saveVisit,
                    icon: const Icon(Icons.save),
                    label: const Text("Sauvegarder"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
