import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_board_getx/controllers/board_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InsertScreen extends StatefulWidget {
  const InsertScreen({super.key});

  @override
  State<InsertScreen> createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  BoardController controller = Get.find<BoardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게시글 작성"),
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
              controller.insert();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50), // 가로 100% 버튼
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 테두리를 둥글지 않게 설정
              ),
            ),
            child: const Text('등록하기'),
          ),
        ),
      ),
    );
  }
}
