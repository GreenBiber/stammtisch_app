import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../widgets/xp_animation.dart';
import '../widgets/user_profile_card.dart';
import '../models/points.dart';
import '../l10n/app_localizations.dart';

class RestaurantSuggestionsScreen extends StatefulWidget {
  const RestaurantSuggestionsScreen({super.key});

  @override
  State<RestaurantSuggestionsScreen> createState() => _RestaurantSuggestionsScreenState();
}

class _RestaurantSuggestionsScreenState extends State<RestaurantSuggestionsScreen> {
  final GlobalKey<XPAnimationOverlayState> _overlayKey = GlobalKey();
  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<String> _userVotes = {}; // Track welche Restaurants der User bereits gevotet hat
  bool _isSubmittingRestaurant = false;

  @override
  void dispose() {
    _restaurantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung

    return Consumer3<PointsProvider, AuthProvider, GroupProvider>(
      builder: (context, pointsProvider, authProvider, groupProvider, child) {
        final currentUserId = authProvider.currentUserId;
        final activeGroup = groupProvider.getActiveGroup(context);
        final userPoints = pointsProvider.getUserPoints(currentUserId, activeGroup?.id ?? '');

        final List<Map<String, dynamic>> restaurants = [
          {
            'name': 'Trattoria da Luca',
            'description': l10n.locale.languageCode == 'de'
                ? 'Italienische Küche mit gemütlichem Innenhof'
                : 'Italian cuisine with cozy courtyard',
            'image': 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=800&q=80',
            'votes': 3,
            'category': l10n.locale.languageCode == 'de' ? 'Italienisch' : 'Italian',
            'rating': 4.5,
            'suggestedBy': 'Marco',
          },
          {
            'name': 'Burger Garage',
            'description': l10n.locale.languageCode == 'de'
                ? 'Handgemachte Burger & Craft Beer'
                : 'Handmade burgers & craft beer',
            'image': 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
            'votes': 7,
            'category': 'Burger',
            'rating': 4.2,
            'suggestedBy': 'Lisa',
          },
          {
            'name': 'Sushiko',
            'description': l10n.locale.languageCode == 'de'
                ? 'Frisches Sushi in modernem Ambiente'
                : 'Fresh sushi in modern ambiance',
            'image': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?auto=format&fit=crop&w=800&q=80',
            'votes': 2,
            'category': l10n.locale.languageCode == 'de' ? 'Asiatisch' : 'Asian',
            'rating': 4.8,
            'suggestedBy': l10n.locale.languageCode == 'de' ? 'Du' : 'You',
          },
        ];

        return XPAnimationOverlay(
          key: _overlayKey,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.restaurantSuggestions), // LOKALISIERT
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_business),
                  onPressed: () => _showAddRestaurantDialog(
                    pointsProvider,
                    currentUserId,
                    activeGroup?.id ?? '',
                  ),
                  tooltip: l10n.locale.languageCode == 'de'
                      ? 'Restaurant vorschlagen (+${XPAction.suggestRestaurant.baseXP} XP)'
                      : 'Suggest restaurant (+${XPAction.suggestRestaurant.baseXP} XP)',
                ),
              ],
            ),
            body: Column(
              children: [
                // Profile Card Header (wenn XP vorhanden)
                if (userPoints != null)
                  UserProfileCard(
                    groupId: activeGroup?.id ?? '',
                    showDetailed: false,
                    showProgress: true,
                    heroTagSuffix: 'restaurant-header', // EINDEUTIGES TAG
                  ),

                // XP Info Header
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.locale.languageCode == 'de'
                                  ? 'Sammle XP für Restaurantvorschläge!'
                                  : 'Earn XP for restaurant suggestions!',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              l10n.locale.languageCode == 'de'
                                  ? '🍕 Vorschlag: +${XPAction.suggestRestaurant.baseXP} XP  |  👍 Voting: Spaß ohne XP'
                                  : '🍕 Suggestion: +${XPAction.suggestRestaurant.baseXP} XP  |  👍 Voting: Fun without XP',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Restaurant List
                Expanded(
                  child: Row(
                    children: [
                      // Restaurant Cards (3/4 der Breite)
                      Expanded(
                        flex: 3,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            final hasVoted = _userVotes.contains(restaurant['name']);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Restaurant Image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      restaurant['image']!,
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 180,
                                        color: Colors.grey[800],
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.broken_image, color: Colors.white, size: 32),
                                            const SizedBox(height: 8),
                                            Text(
                                              l10n.locale.languageCode == 'de'
                                                  ? 'Bild nicht verfügbar'
                                                  : 'Image not available',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Restaurant Info
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name und Kategorie
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                restaurant['name']!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(restaurant['category']).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                restaurant['category']!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getCategoryColor(restaurant['category']),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        // Beschreibung
                                        Text(
                                          restaurant['description']!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        // Vorgeschlagen von
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              l10n.suggestedBy(restaurant['suggestedBy']), // LOKALISIERT
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Voting Section
                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: hasVoted
                                                  ? null
                                                  : () => _voteForRestaurant(restaurant['name']!),
                                              icon: Icon(
                                                hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                                              ),
                                              label: Text(hasVoted 
                                                  ? l10n.voted 
                                                  : l10n.vote), // LOKALISIERT
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: hasVoted 
                                                    ? Colors.green.withOpacity(0.7)
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton.icon(
                                              onPressed: () => _showRestaurantDetails(restaurant),
                                              icon: const Icon(Icons.info_outline),
                                              label: Text(l10n.details), // LOKALISIERT
                                            ),
                                            const Spacer(),
                                            
                                            // Vote Count & Rating
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${restaurant['rating']}",
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.people, size: 16, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      l10n.locale.languageCode == 'de'
                                                          ? '${restaurant['votes']} Stimmen'
                                                          : '${restaurant['votes']} votes',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Stats Sidebar (1/4 der Breite) - nur wenn XP vorhanden
                      if (userPoints != null)
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                // Personal Stats Card
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.locale.languageCode == 'de'
                                              ? 'Deine Restaurant-Stats'
                                              : 'Your Restaurant Stats',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        
                                        _buildStatItem('🍕', 
                                            l10n.locale.languageCode == 'de' ? 'Vorschläge' : 'Suggestions', 
                                            '3'),
                                        const SizedBox(height: 8),
                                        _buildStatItem('👍', 
                                            l10n.locale.languageCode == 'de' ? 'Votes erhalten' : 'Votes received', 
                                            '12'),
                                        const SizedBox(height: 8),
                                        _buildStatItem('⭐', 
                                            l10n.locale.languageCode == 'de' ? 'XP aus Restaurants' : 'XP from restaurants', 
                                            '${XPAction.suggestRestaurant.baseXP * 3}'),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Quick Add Button
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.add_business, size: 32, color: Colors.orange),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.suggestRestaurant, // LOKALISIERT
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '+${XPAction.suggestRestaurant.baseXP} XP',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => _showAddRestaurantDialog(
                                              pointsProvider,
                                              currentUserId,
                                              activeGroup?.id ?? '',
                                            ),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                            child: Text(l10n.locale.languageCode == 'de' 
                                                ? 'Vorschlagen' 
                                                : 'Suggest'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Tips Card
                                Card(
                                  color: Colors.blue.withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.lightbulb, color: Colors.blue),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.locale.languageCode == 'de' ? 'Tipp' : 'Tip',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.locale.languageCode == 'de'
                                              ? 'Schlage neue Restaurants vor um XP zu sammeln und Achievements freizuschalten!'
                                              : 'Suggest new restaurants to earn XP and unlock achievements!',
                                          style: const TextStyle(fontSize: 11),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Add Restaurant FAB
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAddRestaurantDialog(
                pointsProvider,
                currentUserId,
                activeGroup?.id ?? '',
              ),
              icon: const Icon(Icons.add_business),
              label: Text(l10n.suggestRestaurant), // LOKALISIERT
              backgroundColor: Colors.orange,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'italienisch':
      case 'italian': return Colors.green;
      case 'burger': return Colors.brown;
      case 'asiatisch':
      case 'asian': return Colors.red;
      case 'mexikanisch':
      case 'mexican': return Colors.orange;
      case 'deutsch':
      case 'german': return Colors.amber;
      default: return Colors.blue;
    }
  }

  void _voteForRestaurant(String restaurantName) {
    final l10n = context.l10n;
    setState(() {
      _userVotes.add(restaurantName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.locale.languageCode == 'de'
            ? 'Du hast für "$restaurantName" gestimmt! 👍'
            : 'You voted for "$restaurantName"! 👍'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: l10n.locale.languageCode == 'de' ? 'Rückgängig' : 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _userVotes.remove(restaurantName);
            });
          },
        ),
      ),
    );
  }

  void _showAddRestaurantDialog(
    PointsProvider pointsProvider,
    String currentUserId,
    String groupId,
  ) {
    final l10n = context.l10n;
    String selectedCategory = l10n.locale.languageCode == 'de' ? 'Italienisch' : 'Italian';
    final categories = l10n.locale.languageCode == 'de' 
        ? ['Italienisch', 'Burger', 'Asiatisch', 'Mexikanisch', 'Deutsch', 'Andere']
        : ['Italian', 'Burger', 'Asian', 'Mexican', 'German', 'Other'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.orange),
              const SizedBox(width: 8),
              Text(l10n.suggestRestaurant), // LOKALISIERT
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _restaurantController,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantName, // LOKALISIERT
                    hintText: l10n.locale.languageCode == 'de' 
                        ? 'z.B. "Pizzeria Mario"'
                        : 'e.g. "Pizzeria Mario"',
                    prefixIcon: const Icon(Icons.restaurant_menu),
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantDescription, // LOKALISIERT
                    hintText: l10n.locale.languageCode == 'de'
                        ? 'Was macht dieses Restaurant besonders?'
                        : 'What makes this restaurant special?',
                    prefixIcon: const Icon(Icons.description),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.category, // LOKALISIERT
                    prefixIcon: const Icon(Icons.category),
                    border: const OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.locale.languageCode == 'de'
                              ? 'Du erhältst +${XPAction.suggestRestaurant.baseXP} XP für deinen Vorschlag!'
                              : 'You will receive +${XPAction.suggestRestaurant.baseXP} XP for your suggestion!',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _restaurantController.clear();
                _descriptionController.clear();
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.cancel), // LOKALISIERT
            ),
            ElevatedButton.icon(
              onPressed: _isSubmittingRestaurant
                  ? null
                  : () => _submitRestaurant(
                      ctx, 
                      pointsProvider, 
                      currentUserId, 
                      groupId, 
                      selectedCategory,
                    ),
              icon: _isSubmittingRestaurant
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(l10n.locale.languageCode == 'de' ? 'Vorschlagen' : 'Suggest'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRestaurant(
    BuildContext dialogContext,
    PointsProvider pointsProvider,
    String currentUserId,
    String groupId,
    String category,
  ) async {
    final l10n = context.l10n;
    final restaurantName = _restaurantController.text.trim();
    final description = _descriptionController.text.trim();
    
    if (restaurantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locale.languageCode == 'de'
              ? 'Bitte gib einen Restaurant-Namen ein'
              : 'Please enter a restaurant name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingRestaurant = true;
    });

    try {
      // Award XP für Restaurant-Vorschlag
      final events = await pointsProvider.awardXP(
        currentUserId, 
        groupId, 
        XPAction.suggestRestaurant,
      );

      // Close dialog
      Navigator.of(dialogContext).pop();
      _restaurantController.clear();
      _descriptionController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locale.languageCode == 'de'
              ? 'Restaurant "$restaurantName" vorgeschlagen! 🍕 +${XPAction.suggestRestaurant.baseXP} XP'
              : 'Restaurant "$restaurantName" suggested! 🍕 +${XPAction.suggestRestaurant.baseXP} XP'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: l10n.locale.languageCode == 'de' ? 'Super!' : 'Great!',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // Show XP Animation
      if (events.contains('xp_gained')) {
        _overlayKey.currentState?.showXPGain(l10n.locale.languageCode == 'de'
            ? '🍕 +${XPAction.suggestRestaurant.baseXP} XP - Restaurant vorgeschlagen!'
            : '🍕 +${XPAction.suggestRestaurant.baseXP} XP - Restaurant suggested!');
      }

      if (events.contains('level_up')) {
        final userPoints = pointsProvider.getUserPoints(currentUserId, groupId);
        if (userPoints != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _overlayKey.currentState?.showLevelUp(userPoints.currentLevel, userPoints.levelTitle);
          });
        }
      }

      if (events.contains('achievement_unlocked')) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _overlayKey.currentState?.showAchievementUnlock(
            l10n.locale.languageCode == 'de' ? 'Restaurant-Scout!' : 'Restaurant Scout!', 
            '🗺️', 
            l10n.locale.languageCode == 'de'
                ? 'Du liebst es, neue Orte zu entdecken!'
                : 'You love discovering new places!'
          );
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locale.languageCode == 'de' 
              ? 'Fehler beim Speichern: $e'
              : 'Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRestaurant = false;
        });
      }
    }
  }

  void _showRestaurantDetails(Map<String, dynamic> restaurant) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(restaurant['name']!),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(restaurant['category']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                restaurant['category']!,
                style: TextStyle(
                  fontSize: 12,
                  color: _getCategoryColor(restaurant['category']),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant['description']!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.locale.languageCode == 'de'
                      ? '${restaurant['rating']} / 5.0 Sterne'
                      : '${restaurant['rating']} / 5.0 stars',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text(l10n.locale.languageCode == 'de'
                    ? '${restaurant['votes']} Stimmen'
                    : '${restaurant['votes']} votes'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(l10n.suggestedBy(restaurant['suggestedBy'])), // LOKALISIERT
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.locale.languageCode == 'de'
                          ? 'In einer späteren Version können hier Öffnungszeiten, Adresse und weitere Details angezeigt werden.'
                          : 'In a future version, opening hours, address and more details can be displayed here.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close), // LOKALISIERT
          ),
          if (!_userVotes.contains(restaurant['name']))
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _voteForRestaurant(restaurant['name']!);
              },
              icon: const Icon(Icons.thumb_up),
              label: Text(l10n.vote), // LOKALISIERT
            ),
        ],
      ),
    );
  }
}