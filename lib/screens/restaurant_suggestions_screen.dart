import 'package:flutter/material.dart';

class RestaurantSuggestionsScreen extends StatelessWidget {
  const RestaurantSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> restaurants = [
      {
        'name': 'Trattoria da Luca',
        'description': 'Italienische Küche mit gemütlichem Innenhof',
        'image':
            'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Burger Garage',
        'description': 'Handgemachte Burger & Craft Beer',
        'image':
            'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Sushiko',
        'description': 'Frisches Sushi in modernem Ambiente',
        'image':
            'https://unsplash.com/de/fotos/ein-teller-sushi-und-essstabchen-auf-einem-tisch-mwFc2qcty_E'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurantvorschläge')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final r = restaurants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    r['image']!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child:
                          const Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name']!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(r['description']!,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Du hast für ${r['name']} gestimmt!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.thumb_up),
                            label: const Text('Abstimmen'),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          const Text("4.5",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
