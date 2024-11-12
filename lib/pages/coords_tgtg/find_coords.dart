import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../global_variable.dart' as globals;

class FindTgTg extends StatefulWidget {
  @override
  FindTgTgState createState() => FindTgTgState();
}

class FindTgTgState extends State<FindTgTg> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // if (globals.savedClientId.isEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.pushReplacementNamed(context, '/');
    //   });
    // }
  }

  void _findCoords() {
    if (_formKey.currentState!.validate()) {
      final street = _streetController.text.trim();
      final zipCode = _zipCodeController.text.trim();
      final city = _cityController.text.trim();

      findCoords(street, zipCode, city);
    }
  }

  Future<void> findCoords(String street, String zipCode, String city) async {
    String adr = "$street $zipCode $city";
    
    try {
      final response = await http.post(
        Uri.parse('${globals.baseUrl}/find_coord'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"adr": adr}),
      );
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        RegExp regex = RegExp(r'"coordonates": "([^"]+)"');
        Match? match = regex.firstMatch(response.body);

        if (match != null) {
          String coordinates = match.group(1)!; 
          globals.coordonates = coordinates;
        } else {
          print("Coordonnées non trouvées");
        }
        _showSuccessMessage('Coordonnées trouvées avec succès !');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/list'); 
        }
      } else {
        final errorMessage = responseData['message'] ?? 'Une erreur est survenue';
        _showErrorMessage(errorMessage);
      }
    } catch (e) {
      _showErrorMessage('Erreur de connexion au serveur');
    }
  }

  // messages de succès
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 10),
      ),
    );
  }

  // messages d'erreur
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(
                    labelText: 'Numéro et nom de la rue',
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _zipCodeController,
                  decoration: InputDecoration(
                    labelText: 'Code postal',
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Ville',
                  ),
                  validator: (value) {
                    if (value!.isEmpty && _zipCodeController.text.isEmpty) {
                      return 'Veuillez saisir au moins la ville ou le code postal.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _findCoords,
                  child: Text('Valider'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}