import "package:flutter/material.dart";

void main() {
  MaterialColor primaryColor = Colors.cyan;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Calculadora de IMC",
      // Herdar do tema padrão, alterando a cor primária
      theme: ThemeData.light().copyWith(
        accentColor: primaryColor,
        primaryColor: primaryColor,
        // Usar cor primária no botão
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(primary: primaryColor[700])),
      ),
      darkTheme: ThemeData.dark().copyWith(
        accentColor: primaryColor,
        primaryColor: primaryColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(primary: primaryColor)),
      ),
      // Mudar entre tema claro e escuro conforme a configuração do sistema
      themeMode: ThemeMode.system,
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _pesoController = TextEditingController();
  TextEditingController _alturaController = TextEditingController();

  IconData _icon = Icons.calculate_outlined;
  String _resultadoText = "";

  double _calcularIMC() {
    double peso;
    double altura;

    try {
      //  Aceitar pontos ou vírgulas como separador decimal
      peso = double.parse(_pesoController.text.replaceAll(",", "."));
      altura = double.parse(_alturaController.text.replaceAll(",", "."));
    } catch (FormatException) {
      // Não aceitar valores não-numéricos
      return null;
    }

    // Não aceitar valores fora dos limites humanos
    if (peso < 1 || peso > 800 || altura < 1 || altura > 3) {
      return null;
    }

    return peso / (altura * altura);
  }

  void _mostrarResultado(context) {
    double imc = _calcularIMC();
    if (imc == null) {
      setState(() {
        _resultadoText = "Dados inválidos.";
      });
      return;
    }

    String categoria;
    IconData icon;
    if (imc < 18.5) {
      categoria = "Abaixo do peso";
      icon = Icons.dinner_dining;
    } else if (imc < 25) {
      categoria = "Peso ideal";
      icon = Icons.sentiment_very_satisfied;
    } else if (imc < 30) {
      categoria = "Acima do peso";
      icon = Icons.directions_walk;
    } else {
      categoria = "Obesidade";
      icon = Icons.directions_run;
    }

    setState(() {
      _icon = icon;
      _resultadoText = "$categoria\nIMC = ${imc.toStringAsFixed(1)}";
      _hideKeyboard();
    });
  }

  void _hideKeyboard() {
    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
  }

  void _resetar() {
    _pesoController.text = "";
    _alturaController.text = "";
    setState(() {
      _icon = Icons.calculate_outlined;
      _resultadoText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
        actions: [
          IconButton(
            icon: Icon(Icons.backspace),
            tooltip: "Limpar entradas",
            onPressed: () => _resetar(),
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
                  _buildAnimatedIcon(),
                ],
              ),
              Container(
                height: 50.0,
                margin: EdgeInsets.only(top: 30.0, bottom: 30.0),
                child: ElevatedButton(
                  onPressed: () => _mostrarResultado(context),
                  child: Text(
                    "Calcular",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              ),
              Text(
                _resultadoText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  height: 1.3,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AnimatedSwitcher _buildAnimatedIcon() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOutExpo,
      child: Icon(
        _icon,
        key: ValueKey(_icon),
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
}
