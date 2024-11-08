// import 'package:appli_tgtg/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../global_variable.dart' as globals;

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isConnected = false;
  bool isButtonEnabled = false;
  bool rememberMe = false;
  final TextEditingController _clientIdController = TextEditingController();

  Future<void> connectTgTg(String clientId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Connexion en cours'),
        content: Text('Veuillez vérifier vos mails...'),
      ),
    );

    final response = await http.post(
      // Uri.parse('${globals.baseUrl}connect_tgtg'),
      Uri.parse('http://127.0.0.1:5000/api/connect_tgtg'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"mail": clientId}),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (rememberMe) {
        globals.savedClientId = data;
      }
      print(globals.savedClientId);
      if (rememberMe) {
        globals.savedClientId = clientId;
      }
      setState(() {
        isConnected = true;
      });
    } else {
      print('Erreur : ${response.statusCode}');
    }
  }


  @override
  void initState() {
    super.initState();
    _clientIdController.addListener(() {
      setState(() {
        isButtonEnabled = _clientIdController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _clientIdController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Se souvenir de moi'),
                Switch(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                      connectTgTg(_clientIdController.text);
                    }
                  : null,
              child: Text('Se connecter'),
            ),
            if (isConnected) 
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Vous êtes connecté'),
              ),
          ],
        ),
      ),
    );
  }
}
//test