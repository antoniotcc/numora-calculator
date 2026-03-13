import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantalla_principal.dart';
import 'pantalla_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> historial = [];
  ThemeMode _tema = ThemeMode.dark;
  bool _vibracion = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final t = prefs.getString('tema') ?? 'dark';
      _tema = t == 'light'
          ? ThemeMode.light
          : t == 'system'
          ? ThemeMode.system
          : ThemeMode.dark;
      _vibracion = prefs.getBool('vibracion') ?? true;
    });
  }

  Future<void> _cambiarTema(ThemeMode nuevoTema) async {
    final prefs = await SharedPreferences.getInstance();
    final valor = nuevoTema == ThemeMode.light
        ? 'light'
        : nuevoTema == ThemeMode.system
        ? 'system'
        : 'dark';
    await prefs.setString('tema', valor);
    setState(() => _tema = nuevoTema);
  }

  Future<void> _cambiarVibracion(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibracion', valor);
    setState(() => _vibracion = valor);
  }

  static const Color _lightBg = Color(0xFFEEEDF5);
  static const Color _lightDisplay = Color(0xFF2A2750);
  static const Color _lightBtn = Color(0xFFB8B5E0);
  static const Color _lightBtnOp = Color(0xFF7B78C8);
  static const Color _lightBtnSpec = Color(0xFF6C63FF);
  static const Color _lightBtnEq = Color(0xFF1ED9A4);

  static const Color _darkBg = Color(0xFF1F2140);
  static const Color _darkDisplay = Color(0xFF0D0C24);
  static const Color _darkBtn = Color(0xFF3A3D66);
  static const Color _darkBtnOp = Color(0xFF4C5DFF);
  static const Color _darkBtnSpec = Color(0xFF6C63FF);
  static const Color _darkBtnEq = Color(0xFF1ED9A4);

  @override
  Widget build(BuildContext context) {
    final bool esOscuro =
        _tema == ThemeMode.dark ||
        (_tema == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _tema,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: _lightBg,
        canvasColor: _lightBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: _lightBg,
          foregroundColor: Color(0xFF1F2140),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _darkBg,
        canvasColor: _darkBg,
        appBarTheme: const AppBarTheme(backgroundColor: _darkBg),
      ),
      home: Builder(
        builder: (ctx) => _PaginaInicio(
          esOscuro: esOscuro,
          vibracion: _vibracion,
          tema: _tema,
          onTemaChanged: _cambiarTema,
          onVibracionChanged: _cambiarVibracion,
          colores: _Colores(
            bg: esOscuro ? _darkBg : _lightBg,
            display: esOscuro ? _darkDisplay : _lightDisplay,
            btn: esOscuro ? _darkBtn : _lightBtn,
            btnOp: esOscuro ? _darkBtnOp : _lightBtnOp,
            btnSpec: esOscuro ? _darkBtnSpec : _lightBtnSpec,
            btnEqual: esOscuro ? _darkBtnEq : _lightBtnEq,
          ),
        ),
      ),
    );
  }
}

class _Colores {
  final Color bg, display, btn, btnOp, btnSpec, btnEqual;
  const _Colores({
    required this.bg,
    required this.display,
    required this.btn,
    required this.btnOp,
    required this.btnSpec,
    required this.btnEqual,
  });
}

class _PaginaInicio extends StatelessWidget {
  final bool esOscuro;
  final bool vibracion;
  final ThemeMode tema;
  final ValueChanged<ThemeMode> onTemaChanged;
  final ValueChanged<bool> onVibracionChanged;
  final _Colores colores;

  const _PaginaInicio({
    required this.esOscuro,
    required this.vibracion,
    required this.tema,
    required this.onTemaChanged,
    required this.onVibracionChanged,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colores.bg,
      appBar: AppBar(
        foregroundColor: esOscuro ? Colors.white : const Color(0xFF1F2140),
        backgroundColor: colores.bg,
        toolbarHeight: 35,
        elevation: 0,
      ),
      body: Center(
        child: PantallaPrincipal(
          historial: [],
          vibracionActiva: vibracion,
          esOscuro: esOscuro,
          colorDisplay: colores.display,
          colorBtn: colores.btn,
          colorBtnOp: colores.btnOp,
          colorBtnSpec: colores.btnSpec,
          colorBtnEqual: colores.btnEqual,
          onAbrirSettings: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                barrierColor: colores.bg,
                pageBuilder: (_, __, ___) => PantallaSettings(
                  esOscuro: esOscuro,
                  temaActual: tema,
                  onTemaChanged: onTemaChanged,
                  vibracionActiva: vibracion,
                  onVibracionChanged: onVibracionChanged,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
