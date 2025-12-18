import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';

mixin ThemeMixin on Widget {
  /// Tüm AppBar'lara tema butonu ekleyen yardımcı method
  AppBar buildAppBarWithTheme(
      BuildContext context, {
        required String title,
        List<Widget>? actions,
        bool automaticallyImplyLeading = true,
        Widget? leading,
        Color? backgroundColor,
        Color? foregroundColor,
        Color? iconThemeColor,
      }) {
    return AppBar(
      title: Text(title),
      leading: leading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: iconThemeColor != null ? IconThemeData(color: iconThemeColor) : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        // Tema değiştirme butonu - Consumer ile dinleniyor
        Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return IconButton(
              icon: Icon(settings.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => settings.toggleTheme(),
              tooltip: 'Tema Değiştir',
            );
          },
        ),
        // Orijinal actions'lar
        ...?actions,
      ],
    );
  }

  /// Scaffold için kısayol method
  Scaffold buildThemedScaffold(
      BuildContext context, {
        required String appBarTitle,
        required Widget body,
        List<Widget>? appBarActions,
        Widget? floatingActionButton,
        Widget? drawer,
        Widget? bottomNavigationBar,
        bool appBarAutomaticallyImplyLeading = true,
        Widget? appBarLeading,
      }) {
    return Scaffold(
      appBar: buildAppBarWithTheme(
        context,
        title: appBarTitle,
        actions: appBarActions,
        automaticallyImplyLeading: appBarAutomaticallyImplyLeading,
        leading: appBarLeading,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}