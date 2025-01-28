import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_board_getx/controllers/board_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  BoardController controller = Get.find<BoardController>();

  late int no;

  final List<PopupMenuEntry<String>> _popupMenuItems = [
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null) {
      no = arguments as int;
      controller.getBoard(no); // 이름 변경된 메서드 호출
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게시글 수정"),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return _popupMenuItems;
            },
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) async {
              if (value == 'delete') {
                bool check = await _showDeleteConfirmDialog();
                if (check) {
                  controller.deleteBoard(no).then((result) {
                    if (result) {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, "/board/list");
//                      Get.toNamed("/board/list");
                    }
                  });
                }
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력하세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _writerController,
                decoration: const InputDecoration(labelText: '작성자'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '작성자를 입력하세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '내용을 입력하세요';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 60,
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              controller.updateBoard();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50), // 가로 100% 버튼
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 테두리를 둥글지 않게 설정
              ),
            ),
            child: const Text('수정하기'),
          ),
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그 표시 메서드
  Future<bool> _showDeleteConfirmDialog() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('정말로 이 게시글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 취소를 클릭하면 false 반환
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 삭제를 클릭하면 true 반환
              },
              child: Text('삭제'),
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
