import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/device_log_model.dart';
import '../services/device_logs_service.dart';

class DeviceLogsScreen extends StatefulWidget {
  const DeviceLogsScreen({super.key});

  @override
  State<DeviceLogsScreen> createState() => _DeviceLogsScreenState();
}

class _DeviceLogsScreenState extends State<DeviceLogsScreen> {
  final DeviceLogsService _service = DeviceLogsService();

  bool loading = true;
  String? errorMessage;
  List<DeviceLog> logs = [];

  AppLocalizations get t => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  bool _isInternetError(Object error) {
    final msg = error.toString();

    return msg.contains('SocketException') ||
        msg.contains('ClientException') ||
        msg.contains('Network is unreachable') ||
        msg.contains('Connection failed') ||
        msg.contains('Failed host lookup') ||
        msg.contains('No address associated with hostname') ||
        msg.contains('Connection refused') ||
        msg.contains('timed out') ||
        msg.contains('timeout');
  }

  String _friendlyError(Object error) {
    if (_isInternetError(error)) return t.deviceLogsInternetError;
    return t.deviceLogsUnableToLoad;
  }

  Future<void> _loadLogs() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await _service.getDeviceLogs().timeout(
        const Duration(seconds: 20),
      );

      if (!mounted) return;

      setState(() {
        logs = result;
        loading = false;
      });
    } on TimeoutException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = _friendlyError(e);
        loading = false;
      });
    } on SocketException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = _friendlyError(e);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = _friendlyError(e);
        loading = false;
      });
    }
  }

  IconData _deviceIcon(DeviceLog log) {
    final value =
    '${log.deviceName} ${log.deviceType} ${log.platform} ${log.browser}'
        .toLowerCase();

    if (value.contains('iphone') || value.contains('ios')) {
      return Icons.phone_iphone_rounded;
    }

    if (value.contains('android') ||
        value.contains('samsung') ||
        value.contains('pixel')) {
      return Icons.android_rounded;
    }

    if (value.contains('mac') || value.contains('macbook')) {
      return Icons.laptop_mac_rounded;
    }

    if (value.contains('windows')) {
      return Icons.desktop_windows_rounded;
    }

    if (value.contains('firefox')) {
      return Icons.public_rounded;
    }

    return Icons.devices_rounded;
  }

  Color _deviceColor(DeviceLog log) {
    final cs = Theme.of(context).colorScheme;
    final value =
    '${log.deviceName} ${log.platform} ${log.browser}'.toLowerCase();

    if (value.contains('android') || value.contains('samsung')) {
      return Colors.green;
    }

    if (value.contains('iphone') || value.contains('ios')) {
      return Colors.blue;
    }

    if (value.contains('firefox')) {
      return Colors.pink;
    }

    return cs.primary;
  }

  String _subtitle(DeviceLog log) {
    final parts = [
      if (log.browser.isNotEmpty) log.browser,
      if (log.platform.isNotEmpty) log.platform,
    ];

    return parts.isEmpty ? t.deviceLogsUnknownApp : parts.join(' ');
  }

  String _location(DeviceLog log) {
    final parts = [
      if (log.city.isNotEmpty) log.city,
      if (log.country.isNotEmpty) log.country,
    ];

    return parts.isEmpty ? t.deviceLogsUnknownLocation : parts.join(', ');
  }

  String _dateText(DeviceLog log) {
    if (log.createdAt.isEmpty) return '';

    try {
      final date = DateTime.parse(log.createdAt).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return log.createdAt;
    }
  }

  Widget _errorView() {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 74,
              color: cs.error.withOpacity(0.65),
            ),
            const SizedBox(height: 24),
            Text(
              t.deviceLogsUnableToLoad,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? t.deviceLogsInternetError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _loadLogs,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  t.deviceLogsTryAgain,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.devices_other_rounded,
              size: 76,
              color: cs.primary.withOpacity(0.75),
            ),
            const SizedBox(height: 20),
            Text(
              t.deviceLogsEmptyTitle,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.deviceLogsEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logCard(DeviceLog log) {
    final cs = Theme.of(context).colorScheme;
    final color = _deviceColor(log);
    final dateText = _dateText(log);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(
              _deviceIcon(log),
              color: color,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.deviceName.isEmpty
                            ? t.deviceLogsUnknownDevice
                            : log.deviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (log.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.deviceLogsCurrent,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _subtitle(log),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_location(log)}${dateText.isEmpty ? '' : ' • $dateText'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (log.ipAddress.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${t.deviceLogsIp}: ${log.ipAddress}',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.deviceLogsTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: t.deviceLogsRefresh,
            onPressed: loading ? null : _loadLogs,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _errorView()
          : logs.isEmpty
          ? _emptyView()
          : RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.45),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.deviceLogsHeaderSubtitle,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...logs.map(_logCard),
          ],
        ),
      ),
    );
  }
}