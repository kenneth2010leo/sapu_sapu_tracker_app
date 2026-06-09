import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  const QuantityInputWidget({
    super.key,
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
    required this.onTap,
    required this.onChanged,
  });

  Widget _buildQtyBtn({required String icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          icon,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF1D9E75),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildQtyBtn(
          icon: '-',
          onTap: onDecrement,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0xFF222222),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onTap: onTap,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        _buildQtyBtn(
          icon: '+',
          onTap: onIncrement,
        ),
        const SizedBox(width: 12),
        const Text(
          'ekor',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
