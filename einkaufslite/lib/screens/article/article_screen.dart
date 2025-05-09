import 'package:flutter/material.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artikel"), centerTitle: true),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Padding(padding: EdgeInsets.all(10.0), child: Column(children: []));
  }
}
