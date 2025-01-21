import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_board_getx/models/board.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class BoardController extends GetxController {
  final RxList<Board> boardList = <Board>[].obs;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final String baseUrl = "http://localhost:8080/board";
//    var url = "http://10.0.2.2:8080/board/$no";

  late int no;

  //공통 HTTP 요청 메서드
  Future<http.Response> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/$endpoint");
      final headers = {"Content-type": "application/json"};

      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(url);
        case 'POST':
          return await http.post(url, headers: headers, body: jsonEncode(body));
        case 'PUT':
          return await http.post(url, headers: headers, body: jsonEncode(body));
        case 'DELETE':
          return await http.delete(url);
        default:
          throw Exception('Invalid HTTP method : $method');
      }
    } catch (e) {
      throw Exception('HTTP request failed : $e');
    }
  }

  ///
  /// 👩‍💻 게시글 조회 요청
  ///
  Future<void> getBoard(int no) async {
    try {
      /// await http.(...) -> _makeRequest(...)로 수정
      var response = await _makeRequest(endpoint: "read/$no", method: "GET");
      print("::::: response - body :::::");
      print(response.body);

      if (response.statusCode == 200) {
        var utf8Decoded = utf8.decode(response.bodyBytes);
        var boardJson = jsonDecode(utf8Decoded);

        _titleController.text = boardJson['title'];
        _writerController.text = boardJson['writer'];
        _contentController.text = boardJson['content'];
      } else {
        throw Exception('Failed to load board details');
      }
    } catch (e) {
      Get.snackbar("error", "failed to load board: $e");
    }
  }

  //
  // 🌞 게시글 목록 데이터 요청
  //
  Future<List<Board>> getBoardList() async {
    List<Board> list = [];

    try {
      var response = await _makeRequest(endpoint: "list", method: "GET");
      print("::::: response - body :::::");
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var utf8Decoded = utf8.decode(response.bodyBytes);
        var boardList = jsonDecode(utf8Decoded);
        for (var i = 0; i < boardList.length; i++) {
          list.add(Board(
            no: boardList[i]['no'],
            title: boardList[i]['title'],
            writer: boardList[i]['writer'],
            content: boardList[i]['content'],
          ));
        }
        print(list);
      }
    } catch (e) {
      Get.snackbar("error", "failed to fetch board list :$e");
    }

    return list;
  }

  //
  // 🌞 게시글 목록 데이터 요청
  //  fetch와 get의 차이는?
  Future<void> fetchBoardList() async {
    try {
      var response = await _makeRequest(endpoint: "list", method: "GET");
      print("::::: response - body :::::");
      print(response.body);

      if (response.statusCode == 200) {
        var boards = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        boardList.value = boards
            .map((board) => Board(
                  no: board['no'],
                  title: board['title'],
                  writer: board['writer'],
                  content: board['content'],
                ))
            .toList();
      }
    } catch (e) {
      Get.snackbar("error", "failed to fetch board list :$e");
    }
  }

  Future<void> insert2() async {
    try {
      var response =
          await _makeRequest(endpoint: "insert", method: "POST", body: {
        'title': _titleController.text,
        'writer': _writerController.text,
        'content': _contentController.text,
      });
      print("::::: response - body :::::");
      print(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Board added successfully.");
        fetchBoardList();
      } else {
        throw Exception("Failed to insert board.");
      }
    } catch (e) {
      Get.snackbar("error", "failed to insert : $e");
    }
  }

  Future<void> insert() async {
    if (_formKey.currentState!.validate()) {
//      var url = "http://10.0.2.2:8080/board/insert";
      var url = "http://10.0.2.2:8080/board/insert";

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'title': _titleController.text,
            'writer': _writerController.text,
            'content': _contentController.text,
          }),
        );
        print("::::: response - body :::::");
        print(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar('성공', '게시글 등록 성공',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blueAccent);
          Get.offNamed('/board/list');
        } else {
          Get.snackbar('실패', '게시글 등록 실패',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  /// 게시글 수정 요청
  Future<void> updateBoard() async {
    if (_formKey.currentState!.validate()) {
//      var url = "http://10.0.2.2:8080/board/update";
      var url = "http://localhost:8080/board/update";
      try {
        var response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'no': no,
            'title': _titleController.text,
            'writer': _writerController.text,
            'content': _contentController.text,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar('성공', '게시글 수정 성공',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blueAccent);
          Get.offNamed("/board/list");
        } else {
          Get.snackbar('실패', '게시글 수정 실패',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  /// 게시글 삭제 요청
  Future<bool> deleteBoard(int no) async {
//    var url = "http://10.0.2.2:8080/board/$no";
    var url = "http://localhost:8080/board/$no";
    try {
      var response = await http.delete(Uri.parse(url));
      print("::::: response - statusCode :::::");
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 성공적으로 삭제됨
        print("게시글 삭제 성공");
        return true;
      } else {
        // 실패 시 오류 메시지
        print("삭제 실패");
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
