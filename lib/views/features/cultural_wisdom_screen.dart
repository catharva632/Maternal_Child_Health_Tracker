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
              Tab(text: 'Mantras'),
              Tab(text: 'Myth vs Fact'),
              Tab(text: 'Readings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MantrasTab(),
            _MythVsFactTab(),
            _ReadingListTab(),
          ],
        ),
      ),
    );
  }
}

class _MantrasTab extends StatelessWidget {
  const _MantrasTab();

  @override
  Widget build(BuildContext context) {
    final mantras = [
      {
        'name': 'Gauri Mantra',
        'text': 'Sarva Mangala Mangalye Shive Sarvartha Sadhike, Sharanye Tryambake Gauri Narayani Namostute.',
        'benefit': 'Invokes auspiciousness and divine protection for the mother and child.',
        'image': Icons.spa_outlined,
      },
      {
        'name': 'Gayatri Mantra',
        'text': 'Om Bhur Bhuvah Svah, Tat Savitur Varenyam, Bhargo Devasya Dheemahi, Dhiyo Yo Nah Prachodayat.',
        'benefit': 'Enhances mental clarity and intellectual development of the baby.',
        'image': Icons.wb_sunny_outlined,
      },
      {
        'name': 'Saraswati Mantra',
        'text': 'Om Shreem Hreem Saraswatyai Namah.',
        'benefit': 'Promotes wisdom, arts, and early cognitive skills.',
        'image': Icons.music_note_outlined,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: mantras.length,
      itemBuilder: (context, index) {
        final mantra = mantras[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(mantra['image'] as IconData, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Text(mantra['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.brown.shade100),
                  ),
                  child: Text(
                    mantra['text'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15, height: 1.4),
                  ),
                ),
                const SizedBox(height: 12),
                Text(mantra['benefit'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mantra recording feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Listen to Recording'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown,
                    side: const BorderSide(color: Colors.brown),
                  ),
                ),
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
    final sections = [
      {
        'title': 'Traditional Indian Literature',
        'items': [
          {'title': 'Sushrut Samhita (Sharira Sthana)', 'subtitle': 'Foundational Ayurvedic text on embryology and fetal development.', 'link': 'https://archive.org/details/SushrutaSamhitaEnglishTranslation'},
          {'title': 'Garbhopanishad', 'subtitle': 'Ancient scriptural teachings on the miracle of life.', 'link': 'https://www.wisdomlib.org/hinduism/book/garbha-upanishad'},
        ]
      },
      {
        'title': 'Great Indian Personalities (Biographies)',
        'items': [
          {'title': 'Chhatrapati Shivaji Maharaj', 'subtitle': 'The legendary founder of the Maratha Empire, taught bravery and ethics.', 'link': 'https://www.google.com/search?q=Chhatrapati+Shivaji+Maharaj+biography'},
          {'title': 'Chhatrapati Sambhaji Maharaj', 'subtitle': 'A scholar and warrior, known for his immense fortitude.', 'link': 'https://www.google.com/search?q=Chhatrapati+Sambhaji+Maharaj+biography'},
          {'title': 'Maharana Pratap', 'subtitle': 'The symbol of Rajput valor and indomitable spirit.', 'link': 'https://www.google.com/search?q=Maharana+Pratap+biography'},
        ]
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(section['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
            ),
            ...(section['items'] as List).map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined, color: Colors.brown),
                title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['subtitle']!),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${item['title']}...')),
                  );
                },
              ),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
