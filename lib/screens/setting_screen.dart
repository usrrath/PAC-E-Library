import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../apps/app_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/settings_model.dart';
import '../screens/login_screen.dart';
import '../services/settings_service.dart';
import '../services/user_service.dart';
import '../utils/settings_utils.dart';
import '../widgets/settings_widgets.dart';
import 'Device_Logs_Screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  ThemeMode mode = AppProvider.themeMode.value;
  FontSizePref fontSize = FontSizePref.medium;
  String languageCode =
  AppProvider.locale.value.languageCode == 'km' ? 'km' : 'en';

  bool notifNewReleases = true;
  bool enable2FA = false;
  bool loginAlerts = true;

  bool logoutLoading = false;
  bool passwordLoading = false;

  String? errorMessage;

  bool get _busy => logoutLoading || passwordLoading;

  AppLocalizations get t => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    fontSize = SettingsService.fontFromScale(AppProvider.fontScale.value);
    languageCode =
    AppProvider.locale.value.languageCode == 'km' ? 'km' : 'en';
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
    if (_isInternetError(error)) return 'Error Internet';

    final msg = error.toString().replaceFirst('Exception: ', '').trim();

    if (msg.isEmpty) return 'Something went wrong';

    return msg;
  }

  void _showInternetError(Object error) {
    setState(() {
      errorMessage = _friendlyError(error);
    });
  }

  Future<void> _setMode(ThemeMode value) async {
    setState(() => mode = value);
    await SettingsService.changeThemeMode(value);
  }

  Future<void> _setFontSize(FontSizePref value) async {
    setState(() => fontSize = value);
    await SettingsService.changeFontSize(value);
  }

  Future<void> _setLanguage(String code) async {
    setState(() => languageCode = code);
    await SettingsService.changeLanguage(code);

    if (!mounted) return;
    _toast(t.settingLanguageChanged);
  }

  String _fontLabel(FontSizePref value) {
    switch (value) {
      case FontSizePref.small:
        return t.settingSmall;
      case FontSizePref.medium:
        return t.settingMedium;
      case FontSizePref.large:
        return t.settingLarge;
    }
  }

  String _languageLabel() {
    return languageCode == 'km' ? t.settingKhmer : t.settingEnglish;
  }

  void _toast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _resetSettings() async {
    if (_busy) return;

    await SettingsService.resetSettings();

    if (!mounted) return;

    setState(() {
      mode = ThemeMode.system;
      fontSize = FontSizePref.medium;
      languageCode = 'en';
      errorMessage = null;
    });

    _toast(t.settingResetDone);
  }

  Future<void> _goToLogin() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  Future<void> _confirmLogout() async {
    if (_busy) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.settingLogout),
          content: Text(t.settingLogoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(t.settingCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(t.settingLogout),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    setState(() {
      logoutLoading = true;
      errorMessage = null;
    });

    try {
      final token = await SettingsService.token();

      if (token != null && token.isNotEmpty) {
        try {
          await UserService().logout(token).timeout(
            const Duration(seconds: 20),
          );
        } catch (_) {}
      }

      await SettingsService.clearAuthKeepRememberMe();

      if (!mounted) return;
      await _goToLogin();
    } on TimeoutException catch (e) {
      _showInternetError(e);
    } on SocketException catch (e) {
      _showInternetError(e);
    } catch (e) {
      if (_isInternetError(e)) {
        _showInternetError(e);
      } else {
        _toast('${t.settingLogoutFailed}: ${SettingsUtils.cleanError(e)}');
      }
    } finally {
      if (mounted) setState(() => logoutLoading = false);
    }
  }

  Future<void> _openChangePasswordDialog() async {
    if (_busy) return;

    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    bool terminateSessions = true;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.settingChangePassword),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldCtrl,
                      obscureText: obscureOld,
                      decoration: InputDecoration(
                        labelText: t.settingOldPassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() => obscureOld = !obscureOld);
                          },
                          icon: Icon(
                            obscureOld
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: t.settingNewPassword,
                        helperText: t.settingPasswordHelper,
                        prefixIcon: const Icon(Icons.password_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() => obscureNew = !obscureNew);
                          },
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmCtrl,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: t.settingConfirmNewPassword,
                        prefixIcon: const Icon(
                          Icons.check_circle_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: terminateSessions,
                      title: Text(
                        t.settingLogoutAllDevices,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(t.settingRecommendedAfterPassword),
                      onChanged: (value) {
                        setDialogState(() => terminateSessions = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(t.settingCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final oldPassword = oldCtrl.text.trim();
                    final newPassword = newCtrl.text.trim();
                    final confirmPassword = confirmCtrl.text.trim();

                    if (oldPassword.isEmpty) {
                      _toast(t.settingOldPasswordRequired);
                      return;
                    }

                    if (newPassword.length < 6 || newPassword.length > 10) {
                      _toast(t.settingNewPasswordLength);
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      _toast(t.settingConfirmPasswordNotMatch);
                      return;
                    }

                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(t.settingSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      oldCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();
      return;
    }

    setState(() {
      passwordLoading = true;
      errorMessage = null;
    });

    try {
      final token = await SettingsService.token();

      if (token == null || token.isEmpty) {
        throw Exception(t.settingLoginTokenNotFound);
      }

      await UserService().changePassword(
        token: token,
        oldPassword: oldCtrl.text.trim(),
        newPassword: newCtrl.text.trim(),
        newPasswordConfirmation: confirmCtrl.text.trim(),
        terminateSessions: terminateSessions,
      ).timeout(const Duration(seconds: 20));

      _toast(t.settingPasswordChanged);

      await SettingsService.clearAuthKeepRememberMe();

      if (!mounted) return;
      await _goToLogin();
    } on TimeoutException catch (e) {
      _showInternetError(e);
    } on SocketException catch (e) {
      _showInternetError(e);
    } catch (e) {
      if (_isInternetError(e)) {
        _showInternetError(e);
      } else {
        _toast(SettingsUtils.cleanError(e));
      }
    } finally {
      oldCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();

      if (mounted) setState(() => passwordLoading = false);
    }
  }

  Future<void> _pickLanguage() async {
    final value = await _pickFromList(
      title: t.settingSelectLanguage,
      items: [
        PickItem(label: t.settingEnglish, value: 'en'),
        PickItem(label: t.settingKhmer, value: 'km'),
      ],
      current: languageCode,
    );

    if (!mounted || value == null) return;

    await _setLanguage(value);
  }

  Future<void> _pickFontSize() async {
    final value = await _pickFromList(
      title: t.settingFontSize,
      items: [
        PickItem(label: t.settingSmall, value: FontSizePref.small.name),
        PickItem(label: t.settingMedium, value: FontSizePref.medium.name),
        PickItem(label: t.settingLarge, value: FontSizePref.large.name),
      ],
      current: fontSize.name,
    );

    if (!mounted || value == null) return;

    switch (value) {
      case 'small':
        await _setFontSize(FontSizePref.small);
        break;
      case 'large':
        await _setFontSize(FontSizePref.large);
        break;
      default:
        await _setFontSize(FontSizePref.medium);
    }
  }

  Future<String?> _pickFromList({
    required String title,
    required List<PickItem> items,
    required String current,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final cs = Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              ...items.map((item) {
                final selected = item.value == current;

                return ListTile(
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight:
                      selected ? FontWeight.w900 : FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_rounded, color: cs.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(item.value),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _themeRadio(String title, ThemeMode value) {
    final cs = Theme.of(context).colorScheme;

    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: mode,
      onChanged: _busy
          ? null
          : (v) {
        if (v != null) _setMode(v);
      },
      activeColor: cs.primary,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
    );
  }

  Widget _internetErrorView(String message) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 70, 28, 28),
      children: [
        const SizedBox(height: 30),
        Icon(
          Icons.wifi_off_rounded,
          size: 72,
          color: cs.error.withOpacity(0.65),
        ),
        const SizedBox(height: 38),
        Text(
          'Unable to load settings',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 42),
        SizedBox(
          width: double.infinity,
          height: 76,
          child: FilledButton.icon(
            onPressed: () {
              setState(() => errorMessage = null);
            },
            icon: const Icon(Icons.refresh_rounded, size: 24),
            label: const Text(
              'Try again',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsBody() {
    final cs = Theme.of(context).colorScheme;
    bool enableBiometrics = false;

    void _openGoogleAuthSetupDialog() {
      setState(() => enable2FA = true);
    }

    void _openDeviceLogsScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DeviceLogsScreen()),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        SettingsSectionTitle(text: t.settingAppTheme),
        SettingsCard(
          child: Column(
            children: [
              _themeRadio(t.settingSystem, ThemeMode.system),
              const SettingsDivider(),
              _themeRadio(t.settingLight, ThemeMode.light),
              const SettingsDivider(),
              _themeRadio(t.settingDark, ThemeMode.dark),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingReadingDefaults),
        SettingsCard(
          child: SettingsDropdownRow(
            title: t.settingFontSize,
            value: _fontLabel(fontSize),
            onTap: _busy ? null : _pickFontSize,
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingLanguage),
        SettingsCard(
          child: SettingsDropdownRow(
            title: t.settingAppLanguage,
            value: _languageLabel(),
            onTap: _busy ? null : _pickLanguage,
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(
          text: t.settingNotifications,
        ),

        SettingsCard(
          child: Column(
            children: [
              SettingsSwitchRow(
                title: t.settingNewReleases,
                subtitle: t.settingNewReleasesSubtitle,
                value: notifNewReleases,
                onChanged: _busy
                    ? null
                    : (v) => setState(
                      () => notifNewReleases = v,
                ),
              ),

              const SettingsDivider(),

              SettingsSwitchRow(
                title: t.settingLoginAlerts,
                subtitle: t.settingLoginAlertsSubtitle,
                value: loginAlerts,
                onChanged: _busy
                    ? null
                    : (v) => setState(
                      () => loginAlerts = v,
                ),
              ),
            ],
          ),
        ),


        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingAccountSecurity),
        // SettingsCard(
        //   child: Column(
        //     children: [
        //       ListTile(
        //         contentPadding: EdgeInsets.zero,
        //         leading: passwordLoading
        //             ? const SizedBox(
        //           width: 24,
        //           height: 24,
        //           child: CircularProgressIndicator(strokeWidth: 2),
        //         )
        //             : Icon(
        //           Icons.lock_reset_rounded,
        //           color: cs.primary,
        //         ),
        //         title: Text(
        //           t.settingChangePassword,
        //           style: TextStyle(
        //             fontWeight: FontWeight.w800,
        //             color: cs.onSurface,
        //           ),
        //         ),
        //         subtitle: Text(
        //           passwordLoading
        //               ? t.settingChangingPassword
        //               : t.settingUpdateLoginPassword,
        //           style: TextStyle(color: cs.onSurfaceVariant),
        //         ),
        //         trailing: Icon(
        //           Icons.chevron_right_rounded,
        //           color: cs.onSurfaceVariant,
        //         ),
        //         onTap: _busy ? null : _openChangePasswordDialog,
        //       ),
        //       const SettingsDivider(),
        //       SettingsSwitchRow(
        //         title: t.settingTwoFactor,
        //         subtitle: t.settingTwoFactorSubtitle,
        //         value: enable2FA,
        //         onChanged: _busy ? null : (v) => setState(() => enable2FA = v),
        //       ),
        //
        //     ],
        //   ),
        // ),
        SettingsCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: passwordLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(
                  Icons.lock_reset_rounded,
                  color: cs.primary,
                ),
                title: Text(
                  t.settingChangePassword,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  passwordLoading
                      ? t.settingChangingPassword
                      : t.settingUpdateLoginPassword,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: _busy ? null : _openChangePasswordDialog,
              ),

              const SettingsDivider(),

              SettingsSwitchRow(
                title: t.settingTwoFactor,
                subtitle: enable2FA
                    ? t.settingTwoFactorGoogleAuthEnabled
                    : t.settingTwoFactorGoogleAuthSubtitle,
                value: enable2FA,
                onChanged: _busy
                    ? null
                    : (v) {
                  if (v) {
                    _openGoogleAuthSetupDialog();
                  } else {
                    setState(() => enable2FA = false);
                  }
                },
              ),

              const SettingsDivider(),

              SettingsSwitchRow(
                title: t.settingBiometrics,
                subtitle: t.settingBiometricsSubtitle,
                value: enableBiometrics,
                onChanged: _busy
                    ? null
                    : (v) => setState(() => enableBiometrics = v),
              ),

              const SettingsDivider(),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.devices_rounded,
                  color: cs.primary,
                ),
                title: Text(
                  t.settingDeviceLogs,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  t.settingDeviceLogsSubtitle,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: _busy ? null : _openDeviceLogsScreen,
              ),
            ],
          ),
        ),



        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingLogout),
        SettingsCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: logoutLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(
              t.settingLogout,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              logoutLoading ? t.settingLoggingOut : t.settingLogoutAccount,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            onTap: _busy ? null : _confirmLogout,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: errorMessage == null
          ? AppBar(
        title: Text(
          t.settingTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: t.settingReset,
            onPressed: _busy ? null : _resetSettings,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      )
          : null,
      body: errorMessage != null
          ? _internetErrorView(errorMessage!)
          : _settingsBody(),
    );
  }
}