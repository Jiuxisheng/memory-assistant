import 'package:flutter/material.dart';
import '../models/event.dart';

class InputDialog extends StatefulWidget {
  const InputDialog({super.key});

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = ['健康', '社交', '工作', '其他'];

  String _category = '健康';
  final TextEditingController _whoController = TextEditingController();
  final TextEditingController _whatController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _whyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _whoController.dispose();
    _whatController.dispose();
    _locationController.dispose();
    _whyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('记录新事件'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 分类选择
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // 5W输入
              _buildTextField(_whoController, '人物 (Who)', '例如：张三'),
              const SizedBox(height: 12),
              _buildTextField(_whatController, '事件 (What)', '例如：开会讨论项目'),
              const SizedBox(height: 12),
              _buildTextField(_locationController, '地点 (Location)', '例如：公司会议室'),
              const SizedBox(height: 12),
              _buildTextField(_whyController, '原因 (Why)', '例如：项目进度需要跟进'),
              const SizedBox(height: 12),
              // 备注
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注 (可选)',
                  border: OutlineInputBorder(),
                  hintText: '其他需要记录的信息...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        hintText: hint,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入内容';
        }
        return null;
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        timestamp: DateTime.now(),
        category: _category,
        who: _whoController.text,
        what: _whatController.text,
        location: _locationController.text,
        why: _whyController.text,
        notes: _notesController.text,
      );
      Navigator.pop(context, event);
    }
  }
}