import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/settings_controller.dart';

class CulturalWisdomScreen extends StatelessWidget {
  const CulturalWisdomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(SettingsController().tr('Cultural Wisdom')),
          bottom: TabBar(
            tabs: [
              Tab(text: SettingsController().tr('Mantras')),
              Tab(text: SettingsController().tr('Myth vs Fact')),
              Tab(text: SettingsController().tr('Readings')),
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

class _MantrasTab extends StatefulWidget {
  const _MantrasTab();

  @override
  State<_MantrasTab> createState() => _MantrasTabState();
}

class _MantrasTabState extends State<_MantrasTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  final mantras = [
    {
      'name': 'Gayatri Mantra',
      'text': 'Om Bhur Bhuvah Svah, Tat Savitur Varenyam, Bhargo Devasya Dheemahi, Dhiyo Yo Nah Prachodayat.',
      'benefit': 'Enhances mental clarity and intellectual development of the baby.',
      'image': Icons.wb_sunny_outlined,
      'audio': 'grantha_sounds/gayatri_mantra.mp3.mpeg',
    },
    {
      'name': 'Mahamritunjaya Mantra',
      'text': 'Om Tryambakam Yajamahe Sugandhim Pushti-Vardhanam, Urvarukamiva Bandhanan Mrityor Mukshiya Maamritat.',
      'benefit': 'Invokes healing energy and divine protection.',
      'image': Icons.healing_outlined,
      'audio': 'grantha_sounds/mrithunjaya_mantra.mp3.mpeg',
    },
    {
      'name': 'Hanuman Chalisa',
      'text': 'Shri Guru Charan Saroj Raj...',
      'benefit': 'Provides strength, courage, and removes negative energies.',
      'image': Icons.security_outlined,
      'audio': 'grantha_sounds/hanuman_chalisa.mp3.mpeg',
    },
    {
      'name': 'Krishna Flute',
      'text': 'Devine flute music for relaxation and peace.',
      'benefit': 'Calms the mind and creates a peaceful environment for the baby.',
      'image': Icons.music_note_outlined,
      'audio': 'grantha_sounds/krishna_flute.mp3.mpeg',
    },
    {
      'name': 'Om Chanting',
      'text': 'The primordial sound of the universe.',
      'benefit': 'Reduces stress and promotes deep relaxation.',
      'image': Icons.spa_outlined,
      'audio': 'grantha_sounds/om.mp3.mpeg',
    },
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String audioAsset) async {
    if (_currentlyPlaying == audioAsset) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlaying = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(audioAsset));
      setState(() {
        _currentlyPlaying = audioAsset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: mantras.length,
      itemBuilder: (context, index) {
        final mantra = mantras[index];
        final bool isPlaying = _currentlyPlaying == mantra['audio'];
        
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
                    Expanded(
                      child: Text(mantra['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
                    ),
                    IconButton(
                      icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle_fill, color: Colors.brown, size: 36),
                      onPressed: () => _toggleAudio(mantra['audio'] as String),
                    ),
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
        'myth': 'Papaya and pineapple cause miscarriage.',
        'fact': 'Ripe papaya and normal amounts of pineapple are generally safe. Only unripe papaya in very large quantities may be risky.'
      },
      {
        'myth': 'Pregnant women should not go outside during eclipse (grahan).',
        'fact': 'There is no scientific evidence that eclipses harm the baby. It is a cultural belief, not a medical rule.'
      },
      {
        'myth': 'Eat for two – double your food intake.',
        'fact': 'You don’t need double food. You need better nutrition, not more quantity.'
      },
      {
        'myth': 'Don’t cut nails or hair during pregnancy.',
        'fact': 'Cutting nails or hair has no effect on the baby. Hygiene is actually important during pregnancy.'
      },
      {
        'myth': 'Craving sweets means it’s a girl; spicy means it’s a boy.',
        'fact': 'Cravings are due to hormonal changes — they do not predict the baby’s gender.'
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
                Text(SettingsController().tr("Myth:"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(myths[index]['myth']!, style: const TextStyle(fontStyle: FontStyle.italic)),
                const Divider(height: 24),
                Text(SettingsController().tr("Fact:"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
          {'title': 'Bhagavad Gita', 'subtitle': 'Online text + audio of the sacred scripture.', 'link': 'https://bhagavadgita.com'},
          {'title': 'Mahabharata', 'subtitle': 'Free public domain version found on Internet Sacred Text Archive.', 'link': 'https://sacred-texts.com/hin/index.html'},
          {'title': 'Garbha Sanskar', 'subtitle': 'Ancient scriptural teachings on the miracle of life.', 'link': 'https://1pdf.in/garbh-sanskar/'},
        ]
      },
      {
        'title': 'Great Indian Personalities (Biographies)',
        'items': [
          {'title': 'Krishna Biography', 'subtitle': 'Life and teachings of Krishna from Encyclopaedia Britannica.', 'link': 'https://www.britannica.com/topic/Krishna-Hindu-deity'},
          {'title': 'Karna Story', 'subtitle': 'The legendary tale of Karna\'s valor and loyalty.', 'link': 'https://storiespub.com/karna-story/'},
          {'title': 'Chhatrapati Shivaji Maharaj', 'subtitle': 'Pride of Hindu - Biography by Mahesh Wakchaure.', 'link': 'https://english.pratilipi.com/series/chhatrapati-shivaji-maharaj-pride-of-hindu-by-mahesh-wakchaure-iuqm54fxuvle'},
          {'title': 'Chhatrapati Sambhaji Maharaj', 'subtitle': 'The life and legacy of the second Maratha Chhatrapati.', 'link': 'https://www.matrubharti.com/book/read/content/19900098/chhatrapati-sambhaji-maharaj'},
          {'title': 'Maharana Pratap', 'subtitle': 'Social Science biography of the symbol of Rajput valor.', 'link': 'https://www.geeksforgeeks.org/social-science/maharana-pratap-biography/'},
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
              child: Text(SettingsController().tr(section['title'] as String), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
            ),
            ...(section['items'] as List).map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined, color: Colors.brown),
                title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['subtitle']!),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  final Uri url = Uri.parse(item['link']!);
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch ${item['link']}')),
                      );
                    }
                  }
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
