import 'package:material_ui/material_ui.dart';

import 'core/theme.dart';
import 'screens/home_shell.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'state/weather_controller.dart';

class SkyCastApp extends StatefulWidget {
  const SkyCastApp({super.key});

  @override
  State<SkyCastApp> createState() => _SkyCastAppState();
}

class _SkyCastAppState extends State<SkyCastApp> {
  late final WeatherController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(
      service: WeatherService(),
      storage: StorageService(),
    )..init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCast',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: HomeShell(controller: _controller),
    );
  }
}
