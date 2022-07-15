import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
      theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  ));

}

Future<Map> getData() async {
  http.Response response = await http.get(
      Uri.parse('https://api.hgbrasil.com/finance?format=json&key=fe70fd43'));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {

  final TextEditingController  realController = TextEditingController();
  final TextEditingController  dolarController = TextEditingController();
  final TextEditingController  euroController = TextEditingController();


  double? dolar;
  double? euro;
  void realChanged(String text){
    double real = double.parse(text);
    dolarController.text= (real/dolar!).toStringAsFixed(2);
    euroController.text= (real/euro!).toStringAsFixed(2);
  }
  void dolarChanged(String text){
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);

  }
  void euroChanged(String text){
    double euro = double.parse(text);
    realController.text = (euro * this.euro!).toStringAsFixed(2);
    dolarController.text = (dolar! * this.dolar! / euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const  Text('\$Conversor\$'),
            backgroundColor: Colors.amber,
            centerTitle: true,
          ),
          body: FutureBuilder<Map>(
              future: getData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return  Center(
                      child:  Text(
                        'Carregando Dados...',
                        style: TextStyle(color: Colors.amber, fontSize: 25),
                      ),
                    );
                  default:
                    if(snapshot.hasError){
                      return  Center(
                        child:  Text(
                          ' Erro ao Carregando Dados :(',
                          style: TextStyle(color: Colors.amber, fontSize: 25),
                        ),
                      );
                    }else {
                      dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                      euro = snapshot.data!['results']['currencies']['EUR']['buy'];

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children:[
                            Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                            buildTexField('Reais', 'R\$', realController, realChanged),
                            Divider(),
                            buildTexField('Dólares','US\$', dolarController, dolarChanged),
                            Divider(),
                            buildTexField('Euros','€', euroController, euroChanged),
                          ],
                        ),
                      );
                    }
                }
              })
      ),
    );
  }
}
buildTexField(String label, String prefix, TextEditingController c, Function (String)f){
  return  TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix,
    ),
    style: const  TextStyle(
        color: Colors.amber, fontSize: 25
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );

}
