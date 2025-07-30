import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../models/group.dart';
import '../l10n/app_localizations.dart';

class GroupInviteScreen extends StatefulWidget {
  final Group group;

  const GroupInviteScreen({super.key, required this.group});

  @override
  State<GroupInviteScreen> createState() => _GroupInviteScreenState();
}

class _GroupInviteScreenState extends State<GroupInviteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.locale.languageCode == 'de' ? 'Mitglieder einladen' : 'Invite Members'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.qr_code),
              text: l10n.locale.languageCode == 'de' ? 'Teilen' : 'Share',
            ),
            Tab(
              icon: const Icon(Icons.qr_code_scanner),
              text: l10n.locale.languageCode == 'de' ? 'Scannen' : 'Scan',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShareTab(),
          _buildScanTab(),
        ],
      ),
    );
  }

  Widget _buildShareTab() {
    final l10n = context.l10n;
    final inviteLink = _generateInviteLink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.locale.languageCode == 'de' ? 'Gruppe teilen' : 'Share Group',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l10n.locale.languageCode == 'de' 
                              ? 'Teile den QR-Code oder Link um neue Mitglieder einzuladen'
                              : 'Share the QR code or link to invite new members',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Group Info
          Text(
            '${l10n.locale.languageCode == 'de' ? 'Gruppe' : 'Group'}: ${widget.group.name}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: inviteLink,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Invite Link
          Text(
            l10n.locale.languageCode == 'de' ? 'Einladungslink' : 'Invite Link',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      inviteLink,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(inviteLink),
                    icon: const Icon(Icons.copy),
                    tooltip: l10n.locale.languageCode == 'de' ? 'Kopieren' : 'Copy',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Share Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shareInvite(inviteLink),
              icon: const Icon(Icons.share),
              label: Text(l10n.locale.languageCode == 'de' ? 'Link teilen' : 'Share Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.orange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.locale.languageCode == 'de' ? 'QR-Code scannen' : 'Scan QR Code',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l10n.locale.languageCode == 'de' 
                              ? 'Scanne einen QR-Code um einer Gruppe beizutreten'
                              : 'Scan a QR code to join a group',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Camera Preview Area
          Expanded(
            child: Card(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.locale.languageCode == 'de' 
                          ? 'QR-Scanner wird in einer zukünftigen Version verfügbar sein'
                          : 'QR Scanner will be available in a future version',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showManualJoinDialog,
                      icon: const Icon(Icons.edit),
                      label: Text(l10n.locale.languageCode == 'de' 
                          ? 'Manuell beitreten' 
                          : 'Join Manually'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateInviteLink() {
    // In einer echten App würde das über den Server generiert
    return 'https://stammtisch-app.com/invite/${widget.group.id}?name=${Uri.encodeComponent(widget.group.name)}';
  }

  void _copyToClipboard(String text) {
    final l10n = context.l10n;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.locale.languageCode == 'de' 
            ? 'Link in Zwischenablage kopiert' 
            : 'Link copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareInvite(String link) {
    final l10n = context.l10n;
    // In einer echten App würde hier der Share Dialog des Systems verwendet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.locale.languageCode == 'de' 
            ? 'Teilen-Funktion wird in einer zukünftigen Version verfügbar sein' 
            : 'Share functionality will be available in a future version'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showManualJoinDialog() {
    final l10n = context.l10n;
    final groupIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.locale.languageCode == 'de' ? 'Gruppe beitreten' : 'Join Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.locale.languageCode == 'de' 
                  ? 'Gib die Gruppen-ID ein, um beizutreten:'
                  : 'Enter the group ID to join:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: groupIdController,
              decoration: InputDecoration(
                labelText: l10n.locale.languageCode == 'de' ? 'Gruppen-ID' : 'Group ID',
                hintText: 'z.B. abc123',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.locale.languageCode == 'de' ? 'Abbrechen' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _joinGroupById(groupIdController.text.trim());
            },
            child: Text(l10n.locale.languageCode == 'de' ? 'Beitreten' : 'Join'),
          ),
        ],
      ),
    );
  }

  void _joinGroupById(String groupId) {
    final l10n = context.l10n;
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUserId;

    if (groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locale.languageCode == 'de' 
              ? 'Bitte gib eine gültige Gruppen-ID ein' 
              : 'Please enter a valid group ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Demo: Simuliere Gruppenbeitritt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.locale.languageCode == 'de' 
            ? 'Gruppenbeitritt wird in einer zukünftigen Version implementiert' 
            : 'Group joining will be implemented in a future version'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}