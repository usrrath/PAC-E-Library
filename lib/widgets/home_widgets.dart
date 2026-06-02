import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/app_localizations.dart';
import '../models/home_models.dart';
import '../utils/home_utils.dart';

class HomeBookSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<HomeBook> books;
  final void Function(HomeBook book) onTap;
  final Future<void> Function(HomeBook book) onFavorite;

  const HomeBookSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.books,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 430,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final book = books[i];

              return HomeBookCard(
                book: book,
                onTap: () => onTap(book),
                onFavorite: () => onFavorite(book),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HomeBookCard extends StatelessWidget {
  final HomeBook book;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const HomeBookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor =
    isDark ? const Color(0xFF111418) : const Color(0xFFF7F9FD);

    final borderColor =
    isDark ? const Color(0xFF252A31) : const Color(0xFFE2E8F0);

    final category =
    invalidCategory(book.category) ? t.homeNoCategory : book.category;

    return SizedBox(
      width: 200,
      height: 430,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: SafeNetImage(
                    url: book.coverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeInfoChip(
                          icon: Icons.category_outlined,
                          text: category,
                        ),
                        const SizedBox(height: 9),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 18,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            HomeInfoChip(
                              icon: Icons.visibility_rounded,
                              text: '${book.viewsCount} ${t.homeViews}',
                            ),
                            if (book.tags.isNotEmpty)
                              HomeInfoChip(
                                icon: Icons.sell_rounded,
                                text: book.tags.first,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeTopBar extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onNotifications;

  const HomeTopBar({
    super.key,
    required this.unreadCount,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.homeAppTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.homeSubtitle,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton.filledTonal(
              onPressed: onNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: TextStyle(
                      color: cs.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class HomeHeroCard extends StatefulWidget {
  final String userName;
  final int progressCount;
  final String weatherApiKey;

  const HomeHeroCard({
    super.key,
    required this.userName,
    required this.progressCount,
    required this.weatherApiKey,
  });

  @override
  State<HomeHeroCard> createState() => _HomeHeroCardState();
}

// class _HomeHeroCardState extends State<HomeHeroCard> {
//   bool weatherLoading = true;
//   String weatherStatus = 'Loading weather...';
//   IconData weatherIcon = Icons.cloud_outlined;
//
//   final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 12),
//       receiveTimeout: const Duration(seconds: 12),
//       sendTimeout: const Duration(seconds: 12),
//       headers: {
//         'User-Agent': 'PAC-E-Library/1.0',
//       },
//     ),
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(_loadWeather);
//   }
//
//   Future<void> _loadWeather() async {
//     try {
//       final location = await _getWeatherLocation();
//
//       final response = await _dio.get(
//         'https://api.open-meteo.com/v1/forecast',
//         queryParameters: {
//           'latitude': location.latitude,
//           'longitude': location.longitude,
//           'current': 'temperature_2m,weather_code',
//           'timezone': 'auto',
//         },
//       );
//
//       final data = Map<String, dynamic>.from(response.data ?? {});
//       final current = Map<String, dynamic>.from(data['current'] ?? {});
//
//       final tempValue = current['temperature_2m'];
//       final codeValue = current['weather_code'];
//
//       final temp = tempValue is num ? '${tempValue.round()}°C' : '--°C';
//       final code = codeValue is num ? codeValue.toInt() : 0;
//       final text = _weatherTextFromCode(code);
//
//       _setWeather(
//         '${location.name} • $temp • $text',
//         _weatherIconFromCode(code),
//       );
//     } catch (_) {
//       _setWeather(
//         'Weather unavailable',
//         Icons.cloud_off_rounded,
//       );
//     }
//   }
//
//   Future<_WeatherLocation> _getWeatherLocation() async {
//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//       if (!serviceEnabled) {
//         return _WeatherLocation.phnomPenh();
//       }
//
//       var permission = await Geolocator.checkPermission();
//
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission != LocationPermission.always &&
//           permission != LocationPermission.whileInUse) {
//         return _WeatherLocation.phnomPenh();
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       ).timeout(const Duration(seconds: 10));
//
//       final name = await _getDistrictName(
//         position.latitude,
//         position.longitude,
//       );
//
//       return _WeatherLocation(
//         latitude: position.latitude,
//         longitude: position.longitude,
//         name: name,
//       );
//     } catch (_) {
//       return _WeatherLocation.phnomPenh();
//     }
//   }
//
//   Future<String> _getDistrictName(
//       double latitude,
//       double longitude,
//       ) async {
//     try {
//       final response = await _dio.get(
//         'https://nominatim.openstreetmap.org/reverse',
//         queryParameters: {
//           'format': 'jsonv2',
//           'lat': latitude,
//           'lon': longitude,
//           'zoom': 14,
//           'addressdetails': 1,
//         },
//       );
//
//       final data = Map<String, dynamic>.from(response.data ?? {});
//       final address = Map<String, dynamic>.from(data['address'] ?? {});
//
//       final district = _firstValid([
//         address['city_district'],
//         address['district'],
//         address['suburb'],
//         address['quarter'],
//         address['neighbourhood'],
//         address['town'],
//         address['city'],
//         address['municipality'],
//         address['county'],
//       ]);
//
//       final province = _firstValid([
//         address['state'],
//         address['province'],
//         address['region'],
//       ]);
//
//       if (district.isNotEmpty &&
//           province.isNotEmpty &&
//           district.toLowerCase() != province.toLowerCase()) {
//         return '$district, $province';
//       }
//
//       if (district.isNotEmpty) return district;
//       if (province.isNotEmpty) return province;
//
//       return 'Current location';
//     } catch (_) {
//       return 'Current location';
//     }
//   }
//
//   String _firstValid(List<dynamic> values) {
//     for (final value in values) {
//       final text = value?.toString().trim() ?? '';
//       if (text.isNotEmpty && text.toLowerCase() != 'null') {
//         return text;
//       }
//     }
//
//     return '';
//   }
//
//   void _setWeather(String text, IconData icon) {
//     if (!mounted) return;
//
//     setState(() {
//       weatherLoading = false;
//       weatherStatus = text;
//       weatherIcon = icon;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final theme = Theme.of(context);
//     final cs = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;
//
//     final titleColor = isDark ? cs.onSurface : const Color(0xFF1B2A3A);
//     final subColor = isDark ? cs.onSurfaceVariant : const Color(0xFF5F7285);
//     final accentColor = isDark ? cs.primary : const Color(0xFF2F6EA5);
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22),
//         color: isDark
//             ? cs.surfaceContainerHighest.withOpacity(0.75)
//             : Colors.white,
//         border: Border.all(
//           color: isDark
//               ? cs.outlineVariant.withOpacity(0.25)
//               : const Color(0xFFE1EAF3),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.14)
//                 : const Color(0xFF2F6EA5).withOpacity(0.08),
//             blurRadius: 14,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(
//             // weatherLoading ? _fallbackGreetingIcon() : weatherIcon,
//             _fallbackGreetingIcon(),
//             size: 26,
//             color: accentColor,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${_greeting(context)}, ${widget.userName}',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: titleColor,
//                     fontSize: 18,
//                     height: 1.25,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.menu_book_rounded,
//                       size: 16,
//                       color: accentColor,
//                     ),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         widget.progressCount > 0
//                             ? t.homeBooksInProgress(widget.progressCount)
//                             : t.homeStartReading,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: subColor,
//                           fontSize: 13,
//                           height: 1.25,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   children: [
//                     Icon(
//                       weatherLoading
//                           ? Icons.my_location_rounded
//                           : weatherIcon,
//                       size: 14,
//                       color: accentColor,
//                     ),
//                     const SizedBox(width: 5),
//                     Expanded(
//                       child: Text(
//                         weatherStatus,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: subColor,
//                           fontSize: 12,
//                           height: 1.2,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _greeting(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final hour = DateTime.now().hour;
//
//     if (hour < 12) return t.homeGoodMorning;
//     if (hour < 17) return t.homeGoodAfternoon;
//     return t.homeGoodEvening;
//   }
//
//   IconData _fallbackGreetingIcon() {
//     final hour = DateTime.now().hour;
//
//     if (hour < 12) return Icons.wb_sunny_rounded;
//     if (hour < 17) return Icons.wb_twilight;
//     return Icons.nights_stay_outlined;
//   }
//
//   String _weatherTextFromCode(int code) {
//     switch (code) {
//       case 0:
//         return 'Clear';
//       case 1:
//       case 2:
//         return 'Partly cloudy';
//       case 3:
//         return 'Cloudy';
//       case 45:
//       case 48:
//         return 'Foggy';
//       case 51:
//       case 53:
//       case 55:
//       case 61:
//       case 63:
//       case 65:
//       case 80:
//       case 81:
//       case 82:
//         return 'Rain';
//       case 95:
//       case 96:
//       case 99:
//         return 'Thunderstorm';
//       default:
//         return 'Weather';
//     }
//   }
//
//   IconData _weatherIconFromCode(int code) {
//     switch (code) {
//       case 0:
//         return Icons.wb_sunny_rounded;
//       case 1:
//       case 2:
//         return Icons.wb_cloudy_rounded;
//       case 3:
//         return Icons.cloud_rounded;
//       case 45:
//       case 48:
//         return Icons.foggy;
//       case 95:
//       case 96:
//       case 99:
//         return Icons.thunderstorm_rounded;
//       default:
//         return Icons.water_drop_rounded;
//     }
//   }
// }

// class _WeatherLocation {
//   final double latitude;
//   final double longitude;
//   final String name;
//
//   const _WeatherLocation({
//     required this.latitude,
//     required this.longitude,
//     required this.name,
//   });
//
//   factory _WeatherLocation.phnomPenh() {
//     return const _WeatherLocation(
//       latitude: 11.5564,
//       longitude: 104.9282,
//       name: 'Phnom Penh',
//     );
//   }
// }

class _HomeHeroCardState extends State<HomeHeroCard> {
  bool weatherLoading = true;
  String weatherStatus = 'Loading weather...';
  IconData weatherIcon = Icons.cloud_outlined;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      headers: {
        'User-Agent': 'PAC-E-Library/1.0 rath01.kh@gmail.com',
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadWeather);
  }

  Future<void> _loadWeather() async {
    try {
      final location = await _getWeatherLocation();

      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'current': 'temperature_2m,weather_code',
          'timezone': 'auto',
        },
      );

      final data = Map<String, dynamic>.from(response.data ?? {});
      final current = Map<String, dynamic>.from(data['current'] ?? {});

      final tempValue = current['temperature_2m'];
      final codeValue = current['weather_code'];

      final temp = tempValue is num ? '${tempValue.round()}°C' : '--°C';
      final code = codeValue is num ? codeValue.toInt() : 0;
      final text = _weatherTextFromCode(code);

      _setWeather(
        '${location.name} • $temp • $text',
        _weatherIconFromCode(code),
      );
    } catch (_) {
      _setWeather('Weather unavailable', Icons.cloud_off_rounded);
    }
  }

  Future<_WeatherLocation> _getWeatherLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _WeatherLocation.phnomPenh();

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _WeatherLocation.phnomPenh();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      final name = await _getPlaceName(
        position.latitude,
        position.longitude,
      );

      return _WeatherLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: name,
      );
    } catch (_) {
      return _WeatherLocation.phnomPenh();
    }
  }

  Future<String> _getPlaceName(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'zoom': 18,
          'addressdetails': 1,
          'accept-language': 'en',
        },
      );

      final data = Map<String, dynamic>.from(response.data ?? {});
      final address = Map<String, dynamic>.from(data['address'] ?? {});

      final place = _firstValid([
        address['building'],
        address['amenity'],
        address['office'],
        address['shop'],
        address['tourism'],
        address['leisure'],
        address['road'],
        address['neighbourhood'],
        address['quarter'],
        address['village'],
      ]);

      final commune = _firstValid([
        address['suburb'],
        address['municipality'],
        address['city_district'],
        address['quarter'],
      ]);

      final district = _firstValid([
        address['district'],
        address['county'],
        address['city_district'],
        address['city'],
        address['town'],
      ]);

      final province = _firstValid([
        address['state'],
        address['province'],
        address['region'],
        address['city'],
      ]);

      final parts = <String>[];

      void addPart(String value) {
        final text = value.trim();
        if (text.isEmpty) return;

        final exists = parts.any(
              (e) => e.toLowerCase() == text.toLowerCase(),
        );

        if (!exists) parts.add(text);
      }

      addPart(place);
      addPart(commune);
      addPart(district);
      addPart(province);

      if (parts.isEmpty) return 'Current location';

      return parts.take(3).join(', ');
    } catch (_) {
      return 'Current location';
    }
  }

  String _firstValid(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  void _setWeather(String text, IconData icon) {
    if (!mounted) return;
    setState(() {
      weatherLoading = false;
      weatherStatus = text;
      weatherIcon = icon;
    });
  }
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? cs.onSurface : const Color(0xFF1B2A3A);
    final subColor = isDark ? cs.onSurfaceVariant : const Color(0xFF5F7285);
    final accentColor = isDark ? cs.primary : const Color(0xFF2F6EA5);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark
            ? cs.surfaceContainerHighest.withOpacity(0.75)
            : Colors.white,
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withOpacity(0.25)
              : const Color(0xFFE1EAF3),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.14)
                : const Color(0xFF2F6EA5).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            // weatherLoading ? _fallbackGreetingIcon() : weatherIcon,
            _fallbackGreetingIcon(),
            size: 26,
            color: accentColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting(context)}, ${widget.userName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.progressCount > 0
                            ? t.homeBooksInProgress(widget.progressCount)
                            : t.homeStartReading,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subColor,
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      weatherLoading
                          ? Icons.my_location_rounded
                          : weatherIcon,
                      size: 13,
                      color: accentColor,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        weatherStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subColor,
                          fontSize: 9,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;

    if (hour < 12) return t.homeGoodMorning;
    if (hour < 17) return t.homeGoodAfternoon;
    return t.homeGoodEvening;
  }

  IconData _fallbackGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_twilight;
    return Icons.nights_stay_outlined;
  }

  String _weatherTextFromCode(int code) {
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return 'Rain';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Weather';
    }
  }

  IconData _weatherIconFromCode(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
        return Icons.wb_cloudy_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.foggy;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.water_drop_rounded;
    }
  }
}

class _WeatherLocation {
  final double latitude;
  final double longitude;
  final String name;

  const _WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory _WeatherLocation.phnomPenh() {
    return const _WeatherLocation(
      latitude: 11.5564,
      longitude: 104.9282,
      name: 'Phnom Penh',
    );
  }
}



class HomeQuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const HomeQuickCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.primary.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const HomeInfoChip({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF1D2A37) : const Color(0xFFE7EEF7);
    final fg = isDark ? const Color(0xFF9CCBFF) : const Color(0xFF315F8F);

    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 36,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SafeNetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  const SafeNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget child;

    if (url.trim().isEmpty) {
      child = _fallback(cs);
    } else {
      child = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _fallback(cs, loading: true),
        errorWidget: (_, __, ___) => _fallback(cs),
      );
    }

    if (radius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }

    return child;
  }

  Widget _fallback(
      ColorScheme cs, {
        bool loading = false,
      }) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      alignment: Alignment.center,
      color: cs.primary.withOpacity(0.10),
      child: loading
          ? CircularProgressIndicator(
        strokeWidth: 2,
        color: cs.primary,
      )
          : Icon(
        Icons.menu_book_rounded,
        color: cs.primary,
      ),
    );
  }
}

class HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 34),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.18,
        ),
        Icon(
          Icons.wifi_off_rounded,
          size: 72,
          color: isDark
              ? const Color(0xFFD89A91)
              : cs.error.withOpacity(0.75),
        ),
        const SizedBox(height: 28),
        Text(
          t.homeUnableToLoad,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.72),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 78,
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(t.homeTryAgain),
            style: FilledButton.styleFrom(
              backgroundColor:
              isDark ? const Color(0xFF9DCAFA) : cs.primaryContainer,
              foregroundColor:
              isDark ? const Color(0xFF073A58) : cs.onPrimaryContainer,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
      ],
    );
  }
}