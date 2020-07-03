import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=8b4d12e2';

void main() async {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.orange[600],
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.deepOrange[200],
              width: 1.5,
            ),
          ),
        ),
      ),
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final TextEditingController _realControler = TextEditingController();
  final TextEditingController _dolarControler = TextEditingController();
  final TextEditingController _euroControler = TextEditingController();

  double dolar;
  double euro;

  void clearAll(){
    _dolarControler.text = '';
    _realControler.text = '';
    _euroControler.text = '';
  }

  void _realChanged(String text){
    if (text == ''){
      clearAll();
    }
    else {
      double real = double.tryParse(text);
      _dolarControler.text = (real / this.dolar).toStringAsFixed(2);
      _euroControler.text = (real / this.euro).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String text){
    if (text == ''){
      clearAll();
    }
    else {
      double dolarConv = double.tryParse(text);
      _realControler.text = (dolarConv * this.dolar).toStringAsFixed(2);
      _euroControler.text =
          ((dolarConv * this.dolar) / this.euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text){
    if (text == ''){
      clearAll();
    }
    else {
      double euroConv = double.tryParse(text);
      _realControler.text = (euroConv * this.euro).toStringAsFixed(2);
      _dolarControler.text =
          ((euroConv * this.euro) / this.dolar).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversor'),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;

            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RefreshProgressIndicator(),
                    Text(
                      'Carregando dados...',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
              break;

            case ConnectionState.active:
              break;

            case ConnectionState.done:
              dolar = snapshot.data['results']['currencies']['USD']['buy'];
              euro = snapshot.data['results']['currencies']['EUR']['buy'];

              return SingleChildScrollView(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.monetization_on,
                      size: 150,
                      color: Colors.amber,
                    ),
                  BuildTextInput('Reais', 'R\$', _realControler, _realChanged),
                    Divider(),
                    BuildTextInput('Dólar', 'US\$', _dolarControler, _dolarChanged),
                    Divider(),
                    BuildTextInput('Euro', 'E\$', _euroControler, _euroChanged),
                  ],
                ),
              );
              break;
          };
          return Text('Treta, vixi. Muitatretavixi');
        },
      ),
    );
  }
}

Widget BuildTextInput(String label, String prefix, TextEditingController controlador, Function funcao){
  return TextField(
    controller: controlador,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      hintText: ' 100.00',
      labelText: label,
      prefixText: prefix,
      prefixStyle: TextStyle(color: Colors.deepOrange[700]),
      labelStyle: TextStyle(
        fontSize: 24,
      ),
    ),
    onChanged: funcao,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
