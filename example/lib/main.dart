import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_mouse_indicator/keyboard_mouse_indicator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final KeyboardIndicatorController controller =
      KeyboardIndicatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKey: (node, event) {
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            Positioned(
              right: 32,
              bottom: 32,
              child: KeyboardMouseIndicator(
                controller: controller,
                alignment: Alignment.bottomLeft,
                showAsHistory: true,
                maxLength: 10,
                mouseIndicator: const MouseIndicator(
                  height: 72,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FilledButton(
                onPressed: () => controller.clear(),
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
