import 'package:flutter/material.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String text;

  const SettingsSectionTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Divider(
      height: 18,
      color: cs.outlineVariant.withOpacity(0.6),
    );
  }
}

class SettingsDropdownRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const SettingsDropdownRow({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: cs.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: cs.primary,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }
}