import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Switch.adaptive(
          value: themeProvider.isDarkMode,
          onChanged: (value) async {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            sharedPreferences.setBool('is_dark_mode_enabled', value);

            final provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(value);
          },
        ),
        Text(
          'Dark Mode',
          style: TextStyle(
              fontSize: 12.0, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      ],
    );
  }
}
