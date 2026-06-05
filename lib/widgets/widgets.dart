import 'package:flutter/material.dart';
import '../utils/theme.dart';

// ─── TARJETA DE MÉTRICA ───
class MetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidad;
  final String estado;
  final IconData icono;
  final VoidCallback? onTap;

  const MetricaCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.unidad,
    required this.estado,
    required this.icono,
    this.onTap,
  });

  Color get _estadoColor {
    switch (estado.toLowerCase()) {
      case 'normal':
      case 'bajo peso':
        return AppColors.ok;
      case 'elevada':
      case 'alta i':
      case 'prediabetes':
      case 'alto':
      case 'sobrepeso':
        return AppColors.warn;
      default:
        return AppColors.danger;
    }
  }

  Color get _estadoBg {
    switch (estado.toLowerCase()) {
      case 'normal':
      case 'bajo peso':
        return AppColors.okBg;
      case 'elevada':
      case 'alta i':
      case 'prediabetes':
      case 'alto':
      case 'sobrepeso':
        return AppColors.warnBg;
      default:
        return AppColors.dangerBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icono, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(titulo,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ]),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                text: valor,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                    text: ' $unidad',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _estadoBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(estado,
                  style: TextStyle(color: _estadoColor, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BADGE DE ESTADO ───
class EstadoBadge extends StatelessWidget {
  final String texto;
  const EstadoBadge(this.texto, {super.key});

  Color get _color {
    switch (texto.toLowerCase()) {
      case 'normal':
        return AppColors.ok;
      case 'elevada':
      case 'alta i':
      case 'prediabetes':
        return AppColors.warn;
      default:
        return AppColors.danger;
    }
  }

  Color get _bg {
    switch (texto.toLowerCase()) {
      case 'normal':
        return AppColors.okBg;
      case 'elevada':
      case 'alta i':
      case 'prediabetes':
        return AppColors.warnBg;
      default:
        return AppColors.dangerBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(4)),
      child: Text(texto, style: TextStyle(color: _color, fontSize: 11)),
    );
  }
}

// ─── SECCIÓN TÍTULO ───
class SeccionTitulo extends StatelessWidget {
  final String titulo;
  final Widget? accion;
  const SeccionTitulo(this.titulo, {super.key, this.accion});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8)),
        if (accion != null) accion!,
      ],
    );
  }
}

// ─── ALERTA PRIORITARIA ───
class AlertaPrioritaria extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final Color color;
  final Color colorBg;
  const AlertaPrioritaria({
    super.key,
    required this.mensaje,
    required this.icono,
    required this.color,
    required this.colorBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icono, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(mensaje,
                style: TextStyle(color: color, fontSize: 12))),
      ]),
    );
  }
}
