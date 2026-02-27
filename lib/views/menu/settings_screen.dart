import 'package:flutter/material.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SettingsController().tr('Settings'))),
      body: Column(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController().themeMode,
            builder: (context, mode, child) {
              return SwitchListTile(
                title: Text(SettingsController().tr('Dark Theme')),
                secondary: const Icon(Icons.palette_outlined),
                value: mode == ThemeMode.dark,
                onChanged: (val) => ThemeController().toggleTheme(val),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: SettingsController().notificationsEnabled,
            builder: (context, enabled, child) {
              return SwitchListTile(
                title: Text(SettingsController().tr('Notifications')),
                secondary: const Icon(Icons.notifications_outlined),
                value: enabled,
                onChanged: (val) => SettingsController().toggleNotifications(val),
              );
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: SettingsController().language,
            builder: (context, lang, child) {
              return ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(SettingsController().tr('Language')),
                trailing: Text(lang),
                onTap: () => _showLanguageDialog(context),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, 'English'),
            _languageOption(context, 'Hindi'),
            _languageOption(context, 'Marathi'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String lang) {
    return ListTile(
      title: Text(lang),
      onTap: () {
        SettingsController().setLanguage(lang);
        Navigator.pop(context);
      },
    );
  }
}
