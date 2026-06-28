import 'package:flutter/material.dart';

import '../models/search_result.dart';
import '../services/api_service.dart';
import '../widgets/sermon_card.dart';
import '../widgets/verse_card.dart';
import 'history_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();

  SearchResult? _result;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _runSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _api.search(query);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verse & Sermon Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Saved searches',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _runSearch(),
              decoration: InputDecoration(
                hintText: 'e.g. "dealing with anxiety", "forgiveness"...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _runSearch,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: CircularProgressIndicator(),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (result != null)
              Expanded(
                child: ListView(
                  children: [
                    if (result.warnings.isNotEmpty)
                      ...result.warnings.map(
                        (w) => Card(
                          color: Colors.amber.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              w,
                              style: TextStyle(color: Colors.amber.shade900),
                            ),
                          ),
                        ),
                      ),
                    if (result.verses.isNotEmpty) ...[
                      const _SectionHeader(title: 'Verses'),
                      ...result.verses.map((v) => VerseCard(verse: v)),
                    ],
                    if (result.sermons.isNotEmpty) ...[
                      const _SectionHeader(title: 'Related sermons'),
                      ...result.sermons.map((s) => SermonCard(sermon: s)),
                    ],
                    if (result.verses.isEmpty && result.sermons.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(
                          child: Text('No results found. Try a different search.'),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
