import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class CashuDropsApp extends StatelessWidget {
  const CashuDropsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CashuDrops',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
