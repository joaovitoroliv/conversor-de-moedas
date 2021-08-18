import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //Biblioteca que permite fazer requisições para o servidor
//Permitir que a gente faça requisições e nao tenha que ficar esperando por elas - requisição assíncrona
import 'dart:async';

//Package para transformar os dados em JSON
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=3746b68b"; //API HG BRASIL

void main() async {
  runApp(MaterialApp(
    home: Home(),
    //Inserir um tema
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )
    ),
  )
  );
}

//Função para Retornar no Futuro
Future<Map> getData() async {
  //Mandar um GET pro servidor com a url da API (request) e pedir para o main esperar
  http.Response response = await http.get(Uri.parse(request));
  //Pedir para a API mostrar o map referente results/currencies/USD por exemplo
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Null Safety - Difereça com a aula declara variável double? dolar
  double? dolar;
  double? euro;

  //Criação dos controladores
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  //Função para apagar o texto de todos os campos
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  //Declarar funções para quando real, dolar e/ou euro for mudado
  void _realChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    //Transformar string para double
    double real = double.parse(text);
    //dolar! e euro! devido a Null Safety
    dolarController.text = (real/dolar!).toStringAsFixed(2);
    euroController.text = (real/euro!).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar!/euro!).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro!).toStringAsFixed(2);
    //euro *this.euro! - conversao para reais, depois divide pelo dolar para converter
    dolarController.text = (euro *this.euro! /dolar!).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor de Moedas \$"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      //Implementar o corpo com o Widget: Future builder contendo um Mapa
      body: FutureBuilder<Map>(
        //Especificar que Futuro que nós queremos que ele construa - getData()
          future: getData(),
          //O que ele vai mostrar na tela em cada um dos dados
          builder: (context, snapshot) {
            //Observar o status da conexão
            switch (snapshot.connectionState) {
            //Caso não esteja conectado ou esperando conexão
              case ConnectionState.none:
              case ConnectionState.waiting:
              //Retorne um Widget informando que está carregando os dados
                return Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
            //Especificar um widget default para retornar quando terminar de carregar os dados
              default:
              //Verificar se teve algum erro na hora de carregar os dados
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar Dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                //Caso nao tenha erro
                else {
                  //Pegar o valor do dolar - snap.shot.data! é para tirar o Null Safety
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  //Pegar o valor do Euro - snap.shot.data! é para tirar o Null Safety
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  //Retornar tela rolável
                  return SingleChildScrollView(
                    //Borda em todos os lados
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      //Alargar toda a coluna para preencher toda a linha
                      children: [
                        Icon(Icons.monetization_on, size: 150,
                            color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        //Dar um espaço entre os textfields - propriedade de coluna
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", dolarController, _dolarChanged),
                        //Dar um espaço entre os textfields - propriedade de coluna
                        Divider(),
                        buildTextField(
                            "Euros", "€", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

//Função para Criar o nosso Widget de campos de texto - TextField
Widget buildTextField(String label, String prefix,
    TextEditingController control, Function f) {
  //Criar o nosso text field
  return TextField(
    //Inserir os controladores
    controller: control,
    //Decoração do input text
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25
    ),
    //Chamar a função f quando o campo for alterado - Alteração Null Safety
    onChanged: f as void Function(String)?,
    //Para que só seja possível inserir números no keyboard
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}