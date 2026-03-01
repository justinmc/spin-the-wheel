import 'package:flutter/material.dart';

class SectionConfigPage extends StatefulWidget {
  const SectionConfigPage({super.key, required this.sections});

  final List<String> sections;

  @override
  State<SectionConfigPage> createState() => _SectionConfigPageState();
}

class _SectionConfigPageState extends State<SectionConfigPage> {
  late List<String> _sections;

  static const List<Color> _palette = [
    Color(0xFFE53935),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFFFDD835),
    Color(0xFF8E24AA),
    Color(0xFFFF8F00),
    Color(0xFF00ACC1),
    Color(0xFFD81B60),
    Color(0xFF7CB342),
    Color(0xFF3949AB),
    Color(0xFFFF6D00),
    Color(0xFF00897B),
  ];

  @override
  void initState() {
    super.initState();
    _sections = List.from(widget.sections);
  }

  void _editSection(int index) {
    final controller = TextEditingController(text: _sections[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Section'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Section name'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() => _sections[index] = value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() => _sections[index] = value);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addSection() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Section'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Section name'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() => _sections.add(value.trim()));
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() => _sections.add(value));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Configure Sections'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _sections),
          ),
        ),
        body: ListView.builder(
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _palette[index % _palette.length],
              ),
              title: Text(_sections[index]),
              trailing: _sections.length > 2
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _sections.removeAt(index));
                      },
                    )
                  : null,
              onTap: () => _editSection(index),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addSection,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
