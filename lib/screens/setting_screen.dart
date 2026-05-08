import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '/screens/login_screen.dart';
import '/services/user_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

enum FontSizePref { small, medium, large }

class _SettingScreenState extends State<SettingScreen> {
  ThemeMode mode = MyApp.themeMode.value;
  FontSizePref fontSize = FontSizePref.medium;

  bool rememberLastPage = true;

  String languageCode = MyApp.locale.value.languageCode == "km" ? "km" : "en";

  bool notifNewReleases = true;
  bool notifRecommendations = true;
  bool enable2FA = false;
  bool loginAlerts = true;

  bool logoutLoading = false;
  bool passwordLoading = false;

  bool get _busy => logoutLoading || passwordLoading;

  @override
  void initState() {
    super.initState();
    fontSize = _fontFromScale(MyApp.fontScale.value);
    languageCode = MyApp.locale.value.languageCode == "km" ? "km" : "en";
  }

  Future<void> _setMode(ThemeMode value) async {
    if (!mounted) return;
    setState(() => mode = value);
    await MyApp.changeThemeMode(value);
  }

  Future<void> _setFontSize(FontSizePref value) async {
    if (!mounted) return;
    setState(() => fontSize = value);
    await MyApp.changeFontScale(_fontScale(value));
  }

  Future<void> _setLanguage(String code) async {
    if (!mounted) return;

    setState(() => languageCode = code);
    await MyApp.changeLocale(code);

    if (!mounted) return;
    toast(AppLocalizations.of(context)!.settingLanguageChanged);
  }

  double _fontScale(FontSizePref value) {
    switch (value) {
      case FontSizePref.small:
        return 0.90;
      case FontSizePref.medium:
        return 1.00;
      case FontSizePref.large:
        return 1.15;
    }
  }

  FontSizePref _fontFromScale(double value) {
    if (value <= 0.95) return FontSizePref.small;
    if (value >= 1.10) return FontSizePref.large;
    return FontSizePref.medium;
  }

  String _fontLabel(AppLocalizations t, FontSizePref value) {
    switch (value) {
      case FontSizePref.small:
        return t.settingSmall;
      case FontSizePref.medium:
        return t.settingMedium;
      case FontSizePref.large:
        return t.settingLarge;
    }
  }

  void toast(String message) {
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
    await AppSettings.clearAll();

    if (!mounted) return;

    await _setMode(ThemeMode.system);
    await _setFontSize(FontSizePref.medium);
    await MyApp.changeLocale("en");

    setState(() => languageCode = "en");

    if (!mounted) return;
    toast(AppLocalizations.of(context)!.settingResetDone);
  }

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("auth_token") ??
        prefs.getString("token") ??
        prefs.getString("access_token");
  }

  Future<void> _clearAuthKeepRememberMe() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool("remember_me") ?? false;
    final savedEmail = prefs.getString("user_email") ?? "";

    await prefs.remove("auth_token");
    await prefs.remove("token");
    await prefs.remove("access_token");
    await prefs.remove("user_id");
    await prefs.remove("user_name");
    await prefs.remove("user_level");
    await prefs.remove("user_photo");

    if (rememberMe) {
      await prefs.setBool("remember_me", true);
      await prefs.setString("user_email", savedEmail);
    }
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

    final t = AppLocalizations.of(context)!;

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

    setState(() => logoutLoading = true);

    try {
      final token = await _token();

      if (token != null && token.isNotEmpty) {
        try {
          await UserService().logout(token);
        } catch (_) {}
      }

      await _clearAuthKeepRememberMe();

      if (!mounted) return;
      await _goToLogin();
    } catch (e) {
      toast(
        "${t.settingLogoutFailed}: ${e.toString().replaceFirst('Exception: ', '')}",
      );
    } finally {
      if (mounted) {
        setState(() => logoutLoading = false);
      }
    }
  }

  Future<void> _openChangePasswordDialog() async {
    if (_busy) return;

    final t = AppLocalizations.of(context)!;

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
                      toast(t.settingOldPasswordRequired);
                      return;
                    }

                    if (newPassword.length < 6 || newPassword.length > 10) {
                      toast(t.settingNewPasswordLength);
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      toast(t.settingConfirmPasswordNotMatch);
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

    setState(() => passwordLoading = true);

    try {
      final token = await _token();

      if (token == null || token.isEmpty) {
        throw Exception(t.settingLoginTokenNotFound);
      }

      await UserService().changePassword(
        token: token,
        oldPassword: oldCtrl.text.trim(),
        newPassword: newCtrl.text.trim(),
        newPasswordConfirmation: confirmCtrl.text.trim(),
        terminateSessions: terminateSessions,
      );

      toast(t.settingPasswordChanged);

      await _clearAuthKeepRememberMe();

      if (!mounted) return;
      await _goToLogin();
    } catch (e) {
      toast(
        e
            .toString()
            .replaceFirst("Exception: ", "")
            .replaceFirst("Change password error: ", ""),
      );
    } finally {
      oldCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();

      if (mounted) {
        setState(() => passwordLoading = false);
      }
    }
  }

  Future<void> _pickLanguage() async {
    final t = AppLocalizations.of(context)!;

    final value = await _pickFromList(
      title: t.settingSelectLanguage,
      items: [
        _PickItem(label: t.settingEnglish, value: "en"),
        _PickItem(label: t.settingKhmer, value: "km"),
      ],
      current: languageCode,
    );

    if (!mounted || value == null) return;

    await _setLanguage(value);
  }

  Future<void> _pickFontSize() async {
    final t = AppLocalizations.of(context)!;

    final value = await _pickFromList(
      title: t.settingFontSize,
      items: [
        _PickItem(label: t.settingSmall, value: FontSizePref.small.name),
        _PickItem(label: t.settingMedium, value: FontSizePref.medium.name),
        _PickItem(label: t.settingLarge, value: FontSizePref.large.name),
      ],
      current: fontSize.name,
    );

    if (!mounted || value == null) return;

    switch (value) {
      case "small":
        await _setFontSize(FontSizePref.small);
        break;
      case "large":
        await _setFontSize(FontSizePref.large);
        break;
      default:
        await _setFontSize(FontSizePref.medium);
    }
  }

  Future<String?> _pickFromList({
    required String title,
    required List<_PickItem> items,
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
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
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

  String _languageLabel(AppLocalizations t) {
    return languageCode == "km" ? t.settingKhmer : t.settingEnglish;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _sectionTitle(t.settingAppTheme),
          _card(
            child: Column(
              children: [
                _themeRadio(t.settingSystem, ThemeMode.system),
                _divider(),
                _themeRadio(t.settingLight, ThemeMode.light),
                _divider(),
                _themeRadio(t.settingDark, ThemeMode.dark),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _sectionTitle(t.settingReadingDefaults),
          _card(
            child: Column(
              children: [
                _dropdownRow(
                  title: t.settingFontSize,
                  value: _fontLabel(t, fontSize),
                  onTap: _pickFontSize,
                ),
                // _divider(),
                // SwitchListTile(
                //   value: rememberLastPage,
                //   onChanged: _busy
                //       ? null
                //       : (v) => setState(() => rememberLastPage = v),
                //   contentPadding: EdgeInsets.zero,
                //   activeColor: cs.primary,
                //   title: Text(
                //     t.settingRememberLastPage,
                //     style: TextStyle(
                //       fontWeight: FontWeight.w800,
                //       color: cs.onSurface,
                //     ),
                //   ),
                //   subtitle: Text(
                //     t.settingContinueWhereLeftOff,
                //     style: TextStyle(color: cs.onSurfaceVariant),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _sectionTitle(t.settingLanguage),
          _card(
            child: _dropdownRow(
              title: t.settingAppLanguage,
              value: _languageLabel(t),
              onTap: _pickLanguage,
            ),
          ),
          const SizedBox(height: 18),

          _sectionTitle(t.settingNotifications),
          _card(
            child: Column(
              children: [
                _switchRow(
                  title: t.settingNewReleases,
                  subtitle: t.settingNewReleasesSubtitle,
                  value: notifNewReleases,
                  onChanged: (v) => setState(() => notifNewReleases = v),
                ),
                // _divider(),
                // _switchRow(
                //   title: t.settingRecommendations,
                //   subtitle: t.settingRecommendationsSubtitle,
                //   value: notifRecommendations,
                //   onChanged: (v) => setState(() => notifRecommendations = v),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _sectionTitle(t.settingAccountSecurity),
          _card(
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
                _divider(),
                _switchRow(
                  title: t.settingTwoFactor,
                  subtitle: t.settingTwoFactorSubtitle,
                  value: enable2FA,
                  onChanged: (v) => setState(() => enable2FA = v),
                ),
                _divider(),
                _switchRow(
                  title: t.settingLoginAlerts,
                  subtitle: t.settingLoginAlertsSubtitle,
                  value: loginAlerts,
                  onChanged: (v) => setState(() => loginAlerts = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _sectionTitle(t.settingLogout),
          _card(
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
      ),
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

  Widget _sectionTitle(String text) {
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

  Widget _card({required Widget child}) {
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

  Widget _divider() {
    final cs = Theme.of(context).colorScheme;

    return Divider(
      height: 18,
      color: cs.outlineVariant.withOpacity(0.6),
    );
  }

  Widget _dropdownRow({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
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
      onTap: _busy ? null : onTap,
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;

    return SwitchListTile(
      value: value,
      onChanged: _busy ? null : onChanged,
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

class _PickItem {
  final String label;
  final String value;

  const _PickItem({
    required this.label,
    required this.value,
  });
}