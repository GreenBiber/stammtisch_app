import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showText;
  final bool isCompact;

  const LanguageSwitcher({
    super.key,
    this.showText = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        if (isCompact) {
          // Kompakter Button (für AppBar)
          return IconButton(
            onPressed: () => localeProvider.toggleLanguage(),
            icon: Text(
              localeProvider.currentLanguageFlag,
              style: const TextStyle(fontSize: 20),
            ),
            tooltip: 'Sprache wechseln / Switch language',
          );
        }

        // Vollständiger Umschalter
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageButton(
                flag: '🇩🇪',
                code: 'DE',
                name: showText ? 'Deutsch' : null,
                isActive: localeProvider.isGerman,
                onTap: () => localeProvider.setGerman(),
              ),
              _LanguageButton(
                flag: '🇺🇸',
                code: 'EN',
                name: showText ? 'English' : null,
                isActive: localeProvider.isEnglish,
                onTap: () => localeProvider.setEnglish(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flag;
  final String code;
  final String? name;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flag,
    required this.code,
    this.name,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: name != null ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              code,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
            if (name != null) ...[
              const SizedBox(width: 6),
              Text(
                name!,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Quick Toggle Button für einfache Verwendung
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return ElevatedButton.icon(
          onPressed: () => localeProvider.toggleLanguage(),
          icon: Text(
            localeProvider.currentLanguageFlag,
            style: const TextStyle(fontSize: 16),
          ),
          label: Text(localeProvider.currentLanguageName),
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(Colors.grey.withOpacity(0.2)),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
        );
      },
    );
  }
}

// Language Selection Dialog
class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return AlertDialog(
          title: const Row(
            children: [
              Text('🌍'),
              SizedBox(width: 8),
              Text('Sprache wählen / Choose Language'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocaleProvider.languageInfo.entries.map((entry) {
              final langCode = entry.key;
              final info = entry.value;
              final isActive = localeProvider.locale.languageCode == langCode;

              return ListTile(
                leading: Text(
                  info['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(info['name']!),
                subtitle: Text(info['code']!),
                trailing: isActive
                    ? const Icon(Icons.check, color: Colors.teal)
                    : null,
                onTap: () {
                  localeProvider.setLocale(Locale(langCode));
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen / Close'),
            ),
          ],
        );
      },
    );
  }
}
