import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../app_state.dart';
import '../app_colors.dart';
import '../../l10n/app_localizations.dart';

class ContactSyncList extends StatefulWidget {
  final Function(Contact contact, String? murtaaxName) onContactSelected;

  const ContactSyncList({super.key, required this.onContactSelected});

  @override
  State<ContactSyncList> createState() => _ContactSyncListState();
}

class _ContactSyncListState extends State<ContactSyncList> {
  List<Contact>? _contacts;
  bool _isLoading = true;
  String _searchQuery = "";
  ph.PermissionStatus _permissionStatus = ph.PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndFetch();
  }

  Future<void> _checkPermissionAndFetch() async {
    final status = await ph.Permission.contacts.status;
    setState(() {
      _permissionStatus = status;
    });

    if (status.isGranted) {
      _fetchContacts();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await ph.Permission.contacts.request();
    setState(() {
      _permissionStatus = status;
    });
    if (status.isGranted) {
      _fetchContacts();
    }
  }

  Future<void> _fetchContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone, ContactProperty.photoThumbnail},
      );
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _cleanPhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (clean.startsWith('+252')) clean = clean.substring(4);
    else if (clean.startsWith('252')) clean = clean.substring(3);
    return clean;
  }

  void _inviteContact(Contact contact) {
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : "";
    final name = contact.displayName;
    final message = "Hi $name, I'm using MurtaaxPay to send money and manage my savings. Join me! https://murtaaxpay.com/download";
    
    Share.share(message, subject: "Join me on MurtaaxPay");
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    if (_permissionStatus.isDenied) {
      return _buildPermissionPrompt(l10n, theme);
    }

    if (_permissionStatus.isPermanentlyDenied) {
      return _buildPermanentlyDenied(l10n, theme);
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredContacts = _contacts?.where((c) {
      final displayName = (c.displayName ?? "").toLowerCase();
      final query = _searchQuery.toLowerCase();
      return displayName.contains(query) ||
             c.phones.any((p) => p.number.contains(_searchQuery));
    }).toList() ?? [];

    // Separate contacts into "On Murtaax" and "Invite"
    final onMurtaax = <Map<String, dynamic>>[];
    final others = <Contact>[];

    for (var contact in filteredContacts) {
      bool found = false;
      for (var phone in contact.phones) {
        String cleaned = _cleanPhone(phone.number);
        if (appState.mockUsers.containsKey(cleaned)) {
          onMurtaax.add({
            'contact': contact,
            'murtaaxName': appState.mockUsers[cleaned],
            'phone': phone.number,
          });
          found = true;
          break;
        }
      }
      if (!found) {
        others.add(contact);
      }
    }

    return Center(
      child: MaxWidthBox(
        maxWidth: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Search contacts...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (onMurtaax.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "CONTACTS ON MURTAAX",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: theme.colorScheme.secondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...onMurtaax.map((m) => _buildContactTile(
                      context, 
                      m['contact'], 
                      theme, 
                      murtaaxName: m['murtaaxName'],
                      isMurtaax: true,
                    )),
                    const Divider(),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "ALL CONTACTS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...others.map((c) => _buildContactTile(context, c, theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, Contact contact, ThemeData theme, {String? murtaaxName, bool isMurtaax = false}) {
    Uint8List? photoBytes;
    if (contact.photo != null) {
      photoBytes = contact.photo?.thumbnail;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isMurtaax ? theme.colorScheme.secondary.withValues(alpha: 0.1) : Colors.grey[200],
        backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
        child: photoBytes == null 
          ? Text((contact.displayName ?? "").isNotEmpty ? contact.displayName![0] : "?", 
              style: TextStyle(color: isMurtaax ? theme.colorScheme.secondary : Colors.grey[700], fontWeight: FontWeight.bold)) 
          : null,
      ),
      title: Text(contact.displayName ?? "No Name", style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(contact.phones.isNotEmpty ? contact.phones.first.number : "No phone"),
      trailing: isMurtaax 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("PAY", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        : OutlinedButton(
            onPressed: () => _inviteContact(contact),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.secondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text("INVITE", style: TextStyle(color: theme.colorScheme.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      onTap: () => widget.onContactSelected(contact, murtaaxName),
    );
  }

  Widget _buildPermissionPrompt(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: MaxWidthBox(
        maxWidth: 500,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contacts_rounded, size: 64, color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text(
                "Sync your contacts",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Find your friends and family on MurtaaxPay instantly. We'll only use your contacts to help you find people you know.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Sync Contacts", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermanentlyDenied(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              "Permission Required",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.contactPermissionRequired,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => ph.openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.openSettings, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
