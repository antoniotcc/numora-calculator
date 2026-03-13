import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const String kDevName = 'antonio.createsapps';
const String kAppName = 'Numora';
const String kAppDesc = 'Una calculadora simple, bonita y rápida.';
const String kAppVersion = '1.0.0';
const String kGithub = 'https://github.com/antoniotcc';
const String kEmail = 'amtoniotcc@gmail.com';
const String kSupportUrl = 'https://ko-fi.com/antoniocreatesapps';
// ════════════════════════════════════════════════════════════════

class PantallaSettings extends StatefulWidget {
  final ThemeMode temaActual;
  final ValueChanged<ThemeMode> onTemaChanged;
  final bool vibracionActiva;
  final ValueChanged<bool> onVibracionChanged;
  final bool esOscuro;

  const PantallaSettings({
    super.key,
    required this.temaActual,
    required this.esOscuro,
    required this.onTemaChanged,
    required this.vibracionActiva,
    required this.onVibracionChanged,
  });

  @override
  State<PantallaSettings> createState() => _PantallaSettingsState();
}

class _PantallaSettingsState extends State<PantallaSettings> {
  late ThemeMode _tema;
  late bool _vibracion;

  @override
  void initState() {
    super.initState();
    _tema = widget.temaActual;
    _vibracion = widget.vibracionActiva;
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _enviarEmail() async {
    final uri = Uri(scheme: 'mailto', path: kEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = widget.esOscuro;
    final Color bgColor = esOscuro
        ? const Color(0xFF1F2140)
        : const Color(0xFFEEEDF5);
    final Color cardColor = esOscuro
        ? const Color(0xFF2A2D50)
        : const Color(0xFFDDDBF0);
    final Color textoColor = esOscuro ? Colors.white : const Color(0xFF1F2140);
    final Color subColor = esOscuro ? Colors.white54 : const Color(0xFF5A5880);

    return Theme(
      data: Theme.of(context).copyWith(scaffoldBackgroundColor: bgColor),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('Configuración', style: TextStyle(color: textoColor)),
          backgroundColor: bgColor,
          iconTheme: IconThemeData(color: textoColor),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          children: [
            _Seccion(titulo: 'Apariencia', color: const Color(0xFF1ED9A4)),

            _TarjetaItem(
              icono: Icons.palette_outlined,
              titulo: 'Tema',
              subtitulo: 'Elige cómo se ve la app',
              cardColor: cardColor,
              textoColor: textoColor,
              subColor: subColor,
              trailing: DropdownButton<ThemeMode>(
                value: _tema,
                dropdownColor: cardColor,
                style: TextStyle(color: textoColor, fontSize: 14),
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Sistema', style: TextStyle(color: textoColor)),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Claro', style: TextStyle(color: textoColor)),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Oscuro', style: TextStyle(color: textoColor)),
                  ),
                ],
                onChanged: (ThemeMode? nuevoTema) {
                  if (nuevoTema != null) {
                    setState(() => _tema = nuevoTema);
                    widget.onTemaChanged(nuevoTema);
                  }
                },
              ),
            ),

            _Seccion(titulo: 'Ajustes', color: const Color(0xFF1ED9A4)),

            _TarjetaItem(
              icono: Icons.vibration,
              titulo: 'Vibración',
              subtitulo: 'Vibrar al presionar botones',
              cardColor: cardColor,
              textoColor: textoColor,
              subColor: subColor,
              trailing: Switch(
                value: _vibracion,
                activeColor: const Color(0xFF1ED9A4),
                onChanged: (valor) {
                  setState(() => _vibracion = valor);
                  widget.onVibracionChanged(valor);
                  if (valor) HapticFeedback.lightImpact();
                },
              ),
            ),

            _Seccion(titulo: 'Apoyarme', color: const Color(0xFF1ED9A4)),

            _TarjetaItem(
              icono: Icons.favorite_outline,
              iconoColor: const Color(0xFFFF6B6B),
              titulo: 'Invítame un café ☕',
              subtitulo: 'Si te gusta la app, puedes apoyarme',
              cardColor: cardColor,
              textoColor: textoColor,
              subColor: subColor,
              onTap: () => _abrirUrl(kSupportUrl),
            ),

            _Seccion(titulo: 'Acerca de mí', color: const Color(0xFF1ED9A4)),

            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF6C63FF),
                        backgroundImage: const AssetImage(
                          "lib/assets/images/avatar.jpg",
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kDevName,
                            style: TextStyle(
                              color: textoColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$kAppName v$kAppVersion',
                            style: TextStyle(color: subColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    kAppDesc,
                    style: TextStyle(color: subColor, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      _BotonRed(
                        label: 'GitHub',
                        color: const Color(0xFF6C63FF),
                        onTap: () => _abrirUrl(kGithub),
                      ),
                      const SizedBox(width: 10),
                      _BotonRed(
                        label: 'Email',
                        color: const Color(0xFF1ED9A4),
                        onTap: _enviarEmail,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final Color color;
  const _Seccion({required this.titulo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _TarjetaItem extends StatelessWidget {
  final IconData icono;
  final Color? iconoColor;
  final String titulo;
  final String subtitulo;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color textoColor;
  final Color subColor;

  const _TarjetaItem({
    required this.icono,
    this.iconoColor,
    required this.titulo,
    required this.subtitulo,
    this.trailing,
    this.onTap,
    required this.cardColor,
    required this.textoColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icono, color: iconoColor ?? const Color(0xFF6C63FF)),
        title: Text(titulo, style: TextStyle(color: textoColor, fontSize: 15)),
        subtitle: Text(
          subtitulo,
          style: TextStyle(color: subColor, fontSize: 12),
        ),
        trailing:
            trailing ??
            (onTap != null ? Icon(Icons.chevron_right, color: subColor) : null),
      ),
    );
  }
}

class _BotonRed extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BotonRed({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
