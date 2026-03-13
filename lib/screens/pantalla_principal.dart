import 'package:numora/components/sized_button.dart';
import 'package:numora/screens/pantalla_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaPrincipal extends StatefulWidget {
  final List<String> historial;
  final bool vibracionActiva;
  final bool esOscuro;
  final Color colorDisplay;
  final Color colorBtn;
  final Color colorBtnOp;
  final Color colorBtnSpec;
  final Color colorBtnEqual;
  final VoidCallback onAbrirSettings;

  PantallaPrincipal({
    super.key,
    required this.historial,
    required this.vibracionActiva,
    required this.esOscuro,
    required this.colorDisplay,
    required this.colorBtn,
    required this.colorBtnOp,
    required this.colorBtnSpec,
    required this.colorBtnEqual,
    required this.onAbrirSettings,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

List<String> historial = [];

(List<String>, List<String>) separar(List<String> lista, String operador) {
  int indice = lista.indexOf(operador);
  return (lista.sublist(0, indice), lista.sublist(indice + 1));
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  List<String> expresion = [];
  String numerosPantalla = "0";

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> guardado = prefs.getStringList('historial') ?? [];
    setState(() => historial = guardado);
  }

  Future<void> _guardarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('historial', historial);
  }

  void _vibrar() {
    if (widget.vibracionActiva) HapticFeedback.lightImpact();
  }

  String _formatearResultado(String valor) {
    final numero = double.tryParse(valor);
    if (numero == null) return valor;
    if (numero.abs() >= 1e12 || (numero.abs() < 1e-4 && numero != 0)) {
      return numero.toStringAsExponential(3);
    }
    if (valor.contains('.')) {
      return numero
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return valor;
  }

  String _formatearDisplay(String texto) {
    String resultado = texto.replaceAll('*', '×').replaceAll('/', '÷');
    resultado = resultado.replaceAllMapped(RegExp(r'\d+(\.\d*)?'), (match) {
      String numStr = match[0]!;
      List<String> partes = numStr.split('.');
      String parteEntera = partes[0];
      String parteDecimal = partes.length > 1 ? '.${partes[1]}' : '';
      String conComas = parteEntera.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      );
      return conComas + parteDecimal;
    });
    return resultado;
  }

  String get _displayText {
    if (expresion.isNotEmpty) {
      return expresion.join() + (numerosPantalla != "0" ? numerosPantalla : "");
    }
    return numerosPantalla;
  }

  void _agregarDigito(String digito) {
    _vibrar();
    setState(() {
      if (numerosPantalla == "0") {
        numerosPantalla = digito;
      } else {
        numerosPantalla += digito;
      }
    });
  }

  void _agregarPunto() {
    _vibrar();
    setState(() {
      if (!numerosPantalla.contains(".")) numerosPantalla += ".";
    });
  }

  void _agregarOperador(String op) {
    _vibrar();
    setState(() {
      if (numerosPantalla != "0" || expresion.isNotEmpty) {
        expresion.add(numerosPantalla);
        expresion.add(op);
        numerosPantalla = "0";
      }
    });
  }

  void _agregarParentesis() {
    _vibrar();
    setState(() {
      String actual = _displayText;
      int abiertos = actual.split('(').length - 1;
      int cerrados = actual.split(')').length - 1;
      if (actual == "0") {
        numerosPantalla = "(";
      } else if (abiertos > cerrados &&
          actual.isNotEmpty &&
          actual[actual.length - 1] != '(') {
        numerosPantalla += ")";
      } else {
        String ultimo = actual[actual.length - 1];
        if (RegExp(r'[\d\.]').hasMatch(ultimo) || ultimo == ')') {
          numerosPantalla += "*(";
        } else {
          numerosPantalla += "(";
        }
      }
    });
  }

  void _borrarDigito() {
    _vibrar();
    setState(() {
      if (numerosPantalla.length > 1) {
        numerosPantalla = numerosPantalla.substring(
          0,
          numerosPantalla.length - 1,
        );
      } else {
        if (expresion.isNotEmpty) {
          expresion.removeLast();
          String ultimoNumero = expresion.removeLast();
          numerosPantalla = ultimoNumero;
        } else {
          numerosPantalla = "0";
        }
      }
    });
  }

  void _resultado() {
    _vibrar();
    setState(() {
      if (numerosPantalla != "0" || expresion.isNotEmpty) {
        String expressionStr = expresion.isEmpty
            ? numerosPantalla
            : expresion.join() + numerosPantalla;
        String primerRegistro = expressionStr;
        try {
          Parser p = Parser();
          Expression exp = p.parse(expressionStr);
          ContextModel cm = ContextModel();
          double resultado = exp.evaluate(EvaluationType.REAL, cm);
          String resultadoTexto = resultado % 1 == 0
              ? resultado.toInt().toString()
              : resultado.toString();
          numerosPantalla = _formatearResultado(resultadoTexto);
          String nuevoRegistro = primerRegistro + " = " + numerosPantalla;
          if (!historial.contains(nuevoRegistro)) {
            historial.add(nuevoRegistro);
            _guardarHistorial();
          }
          expresion = [];
        } catch (e) {
          numerosPantalla = "Error";
          expresion = [];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.esOscuro
        ? Colors.white
        : const Color(0xFF1F2140);

    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 22, left: 22, right: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: widget.colorDisplay,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                      right: 22,
                      left: 22,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatearDisplay(_displayText),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  iconSize: 30,
                  onPressed: () async {
                    final String? valorSeleccionado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaHistory(
                          historial: historial,
                          esOscuro: widget.esOscuro,
                        ),
                      ),
                    );
                    if (valorSeleccionado != null) {
                      setState(() {
                        expresion = [];
                        numerosPantalla = valorSeleccionado;
                      });
                    }
                  },
                  icon: const Icon(Icons.history),
                  color: iconColor,
                ),
                IconButton(
                  iconSize: 30,
                  onPressed: widget.onAbrirSettings,
                  icon: const Icon(Icons.settings_outlined),
                  color: iconColor,
                ),
              ],
            ),
          ),
          Row(
            spacing: 10.0,
            children: [
              Expanded(
                child: SizedButton(
                  onPressed: () {
                    _vibrar();
                    setState(() {
                      expresion = [];
                      numerosPantalla = "0";
                    });
                  },
                  texto: "C",
                  colorButton: widget.colorBtnSpec,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: _agregarParentesis,
                  texto: "(",
                  colorButton: widget.colorBtnOp,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: _borrarDigito,
                  texto: "⌫",
                  colorButton: widget.colorBtnOp,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarOperador("/"),
                  texto: "÷",
                  colorButton: widget.colorBtnOp,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10.0,
            children: [
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("7"),
                  texto: "7",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("8"),
                  texto: "8",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("9"),
                  texto: "9",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarOperador("*"),
                  texto: "×",
                  colorButton: widget.colorBtnOp,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10.0,
            children: [
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("4"),
                  texto: "4",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("5"),
                  texto: "5",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("6"),
                  texto: "6",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarOperador("-"),
                  texto: "-",
                  colorButton: widget.colorBtnOp,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10.0,
            children: [
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("1"),
                  texto: "1",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("2"),
                  texto: "2",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("3"),
                  texto: "3",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarOperador("+"),
                  texto: "+",
                  colorButton: widget.colorBtnOp,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10.0,
            children: [
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("0"),
                  texto: "0",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: () => _agregarDigito("00"),
                  texto: "00",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: _agregarPunto,
                  texto: ".",
                  colorButton: widget.colorBtn,
                ),
              ),
              Expanded(
                child: SizedButton(
                  onPressed: _resultado,
                  texto: "=",
                  colorButton: widget.colorBtnEqual,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
