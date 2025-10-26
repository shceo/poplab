import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Устанавливаем полноэкранный режим
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Блокируем ориентацию на портретную
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BubblePopLabApp());
}

class BubblePopLabApp extends StatelessWidget {
  const BubblePopLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Pop Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: const MenuScreen(),
    );
  }
}
