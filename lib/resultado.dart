import "package:flutter/material.dart";

enum CategoriaPeso { abaixo, ideal, acima, obesidade }

class Resultado {
  DateTime _createdAt;
  double _peso;
  double _altura;
  double _imc;
  CategoriaPeso _categoria;

  // Construtor privado
  Resultado._(DateTime createdAt, double peso, double altura, double imc, CategoriaPeso categoria) {
    _createdAt = createdAt;
    _peso = peso;
    _altura = altura;
    _imc = imc;
    _categoria = categoria;
  }

  static Resultado fromPesoAltura(double peso, double altura) {
    // Não aceitar valores nulos
    if (peso == null || altura == null) {
      return null;
    }
    // Não aceitar valores fora dos limites humanos
    if (peso < 1 || peso > 800 || altura < 1 || altura > 3) {
      return null;
    }

    double imc = peso / (altura * altura);

    CategoriaPeso categoria;
    if (imc < 18.5) {
      categoria = CategoriaPeso.abaixo;
    } else if (imc < 25) {
      categoria = CategoriaPeso.ideal;
    } else if (imc < 30) {
      categoria = CategoriaPeso.acima;
    } else {
      categoria = CategoriaPeso.obesidade;
    }

    return Resultado._(DateTime.now(), peso, altura, imc, categoria);
  }

  static Resultado fromFirebase(Map<String, dynamic> map) {
    return Resultado._(DateTime.parse(map["timestamp"]), map["peso"], map["altura"], map["imc"],
        CategoriaPeso.values[map["categoria"]]);
  }

  Map<String, dynamic> toFirebase() {
    return {
      "timestamp": _createdAt.toIso8601String(),
      "peso": _peso,
      "altura": _altura,
      "imc": _imc,
      "categoria": _categoria.index,
    };
  }


  DateTime get createdAt => _createdAt;
  double get peso => _peso;
  double get altura => _altura;
  double get imc => _imc;

  String get categoriaDescription {
    switch (_categoria) {
      case CategoriaPeso.abaixo:
        return "Abaixo do peso";
      case CategoriaPeso.ideal:
        return "Peso ideal";
      case CategoriaPeso.acima:
        return "Acima do peso";
      case CategoriaPeso.obesidade:
        return "Obesidade";
      default:
        return "";
    }
  }

  IconData get icon {
    switch (_categoria) {
      case CategoriaPeso.abaixo:
        return Icons.dinner_dining;
      case CategoriaPeso.ideal:
        return Icons.sentiment_very_satisfied;
      case CategoriaPeso.acima:
        return Icons.directions_walk;
      case CategoriaPeso.obesidade:
        return Icons.directions_run;
      default:
        return null;
    }
  }
}
