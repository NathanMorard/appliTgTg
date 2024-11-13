import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../global_variable.dart' as globals;

class ListTgTg extends StatefulWidget {
  @override
  ListgTgState createState() => ListgTgState();
}

class ListgTgState extends State<ListTgTg> {
  List<dynamic> stores = [];
  Map<String, bool> selectedStores = {};

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      final response = await http.post(
        Uri.parse('${globals.baseUrl}/find_AllStore'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "coords": globals.coordonates,
          "id": globals.savedClientId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          stores = [];
          for (var storeString in data['stores']) {
            final idMatch = RegExp(r'Store ID: (\d+)').firstMatch(storeString);
            final nameMatch = RegExp(r'store name: (.+)').firstMatch(storeString);

            if (idMatch != null && nameMatch != null) {
              final storeId = idMatch.group(1)!;
              final storeName = nameMatch.group(1)!;

              stores.add({
                'Store ID': storeId,
                'store name': storeName,
              });

              selectedStores[storeId] = false;
            } else {
              print('FLUTTER_LOG_ERROR: Format inattendu pour un magasin : $storeString');
            }
          }
        });
      } else {
        _showErrorMessage('Erreur lors de la récupération de la liste des magasins');
      }
    } catch (e) {
      _showErrorMessage('Erreur de connexion au serveur');
    }
  }


  void _toggleStoreSelection(String storeId) {
    setState(() {
      selectedStores[storeId] = !selectedStores[storeId]!;
    });
  }

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

  Future<void> notifierTgTg(List<String> idStore) async {
    showDialog(
      context: context,
      barrierDismissible: true, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Recherche des paniers en cours...')
            ],
          ),
        );
      },
    );

    try {
      http.post(
        Uri.parse('${globals.baseUrl}/notifier'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "idStore": idStore,
          "id": globals.savedClientId,
        }),
      );

      
    } catch (e) {
      print('FLUTTER_LOG_ERROR: Erreur lors de la notification : $e');
      Navigator.of(context).pop();
      _showErrorMessage('Erreur de connexion au serveur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des magasins'),
      ),
      body: Column(
        children: [
          Expanded(
            child: stores.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      final storeId = store['Store ID'].toString();
                      return ListTile(
                        title: Text(store['store name']),
                        trailing: Checkbox(
                          value: selectedStores[storeId]!,
                          onChanged: (value) => _toggleStoreSelection(storeId),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _notifySelectedStores,
              child: Text('Notifier'),
            ),
          ),
        ],
      ),
    );
  }

  void _notifySelectedStores() {
    final selectedIds = selectedStores.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) {
      _showErrorMessage('Veuillez sélectionner au moins un magasin');
      return;
    }

    notifierTgTg(selectedIds);
}


}
