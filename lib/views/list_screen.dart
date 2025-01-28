import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_board_getx/controllers/board_controller.dart';
import 'package:flutter_board_getx/models/board.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  BoardController controller = Get.put(BoardController());
  List<Board> _boardList = [];

  @override
  void initState() {
    super.initState();
    controller.getBoardList().then((result) {
      setState(() {
        _boardList = result;
      });
    });
  }

  final List<PopupMenuEntry<String>> _popupMenuItems = [
    const PopupMenuItem<String>(
      value: 'update',
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.black), // 아이콘
          SizedBox(width: 8), // 아이콘과 텍스트 사이에 간격 추가
          Text('수정하기'), // 텍스트
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete, color: Colors.black), // 아이콘
          SizedBox(width: 8), // 아이콘과 텍스트 사이에 간격 추가
          Text('삭제하기'), // 텍스트
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시글 목록")),
      body: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
        child: ListView.builder(
          itemCount: _boardList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Card(
                child: ListTile(
                  leading: Text(_boardList[index].no.toString() ?? '0'),
                  title: Text(_boardList[index].title ?? "제목없음"),
                  subtitle: Text(_boardList[index].writer ?? '-'),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return _popupMenuItems;
                    },
                    onSelected: (String value) async {
                      if (value == 'update') {
                        /*
                        Navigator.pushNamed(
                          context,
                          "/board/update",
                          arguments: _boardList[index].no,
                        );
                        */
                        Get.toNamed("board/update",
                            arguments: _boardList[index].no);
                      } else if (value == 'delete') {
                        bool check = await _showDeleteConfirmDialog();
                        if (check) {
                          deleteBoard(_boardList[index].no).then((result) {
                            if (result) {
                              setState(() {
                                _boardList.removeAt(index);
                              });
                            }
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
              onTap: () {
                /*수정 전 코드
                  Navigator.pushNamed(
                    context,
                    "/board/read",
                    arguments: _boardList[index].no,
                );
                */
                Get.toNamed(
                  "/board/read",
                  arguments: _boardList[index].no,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigator.pushReplacementNamed(context, "/board/insert");
          Get.offNamed("/board/insert");
        },
        child: const Icon(Icons.create),
      ),
    );
  }

  /// 게시글 삭제 요청
  Future<bool> deleteBoard(int? no) async {
    var url = "http://10.0.2.2:8080/board/$no";
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
        throw Exception(
            'Failed to delete board. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// 삭제 확인 다이얼로그 표시
  Future<bool> _showDeleteConfirmDialog() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 취소를 클릭하면 false 반환
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 삭제를 클릭하면 true 반환
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    ).then((value) {
      result = value ?? false;
    });
    return result;
  }
}
