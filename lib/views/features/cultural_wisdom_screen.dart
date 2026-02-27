import 'package:flutter/material.dart';

class CulturalWisdomScreen extends StatelessWidget {
  const CulturalWisdomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cultural Wisdom'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Traditional Tips'),
              Tab(text: 'Myth vs Fact'),
              Tab(text: 'Readings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TraditionalTipsTab(),
            _MythVsFactTab(),
            _ReadingListTab(),
          ],
        ),
      ),
    );
  }
}

class _TraditionalTipsTab extends StatelessWidget {
  const _TraditionalTipsTab();

  @override
  Widget build(BuildContext context) {
    final tips = [
      {'title': 'Abhyanga (Oil Massage)', 'desc': 'Daily self-massage with warm sesame oil improves circulation and reduces anxiety.'},
      {'title': 'Saatvik Diet', 'desc': 'Focus on fresh, easy-to-digest, and nutritious foods to keep the mind and body pure.'},
      {'title': 'Saffron Milk', 'desc': 'Drinking a glass of warm milk with saffron strands is believed to improve skin tone and digestion.'},
      {'title': 'Early Morning Sun', 'desc': '10-15 minutes of mild morning sunlight provides essential Vitamin D and boosts mood.'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tips[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
                const SizedBox(height: 8),
                Text(tips[index]['desc']!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MythVsFactTab extends StatelessWidget {
  const _MythVsFactTab();

  @override
  Widget build(BuildContext context) {
    final myths = [
      {
        'myth': 'Eating for two means double the portions.',
        'fact': 'Quality over quantity. You only need about 300 extra calories per day in the second trimester.'
      },
      {
        'myth': 'The shape of your bump can tell the baby\'s gender.',
        'fact': 'Bump shape depends on your body type, muscle tone, and the baby\'s position.'
      },
      {
        'myth': 'Avoid exercise completely during pregnancy.',
        'fact': 'Moderate, low-impact exercise like walking and yoga is highly beneficial for both mother and baby.'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: myths.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Myth:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(myths[index]['myth']!, style: const TextStyle(fontStyle: FontStyle.italic)),
                const Divider(height: 24),
                const Text("Fact:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text(myths[index]['fact']!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadingListTab extends StatelessWidget {
  const _ReadingListTab();

  @override
  Widget build(BuildContext context) {
    final books = [
      {'title': 'Ayurvedic Pregnancy Care', 'author': 'Dr. Vasant Lad', 'desc': 'A comprehensive guide to holistic maternal health.'},
      {'title': 'Ancient Wisdom for Modern Motherhood', 'author': 'Traditional Texts', 'desc': 'Timeless advice adapted for the 21st century.'},
      {'title': 'The Pregnancy Bible', 'author': 'Dr. Keith Eddleman', 'desc': 'Detailed medical and structural growth overview.'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.book, size: 40),
          title: Text(books[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${books[index]['author']}\n${books[index]['desc']}"),
          isThreeLine: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        );
      },
    );
  }
}
