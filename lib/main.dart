import "package:flutter/material.dart";

import "calculadora.dart";
import "historico.dart";

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
      initialRoute: "/",
      routes: {
        "/": (context) => Calculadora(),
        "/historico": (context) => Scaffold(body: Historico()),
      }
    ),
  );
}
