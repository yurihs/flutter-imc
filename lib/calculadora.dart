import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "resultado.dart";

class Calculadora extends StatefulWidget {
  @override
  _CalculadoraState createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  TextEditingController _pesoController = TextEditingController();
  TextEditingController _alturaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pesoController.addListener(_atualizarResultado);
    _alturaController.addListener(_atualizarResultado);
  }

  Resultado _resultado;

  String get _resultadoText {
    if (_resultado == null) {
      return "";
    }
    return "${_resultado.categoriaDescription}\nIMC = ${_resultado.imc.toStringAsFixed(2)}";
  }

  IconData get _resultadoIcon => _resultado?.icon;

  bool get _canReset {
    return _pesoController.text != "" || _alturaController.text != "";
  }

  void _atualizarResultado() {
    try {
      //  Aceitar pontos ou vírgulas como separador decimal
      double peso = double.parse(_pesoController.text.replaceAll(",", "."));
      double altura = double.parse(_alturaController.text.replaceAll(",", "."));

      setState(() {
        _resultado = Resultado.fromPesoAltura(peso, altura);
      });
    } catch (FormatException) {
      // Não aceitar valores não-numéricos
    }
  }

  void _salvarResultado() {
    if (_resultado == null) {
      return;
    }
    Firestore.instance.collection("resultados").add(_resultado.toFirebase());
    _resetar();
  }

  void _resetar() {
    _pesoController.text = "";
    _alturaController.text = "";
    setState(() {
      _resultado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: "Histórico",
            onPressed: () => Navigator.pushNamed(context, "/historico"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIntroducao(context),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        _buildNumberField(
                            _pesoController, "Peso", "kilogramas"),
                        SizedBox(height: 10.0),
                        _buildNumberField(_alturaController, "Altura", "metros",
                            isLast: true),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.0),
                  _buildAnimatedIcon(_resultadoIcon),
                ],
              ),
              Container(
                  height: 80.0,
                  margin: EdgeInsets.only(top: 30.0, bottom: 10.0),
                  child: Text(
                    _resultadoText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                      height: 1.3,
                    ),
                  )),
              Container(
                height: 50.0,
                margin: EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  onPressed:
                      _resultado == null ? null : () => _salvarResultado(),
                  child: Text(
                    "Gravar no histórico",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              ),
              Container(
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _canReset ? () => _resetar() : null,
                  child: Text(
                    "Limpar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AnimatedSwitcher _buildAnimatedIcon(IconData icon) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOutExpo,
      child: Icon(
        icon,
        key: ValueKey(icon),
        size: 120.0,
      ),
    );
  }

  Container _buildIntroducao(BuildContext context) {
    // Obter cores do tema, para ajustar automaticamente entre claro e escuro.
    ThemeData theme = Theme.of(context);
    Color primaryColor = theme.primaryColor;
    Color textColor = theme.accentTextTheme.bodyText1.color;
    Color shadowColor = theme.shadowColor.withOpacity(0.25);

    return Container(
      padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, size: 20.0, color: textColor),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              "Informe as suas medidas para calcular o Índice de Massa Corporal, " +
                  "conforme as recomendações do Ministério da Saúde " +
                  "para adultos com idade maior ou igual a 20 e inferior a 60 anos.",
              style: TextStyle(fontSize: 15.0, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  TextField _buildNumberField(
      TextEditingController controller, String label, String suffix,
      {bool isLast = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: label,
          suffixText: suffix),
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 25.0,
      ),
      keyboardType: TextInputType.number,
      // Botão enter do teclado foca o próximo campo quando isLast = false.
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
  }
}
