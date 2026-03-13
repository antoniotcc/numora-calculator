import 'package:numora/screens/pantalla_principal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaHistory extends StatefulWidget {
  final List<String> historial;
  final bool esOscuro;
  const PantallaHistory({
    super.key,
    required this.historial,
    required this.esOscuro,
  });

  @override
  State<PantallaHistory> createState() => _PantallaHistoryState();
}

class _PantallaHistoryState extends State<PantallaHistory> {
  String _formatear(String texto) {
    return texto.replaceAll('*', '×').replaceAll('/', '÷');
  }

  Future<void> _borrarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historial');
    setState(() => historial.clear());
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.esOscuro;
    final Color bgColor = dark
        ? const Color(0xFF1F2140)
        : const Color(0xFFEEEDF5);
    final Color cardColor = dark
        ? const Color(0xFF2A2D50)
        : const Color(0xFFDDDBF0);
    final Color textoColor = dark ? Colors.white : const Color(0xFF1F2140);
    final Color subColor = dark ? Colors.white54 : const Color(0xFF5A5880);
    final Color accentColor = const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Historial',
          style: TextStyle(color: textoColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textoColor),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: accentColor.withOpacity(0.3)),
        ),
      ),
      body: widget.historial.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: subColor),
                  const SizedBox(height: 16),
                  Text(
                    'Sin historial aún',
                    style: TextStyle(
                      color: subColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus cálculos aparecerán aquí',
                    style: TextStyle(
                      color: subColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: widget.historial.length,
              itemBuilder: (context, index) {
                final entrada = widget.historial[index];
                final partes = entrada.split(' = ');
                final expText = partes.isNotEmpty ? _formatear(partes[0]) : '';
                final resText = partes.length > 1 ? partes[1] : '';

                return GestureDetector(
                  onTap: () => Navigator.pop(context, resText),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(color: accentColor, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          expText,
                          style: TextStyle(color: subColor, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resText,
                          style: TextStyle(
                            color: textoColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _borrarHistorial,
        backgroundColor: const Color(0xFF0D0C24),
        foregroundColor: Colors.white,
        child: const Icon(Icons.delete_outline),
      ),
    );
  }
}
