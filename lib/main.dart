import 'package:flutter/material.dart';
import 'package:flutter_board_getx/controllers/board_controller.dart';
import 'package:flutter_board_getx/main_screen.dart';
import 'package:flutter_board_getx/views/insert_screen.dart';
import 'package:flutter_board_getx/views/read_screen.dart';
import 'package:flutter_board_getx/views/list_screen.dart';
import 'package:flutter_board_getx/views/update_screen.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(BoardController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/main',
      getPages: [
        GetPage(
          name: '/main',
          page: () => const MainScreen(),
        ),
        GetPage(
          name: '/board/list',
          page: () => const ListScreen(),
        ),
        GetPage(
          name: '/board/read',
          page: () => const ReadScreen(),
        ),
        GetPage(
          name: '/board/insert',
          page: () => const InsertScreen(),
        ),
        GetPage(
          name: '/board/update',
          page: () => const UpdateScreen(),
        ),
      ],
    );
  }
}
