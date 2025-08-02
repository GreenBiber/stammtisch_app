import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../l10n/app_localizations.dart';

class GroupInviteScreen extends StatefulWidget {
  final String groupId;

  const GroupInviteScreen({super.key, required this.groupId});

  @override
  State<GroupInviteScreen> createState() => _GroupInviteScreenState();
}

class _GroupInviteScreenState extends State<GroupInviteScreen> {
  late String _inviteLink;
  bool _isGeneratingQR = false;
  bool _showQRCode = false;

  @override
  void initState() {
    super.initState();
    _inviteLink = _generateInviteLink();
  }

  String _generateInviteLink() {
    // In a real app, this would be a deep link to your app
    return 'https://stammtisch-app.com/invite/${widget.groupId}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer2<AuthProvider, GroupProvider>(
      builder: (context, authProvider, groupProvider, child) {
        final user = authProvider.currentUser;
        final group = groupProvider.getGroupById(widget.groupId);

        if (user == null || group == null) {
          return Scaffold(
            appBar: AppBar(
                title: Text(l10n?.inviteMembers ?? 'Mitglieder einladen')),
            body: Center(
                child: Text(l10n?.groupNotFound ?? 'Gruppe nicht gefunden')),
          );
        }

        if (!group.isAdmin(user.id)) {
          return Scaffold(
            appBar: AppBar(
                title: Text(l10n?.inviteMembers ?? 'Mitglieder einladen')),
            body: Center(
                child: Text(
                    l10n?.adminRightsRequired ?? 'Admin-Rechte erforderlich')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n?.inviteMembers ?? 'Mitglieder einladen'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGroupInfo(group, l10n),
                const SizedBox(height: 24),
                _buildInviteLink(l10n),
                const SizedBox(height: 24),
                _buildQRCodeSection(l10n),
                const SizedBox(height: 24),
                _buildInstructions(l10n),
                const SizedBox(height: 24),
                _buildMembersList(group, groupProvider, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupInfo(group, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal,
              child: Text(
                group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              group.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${group.members.length} ${l10n?.members ?? 'Mitglieder'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteLink(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  l10n?.inviteLink ?? 'Einladungslink',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _inviteLink,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(l10n),
                    icon: const Icon(Icons.copy),
                    tooltip: l10n?.copyLink ?? 'Link kopieren',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareInviteLink(l10n),
                icon: const Icon(Icons.share),
                label: Text(l10n?.shareLink ?? 'Link teilen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  l10n?.qrCode ?? 'QR-Code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: _isGeneratingQR
                  ? const CircularProgressIndicator()
                  : _showQRCode
                      ? Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: QrImageView(
                            data: _inviteLink,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                          ),
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                l10n?.qrCodePlaceholder ??
                                    'QR-Code wird hier angezeigt',
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _generateQRCode(l10n),
                icon: const Icon(Icons.refresh),
                label: Text(l10n?.generateQRCode ?? 'QR-Code generieren'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l10n?.instructions ?? 'Anleitung',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '1.',
              l10n?.inviteStep1 ??
                  'Teile den Einladungslink oder zeige den QR-Code',
              Icons.share,
            ),
            const SizedBox(height: 8),
            _buildInstructionStep(
              '2.',
              l10n?.inviteStep2 ?? 'Neue Mitglieder müssen sich registrieren',
              Icons.person_add,
            ),
            const SizedBox(height: 8),
            _buildInstructionStep(
              '3.',
              l10n?.inviteStep3 ??
                  'Sie werden automatisch zur Gruppe hinzugefügt',
              Icons.group_add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(
      group, GroupProvider groupProvider, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n?.currentMembers ?? 'Aktuelle Mitglieder'} (${group.members.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...group.members.map((memberId) {
              final user = groupProvider.getUserById(memberId);
              final isAdmin = group.isAdmin(memberId);

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    user?.displayName.isNotEmpty == true
                        ? user!.displayName[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(user?.displayName ?? l10n?.unknown ?? 'Unbekannt'),
                subtitle: Text(user?.email ?? ''),
                trailing: isAdmin
                    ? Chip(
                        label: Text(l10n?.admin ?? 'Admin'),
                        backgroundColor: Colors.amber.withOpacity(0.2),
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(AppLocalizations? l10n) {
    Clipboard.setData(ClipboardData(text: _inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.linkCopied ?? 'Link in Zwischenablage kopiert'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareInviteLink(AppLocalizations? l10n) {
    // In a real app, this would use the share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.shareNotImplemented ??
            'Teilen-Funktion noch nicht implementiert'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _generateQRCode(AppLocalizations? l10n) {
    setState(() {
      _isGeneratingQR = true;
    });

    // Generate QR code after brief delay for UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isGeneratingQR = false;
          _showQRCode = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.qrCodeGenerated ?? 'QR-Code erfolgreich generiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
