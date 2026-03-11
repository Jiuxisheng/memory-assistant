import 'package:flutter/material.dart';
import 'package:memory_assistant/models/event.dart';
import 'package:memory_assistant/services/database_service.dart';
import 'package:memory_assistant/widgets/event_card.dart';
import 'package:memory_assistant/widgets/input_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Event> _events = [];
  String _selectedCategory = '全部';

  final List<String> _categories = [
    '全部',
    '健康',
    '社交',
    '工作',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    List<Event> events;
    if (_selectedCategory == '全部') {
      events = await _dbService.getAllEvents();
    } else {
      events = await _dbService.getEventsByCategory(_selectedCategory);
    }
    setState(() {
      _events = events;
    });
  }

  Future<void> _addEvent() async {
    final event = await showDialog<Event>(
      context: context,
      builder: (context) => const InputDialog(),
    );

    if (event != null) {
      await _dbService.insertEvent(event);
      await _loadEvents();
    }
  }

  Future<void> _deleteEvent(int id) async {
    await _dbService.deleteEvent(id);
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记忆助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('关于'),
                  content: const Text(
                    '记忆助手 - 5W事件记录\n\n'
                    '记录生活中的重要事件：\n'
                    '• When: 时间\n'
                    '• Where: 地点\n'
                    '• Who: 人物\n'
                    '• What: 事件\n'
                    '• Why: 原因\n\n'
                    '分类：健康、社交、工作、其他',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类筛选
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _loadEvents();
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // 事件列表
          Expanded(
            child: _events.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '还没有记录任何事件',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '点击下方按钮开始记录',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return EventCard(
                        event: event,
                        onDelete: () => _deleteEvent(event.id!),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}