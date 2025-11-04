import 'package:flutter/material.dart';

class MascotaFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final bool required;

  const MascotaFormField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            border: const OutlineInputBorder(),
            hintText: hintText,
          ),
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class EstadoChip extends StatelessWidget {
  final String estado;
  final bool isSelected;
  final VoidCallback onSelected;

  const EstadoChip({
    super.key,
    required this.estado,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(estado.toUpperCase()),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[200],
      selectedColor: _getEstadoColor(estado).withValues(alpha: 0.3),
      checkmarkColor: _getEstadoColor(estado),
      labelStyle: TextStyle(
        color: isSelected ? _getEstadoColor(estado) : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'perdido':
        return Colors.red;
      case 'adopcion':
        return Colors.blue;
      case 'encontrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}