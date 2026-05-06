// import 'package:flutter/material.dart';
// import 'package:pac_e_library_new/main.dart'; // must export MyApp + AppSettings
//
// class SettingScreen extends StatefulWidget {
//   const SettingScreen({super.key});
//
//   @override
//   State<SettingScreen> createState() => _SettingScreenState();
// }
//
// enum FontSizePref { small, medium, large }
// enum PageTransitionPref { scroll, pageFlip }
// enum StoragePref { auto, internal, sdcard }
//
// class _SettingScreenState extends State<SettingScreen> {
//   /// ✅ ThemeMode (sync with app global)
//   ThemeMode mode = MyApp.themeMode.value;
//
//   /// ✅ Font size (sync with app global)
//   FontSizePref fontSize = FontSizePref.medium;
//
//   // Reading defaults
//   PageTransitionPref transition = PageTransitionPref.scroll;
//   bool autoNightMode = true;
//   bool rememberLastPage = true;
//
//   // Language
//   String language = "English";
//
//   // Storage
//   StoragePref storagePref = StoragePref.auto;
//   bool wifiOnlyDownloads = true;
//   double cacheSizeMb = 256;
//   double usedStorageMb = 412;
//
//   // Notifications
//   bool notifNewReleases = true;
//   bool notifRecommendations = true;
//   bool notifDownloads = true;
//   bool notifSystemUpdates = false;
//
//   // Security
//   bool enable2FA = false;
//   bool loginAlerts = true;
//
//   // Devices monitoring (demo logs)
//   final List<_DeviceLog> logs = [
//     _DeviceLog(
//       device: "Samsung S22 (Android)",
//       location: "Phnom Penh",
//       time: DateTime.now().subtract(const Duration(minutes: 20)),
//       status: "Active",
//     ),
//     _DeviceLog(
//       device: "Chrome (Windows)",
//       location: "Phnom Penh",
//       time: DateTime.now().subtract(const Duration(hours: 6)),
//       status: "Active",
//     ),
//     _DeviceLog(
//       device: "iPad (iOS)",
//       location: "Unknown",
//       time: DateTime.now().subtract(const Duration(days: 4)),
//       status: "Signed out",
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     fontSize = _fontFromScale(MyApp.fontScale.value);
//   }
//
//   /// =======================================================
//   /// ✅ SETTERS (theme + font) saved to secure storage
//   /// =======================================================
//   Future<void> _setMode(ThemeMode m) async {
//     setState(() => mode = m);
//     MyApp.themeMode.value = m;
//     await AppSettings.saveThemeMode(m);
//   }
//
//   Future<void> _setFontSize(FontSizePref pref) async {
//     setState(() => fontSize = pref);
//     final scale = _fontScale(pref);
//     MyApp.fontScale.value = scale;
//     await AppSettings.saveFontScale(scale);
//   }
//
//   /// =======================================================
//   /// ✅ FONT SCALE MAPPING
//   /// =======================================================
//   double _fontScale(FontSizePref p) {
//     switch (p) {
//       case FontSizePref.small:
//         return 1.05;
//       case FontSizePref.medium:
//         return 1.10;
//       case FontSizePref.large:
//         return 1.15;
//     }
//   }
//
//   FontSizePref _fontFromScale(double s) {
//     if (s <= 1.05) return FontSizePref.small;
//     if (s >= 1.15) return FontSizePref.large;
//     return FontSizePref.medium;
//   }
//
//   String _fontLabel(FontSizePref p) {
//     switch (p) {
//       case FontSizePref.small:
//         return "Small";
//       case FontSizePref.medium:
//         return "Medium";
//       case FontSizePref.large:
//         return "Large";
//     }
//   }
//
//   FontSizePref _fontFromLabel(String s) {
//     if (s == "Small") return FontSizePref.small;
//     if (s == "Large") return FontSizePref.large;
//     return FontSizePref.medium;
//   }
//
//   void toast(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
//     );
//   }
//
//   /// =======================================================
//   /// ✅ NEW: Export logs + Logout
//   /// =======================================================
//   Future<void> _exportLogs() async {
//     // Demo export: build a CSV-like string and show a message.
//     final csv = <String>[
//       "device,location,time,status",
//       ...logs.map(
//             (l) => '"${l.device}","${l.location}","${l.time.toIso8601String()}","${l.status}"',
//       ),
//     ].join("\n");
//
//     // You can later write `csv` to a file using path_provider + share_plus.
//     // For now: show preview in a dialog.
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Export logs (demo)"),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: SingleChildScrollView(
//             child: Text(csv, style: const TextStyle(fontFamily: "monospace", fontSize: 12)),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               toast("Logs exported (demo)");
//             },
//             child: const Text("Confirm"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _confirmLogout() async {
//     final cs = Theme.of(context).colorScheme;
//
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Do you want to logout?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//
//     if (ok != true || !mounted) return;
//
//     // Demo behavior:
//     // - clear secure storage (theme/font)
//     // - set app back to defaults
//     await AppSettings.clearAll();
//     MyApp.themeMode.value = ThemeMode.system;
//     MyApp.fontScale.value = _fontScale(FontSizePref.medium);
//
//     if (!mounted) return;
//     toast("Logged out (demo)");
//
//     // Optional: navigate to login screen (if you have it)
//     // Navigator.of(context).pushAndRemoveUntil(
//     //   MaterialPageRoute(builder: (_) => const LoginScreen()),
//     //   (_) => false,
//     // );
//
//     // Theme-safe feedback
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text("You are signed out."),
//         backgroundColor: cs.surface,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.w800)),
//         actions: [
//           IconButton(
//             tooltip: "Reset (clear secure storage)",
//             onPressed: () async {
//               await AppSettings.clearAll();
//               await _setMode(ThemeMode.system);
//               await _setFontSize(FontSizePref.medium);
//               if (!mounted) return;
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset done")));
//             },
//             icon: const Icon(Icons.restart_alt_rounded),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//         children: [
//           _sectionTitle("App Theme"),
//           _card(
//             child: Column(
//               children: [
//                 _themeRadio("System", ThemeMode.system),
//                 _divider(),
//                 _themeRadio("Light", ThemeMode.light),
//                 _divider(),
//                 _themeRadio("Dark", ThemeMode.dark),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 18),
//           _sectionTitle("Reading settings defaults"),
//           _card(
//             child: Column(
//               children: [
//                 _dropdownRow(
//                   title: "Font size",
//                   value: _fontLabel(fontSize),
//                   onTap: _pickFontSize,
//                 ),
//                 _divider(),
//                 // _dropdownRow(
//                 //   title: "Page transition",
//                 //   value: transition == PageTransitionPref.scroll ? "Scroll" : "Page flip",
//                 //   onTap: _pickTransition,
//                 // ),
//                 // _divider(),
//                 // SwitchListTile(
//                 //   value: autoNightMode,
//                 //   onChanged: (v) => setState(() => autoNightMode = v),
//                 //   contentPadding: EdgeInsets.zero,
//                 //   activeColor: cs.primary,
//                 //   title: Text("Auto night mode", style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
//                 //   subtitle: Text("Dim screen at night", style: TextStyle(color: cs.onSurfaceVariant)),
//                 // ),
//                 // _divider(),
//                 SwitchListTile(
//                   value: rememberLastPage,
//                   onChanged: (v) => setState(() => rememberLastPage = v),
//                   contentPadding: EdgeInsets.zero,
//                   activeColor: cs.primary,
//                   title: Text("Remember last page", style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
//                   subtitle: Text("Continue where you left off", style: TextStyle(color: cs.onSurfaceVariant)),
//                 ),
//               ],
//             ),
//           ),
//
//
//
//           const SizedBox(height: 18),
//           _sectionTitle("Language settings"),
//           _card(
//             child: Column(
//               children: [
//                 _dropdownRow(
//                   title: "App language",
//                   value: language,
//                   onTap: _pickLanguage,
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 18),
//           _sectionTitle("Storage settings"),
//           _card(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // _dropdownRow(
//                 //   title: "Storage preference",
//                 //   value: _storageLabel(storagePref),
//                 //   onTap: _pickStorage,
//                 // ),
//                 // _divider(),
//                 // SwitchListTile(
//                 //   value: wifiOnlyDownloads,
//                 //   onChanged: (v) => setState(() => wifiOnlyDownloads = v),
//                 //   contentPadding: EdgeInsets.zero,
//                 //   activeColor: cs.primary,
//                 //   title: Text("Wi-Fi only downloads",
//                 //       style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
//                 //   subtitle: Text("Avoid mobile data usage", style: TextStyle(color: cs.onSurfaceVariant)),
//                 // ),
//                 // _divider(),
//                 Text("Cache size limit", style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface)),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Slider(
//                         value: cacheSizeMb,
//                         min: 64,
//                         max: 1024,
//                         divisions: 15,
//                         label: "${cacheSizeMb.round()} MB",
//                         onChanged: (v) => setState(() => cacheSizeMb = v),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 80,
//                       child: Text(
//                         "${cacheSizeMb.round()} MB",
//                         textAlign: TextAlign.end,
//                         style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text("Used: ${usedStorageMb.round()} MB", style: TextStyle(color: cs.onSurfaceVariant)),
//                 const SizedBox(height: 10),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       setState(() => usedStorageMb = 0);
//                       toast("Cache cleared");
//                     },
//                     icon: const Icon(Icons.delete_sweep_rounded),
//                     label: const Text("Clear cache"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 18),
//           _sectionTitle("Notification controls"),
//           _card(
//             child: Column(
//               children: [
//                 _switchRow(
//                   title: "New releases",
//                   subtitle: "Get notified when new books arrive",
//                   value: notifNewReleases,
//                   onChanged: (v) => setState(() => notifNewReleases = v),
//                 ),
//                 _divider(),
//                 _switchRow(
//                   title: "Recommendations",
//                   subtitle: "Personalized suggestions",
//                   value: notifRecommendations,
//                   onChanged: (v) => setState(() => notifRecommendations = v),
//                 ),
//                 // _divider(),
//                 // _switchRow(
//                 //   title: "Downloads",
//                 //   subtitle: "Download completed alerts",
//                 //   value: notifDownloads,
//                 //   onChanged: (v) => setState(() => notifDownloads = v),
//                 // ),
//                 /*
//                 _divider(),
//                 _switchRow(
//                   title: "System updates",
//                   subtitle: "Maintenance & updates",
//                   value: notifSystemUpdates,
//                   onChanged: (v) => setState(() => notifSystemUpdates = v),
//                 ),*/
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 18),
//           _sectionTitle("Account security"),
//           _card(
//             child: Column(
//               children: [
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: Text("Change password", style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
//                   subtitle: Text("Update your login password", style: TextStyle(color: cs.onSurfaceVariant)),
//                   trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
//                   onTap: () => toast("Change password (demo)"),
//                 ),
//                 _divider(),
//                 _switchRow(
//                   title: "Two-factor authentication (2FA)",
//                   subtitle: "Extra protection for your account",
//                   value: enable2FA,
//                   onChanged: (v) => setState(() => enable2FA = v),
//                 ),
//                 _divider(),
//                 _switchRow(
//                   title: "Login alerts",
//                   subtitle: "Notify me about new sign-ins",
//                   value: loginAlerts,
//                   onChanged: (v) => setState(() => loginAlerts = v),
//                 ),
//               ],
//             ),
//           ),
//
//           // const SizedBox(height: 18),
//           // _sectionTitle("Devices monitoring & logs"),
//           // _card(
//           //   child: Column(
//           //     children: [
//           //       ...logs.map(_deviceTile).toList(),
//           //       const SizedBox(height: 8),
//           //       SizedBox(
//           //         width: double.infinity,
//           //         child: OutlinedButton.icon(
//           //           onPressed: _exportLogs,
//           //           icon: const Icon(Icons.download_rounded),
//           //           label: const Text("Export logs"),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//
//           const SizedBox(height: 18),
//           _sectionTitle("Logout"),
//           _card(
//             child: ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.logout_rounded, color: Colors.red),
//               title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red)),
//               subtitle: Text("Sign out of this account", style: TextStyle(color: cs.onSurfaceVariant)),
//               onTap: _confirmLogout,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// -------------------------
//   /// Theme radio (theme-safe)
//   /// -------------------------
//   Widget _themeRadio(String title, ThemeMode value) {
//     final cs = Theme.of(context).colorScheme;
//     return RadioListTile<ThemeMode>(
//       value: value,
//       groupValue: mode,
//       onChanged: (v) {
//         if (v != null) _setMode(v);
//       },
//       activeColor: cs.primary,
//       contentPadding: EdgeInsets.zero,
//       title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
//     );
//   }
//
//   /// -------------------------
//   /// UI helpers (theme-safe)
//   /// -------------------------
//   Widget _sectionTitle(String t) {
//     final cs = Theme.of(context).colorScheme;
//     return Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: cs.onSurface));
//   }
//
//   Widget _card({required Widget child}) {
//     final cs = Theme.of(context).colorScheme;
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: cs.primary.withOpacity(0.12)),
//         boxShadow: [
//           BoxShadow(blurRadius: 14, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10)),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   Widget _divider() {
//     final cs = Theme.of(context).colorScheme;
//     return Divider(height: 18, color: cs.outlineVariant.withOpacity(0.6));
//   }
//
//   Widget _dropdownRow({
//     required String title,
//     required String value,
//     required VoidCallback onTap,
//   }) {
//     final cs = Theme.of(context).colorScheme;
//
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
//       subtitle: Text(value, style: TextStyle(color: cs.onSurfaceVariant)),
//       trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
//       onTap: onTap,
//     );
//   }
//
//   Widget _switchRow({
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//   }) {
//     final cs = Theme.of(context).colorScheme;
//
//     return SwitchListTile(
//       value: value,
//       onChanged: onChanged,
//       contentPadding: EdgeInsets.zero,
//       activeColor: cs.primary,
//       title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
//       subtitle: Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
//     );
//   }
//
//   /// -------------------------
//   /// Pickers
//   /// -------------------------
//   void _pickLanguage() => _pickFromList(
//     title: "Select language",
//     items: const ["English", "Khmer"],
//     current: language,
//     onPick: (v) => setState(() => language = v),
//   );
//
//   void _pickFontSize() => _pickFromList(
//     title: "Font size",
//     items: const ["Small", "Medium", "Large"],
//     current: _fontLabel(fontSize),
//     onPick: (v) async {
//       final pref = _fontFromLabel(v);
//       await _setFontSize(pref);
//     },
//   );
//
//   void _pickTransition() => _pickFromList(
//     title: "Page transition",
//     items: const ["Scroll", "Page flip"],
//     current: transition == PageTransitionPref.scroll ? "Scroll" : "Page flip",
//     onPick: (v) => setState(() {
//       transition = (v == "Scroll") ? PageTransitionPref.scroll : PageTransitionPref.pageFlip;
//     }),
//   );
//
//   void _pickStorage() => _pickFromList(
//     title: "Storage preference",
//     items: const ["Auto", "Internal storage", "SD card"],
//     current: _storageLabel(storagePref),
//     onPick: (v) => setState(() => storagePref = _storageFromLabel(v)),
//   );
//
//   void _pickFromList({
//     required String title,
//     required List<String> items,
//     required String current,
//     required ValueChanged<String> onPick,
//   }) {
//     final cs = Theme.of(context).colorScheme;
//
//     showModalBottomSheet(
//       context: context,
//       showDragHandle: true,
//       builder: (_) {
//         return SafeArea(
//           child: ListView(
//             shrinkWrap: true,
//             children: [
//               ListTile(title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface))),
//               ...items.map((t) {
//                 final selected = t == current;
//                 return ListTile(
//                   title: Text(
//                     t,
//                     style: TextStyle(
//                       fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
//                       color: cs.onSurface,
//                     ),
//                   ),
//                   trailing: selected ? Icon(Icons.check_rounded, color: cs.primary) : null,
//                   onTap: () {
//                     Navigator.pop(context);
//                     onPick(t);
//                   },
//                 );
//               }),
//               const SizedBox(height: 8),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   /// -------------------------
//   /// Storage helpers
//   /// -------------------------
//   String _storageLabel(StoragePref p) {
//     switch (p) {
//       case StoragePref.auto:
//         return "Auto";
//       case StoragePref.internal:
//         return "Internal storage";
//       case StoragePref.sdcard:
//         return "SD card";
//     }
//   }
//
//   StoragePref _storageFromLabel(String s) {
//     if (s == "Internal storage") return StoragePref.internal;
//     if (s == "SD card") return StoragePref.sdcard;
//     return StoragePref.auto;
//   }
//
//   /// -------------------------
//   /// Device tile (theme-safe)
//   /// -------------------------
//   String _timeAgo(DateTime dt) {
//     final diff = DateTime.now().difference(dt);
//     if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
//     if (diff.inHours < 24) return "${diff.inHours}h ago";
//     return "${diff.inDays}d ago";
//   }
//
//   Widget _deviceTile(_DeviceLog log) {
//     final cs = Theme.of(context).colorScheme;
//     final icon = log.status == "Active" ? Icons.verified_user_rounded : Icons.history_rounded;
//     final statusColor = log.status == "Active" ? Colors.green : Colors.grey;
//
//     return Column(
//       children: [
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           leading: CircleAvatar(
//             backgroundColor: cs.primary.withOpacity(0.12),
//             child: Icon(icon, color: cs.primary),
//           ),
//           title: Text(log.device, style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface)),
//           subtitle: Text("${log.location} • ${_timeAgo(log.time)}", style: TextStyle(color: cs.onSurfaceVariant)),
//           trailing: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: statusColor.withOpacity(0.25)),
//             ),
//             child: Text(
//               log.status,
//               style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 12),
//             ),
//           ),
//         ),
//         _divider(),
//       ],
//     );
//   }
// }
//
//
//
// /// ===============================
// /// Model
// /// ===============================
// class _DeviceLog {
//   final String device;
//   final String location;
//   final DateTime time;
//   final String status;
//
//   _DeviceLog({
//     required this.device,
//     required this.location,
//     required this.time,
//     required this.status,
//   });
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pac_e_library_new/main.dart'; // MyApp + AppSettings
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

  double cacheSizeMb = 256;
  double usedStorageMb = 412;

  bool _logoutLoading = false;

  @override
  void initState() {
    super.initState();
    fontSize = _fontFromScale(MyApp.fontScale.value);
  }

  Future<void> _setMode(ThemeMode m) async {
    setState(() => mode = m);
    MyApp.themeMode.value = m;
    await AppSettings.saveThemeMode(m);
  }

  Future<void> _setFontSize(FontSizePref pref) async {
    setState(() => fontSize = pref);

    final scale = _fontScale(pref);
    MyApp.fontScale.value = scale;

    await AppSettings.saveFontScale(scale);
  }

  double _fontScale(FontSizePref p) {
    switch (p) {
      case FontSizePref.small:
        return 1.05;
      case FontSizePref.medium:
        return 1.10;
      case FontSizePref.large:
        return 1.15;
    }
  }

  FontSizePref _fontFromScale(double s) {
    if (s <= 1.05) return FontSizePref.small;
    if (s >= 1.15) return FontSizePref.large;
    return FontSizePref.medium;
  }

  String _fontLabel(FontSizePref p) {
    switch (p) {
      case FontSizePref.small:
        return "Small";
      case FontSizePref.medium:
        return "Medium";
      case FontSizePref.large:
        return "Large";
    }
  }

  FontSizePref _fontFromLabel(String s) {
    if (s == "Small") return FontSizePref.small;
    if (s == "Large") return FontSizePref.large;
    return FontSizePref.medium;
  }

  void toast(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    if (_logoutLoading) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _logoutLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        try {
          await UserService().logout(token);
        } catch (_) {
          // Continue local logout even if API logout fails.
        }
      }

      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_level');
      await prefs.remove('user_photo');
      await prefs.remove('remember_me');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    } catch (e) {
      toast("Logout failed: ${e.toString().replaceFirst('Exception: ', '')}");
    } finally {
      if (mounted) {
        setState(() => _logoutLoading = false);
      }
    }
  }

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
            onPressed: () async {
              await AppSettings.clearAll();
              await _setMode(ThemeMode.system);
              await _setFontSize(FontSizePref.medium);
              toast("Reset done");
            },
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
                  onChanged: (v) => setState(() => rememberLastPage = v),
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
          _sectionTitle("Storage settings"),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cache size limit",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: cacheSizeMb,
                        min: 64,
                        max: 1024,
                        divisions: 15,
                        label: "${cacheSizeMb.round()} MB",
                        onChanged: (v) => setState(() => cacheSizeMb = v),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        "${cacheSizeMb.round()} MB",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Used: ${usedStorageMb.round()} MB",
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => usedStorageMb = 0);
                      toast("Cache cleared");
                    },
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: const Text("Clear cache"),
                  ),
                ),
              ],
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
                  title: Text(
                    "Change password",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    "Update your login password",
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                  onTap: () => toast("Change password"),
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
              leading: _logoutLoading
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
                _logoutLoading ? "Signing out..." : "Sign out of this account",
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              onTap: _logoutLoading ? null : _confirmLogout,
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
      onChanged: (v) {
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

  Widget _sectionTitle(String t) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      t,
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
      onTap: onTap,
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

  void _pickLanguage() {
    _pickFromList(
      title: "Select language",
      items: const ["English", "Khmer"],
      current: language,
      onPick: (v) => setState(() => language = v),
    );
  }

  void _pickFontSize() {
    _pickFromList(
      title: "Font size",
      items: const ["Small", "Medium", "Large"],
      current: _fontLabel(fontSize),
      onPick: (v) async {
        await _setFontSize(_fontFromLabel(v));
      },
    );
  }

  void _pickFromList({
    required String title,
    required List<String> items,
    required String current,
    required ValueChanged<String> onPick,
  }) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
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
                      fontWeight:
                      selected ? FontWeight.w900 : FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_rounded, color: cs.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onPick(item);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}