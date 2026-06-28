import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/history_entry.dart';
import '../models/search_result.dart';
import '../services/api_service.dart';
import '../widgets/sermon_card.dart';
import '../widgets/verse_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  List<HistoryEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _api.getHistory();
      setState(() {
        _entries = entries;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEntry(HistoryEntry entry) async {
    try {
      await _api.deleteHistoryItem(entry.id);
      setState(() => _entries.removeWhere((e) => e.id == entry.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }

  Future<void> _openEntry(HistoryEntry entry) async {
    try {
      final result = await _api.getHistoryItem(entry.id);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _HistoryDetailScreen(result: result)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved searches')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _entries.isEmpty
                  ? const Center(child: Text('No saved searches yet.'))
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Dismissible(
                            key: ValueKey(entry.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteEntry(entry),
                            child: ListTile(
                              title: Text(entry.queryText),
                              subtitle: Text(
                                DateFormat('MMM d, yyyy \u00b7 h:mm a')
                                    .format(entry.createdAt.toLocal()),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openEntry(entry),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _HistoryDetailScreen extends StatelessWidget {
  final SearchResult result;
  const _HistoryDetailScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(result.query)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...result.verses.map((v) => VerseCard(verse: v)),
          ...result.sermons.map((s) => SermonCard(sermon: s)),
        ],
      ),
    );
  }
}
