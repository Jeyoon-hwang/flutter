import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/drawing_provider.dart';
import 'screens/home_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for immersive experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: Consumer<DrawingProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Digital Note - 공스타그램',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: provider.settings.customFontFamily ?? 'SF Pro',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF667EEA),
                brightness: provider.isDarkMode ? Brightness.dark : Brightness.light,
              ),
            ),
            home: const HomeDashboard(),
          );
        },
      ),
    );
  }
}
