import 'package:flutter/material.dart';
import '../../controllers/contact_controller.dart';
import '../../widgets/contact_card.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _contactController = ContactController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    await _contactController.fetchContacts();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              await _contactController.addContact(nameController.text, phoneController.text);
              if (mounted) {
                Navigator.pop(context); // Pop loader
                Navigator.pop(context); // Pop dialog
                setState(() {});
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Contacts')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final contacts = _contactController.getContacts();

    return Scaffold(
      appBar: AppBar(title: const Text('My Contacts')),
      body: contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No contacts added', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _showAddContactDialog, child: const Text('Add Contact')),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) => ContactCard(contact: contacts[index]),
            ),
      floatingActionButton: contacts.isNotEmpty
          ? FloatingActionButton(onPressed: _showAddContactDialog, child: const Icon(Icons.add))
          : null,
    );
  }
}
