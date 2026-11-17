import 'package:flutter/material.dart';

class DueDateSortButton extends StatelessWidget {
  const DueDateSortButton({
    super.key,
    required this.descending,
    required this.onPressed,
  });

  final bool descending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(descending ? Icons.south : Icons.north),
    label: Text(descending ? 'Prazo mais distante' : 'Prazo mais próximo'),
  );
}
