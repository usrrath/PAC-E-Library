import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pac_e_library_new/main.dart';
import 'package:pac_e_library_new/screens/login_screen.dart';
import 'package:pac_e_library_new/services/user_service.dart';

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
  String language = "English";

  bool notifNewReleases = true;
  bool notifRecommendations = true;
  bool enable2FA = false;
  bool loginAlerts = true;

  bool logoutLoading = false;
  bool passwordLoading = false;

  @override
  void initState() {
    super.initState();
    fontSize = _fontFromScale(MyApp.fontScale.value);
  }

  Future<void> _setMode(ThemeMode value) async {
    if (!mounted) return;
    setState(() => mode = value);
    MyApp.themeMode.value = value;
    await AppSettings.saveThemeMode(value);
  }

  Future<void> _setFontSize(FontSizePref value) async {
    if (!mounted) return;
    setState(() => fontSize = value);

    final scale = _fontScale(value);
    MyApp.fontScale.value = scale;

    await AppSettings.saveFontScale(scale);
  }

  double _fontScale(FontSizePref value) {
    switch (value) {
      case FontSizePref.small:
        return 1.10;
      case FontSizePref.medium:
        return 1.40;
      case FontSizePref.large:
        return 1.70;
    }
  }

  FontSizePref _fontFromScale(double value) {
    if (value <= 1.05) return FontSizePref.small;
    if (value >= 1.15) return FontSizePref.large;
    return FontSizePref.medium;
  }

  String _fontLabel(FontSizePref value) {
    switch (value) {
      case FontSizePref.small:
        return "Small";
      case FontSizePref.medium:
        return "Medium";
      case FontSizePref.large:
        return "Large";
    }
  }

  FontSizePref _fontFromLabel(String value) {
    if (value == "Small") return FontSizePref.small;
    if (value == "Large") return FontSizePref.large;
    return FontSizePref.medium;
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

    toast("Reset done");
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
    if (logoutLoading || passwordLoading) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Logout"),
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
      toast("Logout failed: ${e.toString().replaceFirst('Exception: ', '')}");
    } finally {
      if (mounted) {
        setState(() => logoutLoading = false);
      }
    }
  }

  Future<void> _openChangePasswordDialog() async {
    if (logoutLoading || passwordLoading) return;

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
              title: const Text("Change password"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldCtrl,
                      obscureText: obscureOld,
                      decoration: InputDecoration(
                        labelText: "Old password",
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
                        labelText: "New password",
                        helperText: "Password must be 6-10 characters",
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
                        labelText: "Confirm new password",
                        prefixIcon: const Icon(Icons.check_circle_outline_rounded),
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
                      title: const Text(
                        "Logout all devices",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        "Recommended after changing password",
                      ),
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
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final oldPassword = oldCtrl.text.trim();
                    final newPassword = newCtrl.text.trim();
                    final confirmPassword = confirmCtrl.text.trim();

                    if (oldPassword.isEmpty) {
                      toast("Old password is required");
                      return;
                    }

                    if (newPassword.length < 6 || newPassword.length > 10) {
                      toast("New password must be 6-10 characters");
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      toast("Confirm password does not match");
                      return;
                    }

                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text("Save"),
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
        throw Exception("Login token not found");
      }

      await UserService().changePassword(
        token: token,
        oldPassword: oldCtrl.text.trim(),
        newPassword: newCtrl.text.trim(),
        newPasswordConfirmation: confirmCtrl.text.trim(),
        terminateSessions: terminateSessions,
      );

      toast("Password changed successfully");

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
    final value = await _pickFromList(
      title: "Select language",
      items: const ["English", "Khmer"],
      current: language,
    );

    if (!mounted || value == null) return;

    setState(() => language = value);
  }

  Future<void> _pickFontSize() async {
    final value = await _pickFromList(
      title: "Font size",
      items: const ["Small", "Medium", "Large"],
      current: _fontLabel(fontSize),
    );

    if (!mounted || value == null) return;

    await _setFontSize(_fontFromLabel(value));
  }

  Future<String?> _pickFromList({
    required String title,
    required List<String> items,
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
                final selected = item == current;

                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_rounded, color: cs.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(item),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  bool get _busy => logoutLoading || passwordLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: "Reset settings",
            onPressed: _busy ? null : _resetSettings,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _sectionTitle("App Theme"),
          _card(
            child: Column(
              children: [
                _themeRadio("System", ThemeMode.system),
                _divider(),
                _themeRadio("Light", ThemeMode.light),
                _divider(),
                _themeRadio("Dark", ThemeMode.dark),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _sectionTitle("Reading settings defaults"),
          _card(
            child: Column(
              children: [
                _dropdownRow(
                  title: "Font size",
                  value: _fontLabel(fontSize),
                  onTap: _pickFontSize,
                ),
                _divider(),
                SwitchListTile(
                  value: rememberLastPage,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => rememberLastPage = v),
                  contentPadding: EdgeInsets.zero,
                  activeColor: cs.primary,
                  title: Text(
                    "Remember last page",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    "Continue where you left off",
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _sectionTitle("Language settings"),
          _card(
            child: _dropdownRow(
              title: "App language",
              value: language,
              onTap: _pickLanguage,
            ),
          ),

          const SizedBox(height: 18),
          _sectionTitle("Notification controls"),
          _card(
            child: Column(
              children: [
                _switchRow(
                  title: "New releases",
                  subtitle: "Get notified when new books arrive",
                  value: notifNewReleases,
                  onChanged: (v) => setState(() => notifNewReleases = v),
                ),
                _divider(),
                _switchRow(
                  title: "Recommendations",
                  subtitle: "Personalized suggestions",
                  value: notifRecommendations,
                  onChanged: (v) => setState(() => notifRecommendations = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _sectionTitle("Account security"),
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
                    "Change password",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    passwordLoading
                        ? "Changing password..."
                        : "Update your login password",
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
                  title: "Two-factor authentication (2FA)",
                  subtitle: "Extra protection for your account",
                  value: enable2FA,
                  onChanged: (v) => setState(() => enable2FA = v),
                ),
                _divider(),
                _switchRow(
                  title: "Login alerts",
                  subtitle: "Notify me about new sign-ins",
                  value: loginAlerts,
                  onChanged: (v) => setState(() => loginAlerts = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _sectionTitle("Logout"),
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
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                ),
              ),
              subtitle: Text(
                logoutLoading ? "Signing out..." : "Sign out of this account",
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

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: cs.onSurface,
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