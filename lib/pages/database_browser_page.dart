import 'package:flutter/material.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import '../widgets/mobile/mobile_search_bar.dart';
import '../widgets/mobile/mobile_list_tile.dart';
import '../widgets/mobile/mobile_bottom_sheet.dart';
import '../repositories/json_data_repository.dart';

/// Pagina per navigare i database D&D 5e ottimizzata per mobile
class DatabaseBrowserPage extends StatefulWidget {
  const DatabaseBrowserPage({Key? key}) : super(key: key);

  @override
  State<DatabaseBrowserPage> createState() => _DatabaseBrowserPageState();
}

class _DatabaseBrowserPageState extends State<DatabaseBrowserPage> {
  String _searchQuery = '';
  int _currentTab = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Specie',
      'icon': Icons.person,
      'count': '30+',
      'description': 'Razze giocabili'
    },
    {
      'name': 'Classi',
      'icon': Icons.school,
      'count': '12',
      'description': 'Classi e sottoclassi'
    },
    {
      'name': 'Incantesimi',
      'icon': Icons.auto_awesome,
      'count': '500+',
      'description': 'Database completo'
    },
    {
      'name': 'Equipaggiamento',
      'icon': Icons.inventory,
      'count': '200+',
      'description': 'Armi, armature, oggetti'
    },
    {
      'name': 'Background',
      'icon': Icons.library_books,
      'count': '25+',
      'description': 'Sfondi e storie'
    },
    {
      'name': 'Talenti',
      'icon': Icons.star,
      'count': '35+',
      'description': 'Abilità speciali'
    },
    {
      'name': 'Mostri',
      'icon': Icons.pets,
      'count': '10+',
      'description': 'Creature e bestie'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: 'Database D&D 5e',
      body: Column(
        children: [
          // Search Bar
          MobileSearchBar(
            hintText: 'Cerca in tutti i database...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          // Categories Grid
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildCategoriesView()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openCategory(category['name']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  category['icon'],
                  size: 32,
                  color: const Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                category['count'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return const Center(
      child: Text(
        'Ricerca in sviluppo...',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _openCategory(String categoryName) {
    switch (categoryName) {
      case 'Specie':
        _showSpeciesBottomSheet();
        break;
      case 'Classi':
        _showClassesBottomSheet();
        break;
      case 'Incantesimi':
        _showSpellsBottomSheet();
        break;
      case 'Equipaggiamento':
        _showEquipmentBottomSheet();
        break;
      case 'Background':
        _showBackgroundsBottomSheet();
        break;
      case 'Talenti':
        _showFeatsBottomSheet();
        break;
      case 'Mostri':
        _showMonstersBottomSheet();
        break;
    }
  }

  void _showSpeciesBottomSheet() {
    MobileBottomSheet.show(
      context: context,
      title: 'Specie D&D 5e',
      isScrollControlled: true,
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder(
        future: JsonDataRepository.loadSpecies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Errore: ${snapshot.error}'),
            );
          }

          final species = snapshot.data ?? [];
          return MobileBottomSheetList(
            children: species.map((specie) => MobileListTile(
              title: specie.nome,
              subtitle: specie.descrizione.length > 100
                  ? '${specie.descrizione.substring(0, 100)}...'
                  : specie.descrizione,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF8B4513).withOpacity(0.1),
                child: Text(
                  specie.nome[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSpecieDetails(specie),
              showDivider: true,
            )).toList(),
          );
        },
      ),
    );
  }

  void _showClassesBottomSheet() {
    MobileBottomSheet.show(
      context: context,
      title: 'Classi D&D 5e',
      isScrollControlled: true,
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder(
        future: JsonDataRepository.loadClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Errore: ${snapshot.error}'),
            );
          }

          final classes = snapshot.data ?? [];
          return MobileBottomSheetList(
            children: classes.map((classe) => MobileListTile(
              title: classe.nome,
              subtitle: '${classe.descrizione.substring(0, classe.descrizione.length > 100 ? 100 : classe.descrizione.length)}...',
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF8B4513).withOpacity(0.1),
                child: Text(
                  classe.nome[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: Text(
                'HD: d${classe.dadoVita}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _showClasseDetails(classe),
              showDivider: true,
            )).toList(),
          );
        },
      ),
    );
  }

  void _showSpellsBottomSheet() {
    MobileBottomSheet.show(
      context: context,
      title: 'Incantesimi D&D 5e',
      isScrollControlled: true,
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder(
        future: JsonDataRepository.loadSpells(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Errore: ${snapshot.error}'),
            );
          }

          final spells = snapshot.data ?? [];
          return MobileBottomSheetList(
            children: spells.take(20).map((spell) => MobileListTile(
              title: spell.nome,
              subtitle: '${spell.scuola} • Livello ${spell.livello}',
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getSpellLevelColor(spell.livello),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    spell.livello == 0 ? 'C' : '${spell.livello}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              trailing: const Icon(Icons.auto_awesome, size: 16),
              onTap: () => _showSpellDetails(spell),
              showDivider: true,
            )).toList(),
          );
        },
      ),
    );
  }

  void _showEquipmentBottomSheet() {
    // Implementazione semplificata
    MobileBottomSheet.show(
      context: context,
      title: 'Equipaggiamento',
      child: const Center(
        child: Text('Database equipaggiamento\nin sviluppo...'),
      ),
    );
  }

  void _showBackgroundsBottomSheet() {
    // Implementazione semplificata
    MobileBottomSheet.show(
      context: context,
      title: 'Background',
      child: const Center(
        child: Text('Database background\nin sviluppo...'),
      ),
    );
  }

  void _showFeatsBottomSheet() {
    // Implementazione semplificata
    MobileBottomSheet.show(
      context: context,
      title: 'Talenti',
      child: const Center(
        child: Text('Database talenti\nin sviluppo...'),
      ),
    );
  }

  void _showMonstersBottomSheet() {
    // Implementazione semplificata
    MobileBottomSheet.show(
      context: context,
      title: 'Mostri',
      child: const Center(
        child: Text('Database mostri\nin sviluppo...'),
      ),
    );
  }

  void _showSpecieDetails(dynamic specie) {
    MobileBottomSheet.show(
      context: context,
      title: specie.nome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrizione',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(specie.descrizione),
          const SizedBox(height: 16),
          if (specie.competenze.isNotEmpty) ...[
            Text(
              'Competenze',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: specie.competenze.map<Widget>((comp) => Chip(
                label: Text(comp),
                backgroundColor: const Color(0xFF8B4513).withOpacity(0.1),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showClasseDetails(dynamic classe) {
    MobileBottomSheet.show(
      context: context,
      title: classe.nome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrizione',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(classe.descrizione),
          const SizedBox(height: 16),
          Text(
            'Dado Vita: d${classe.dadoVita}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (classe.sottoclassi.isNotEmpty) ...[
            Text(
              'Sottoclassi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: classe.sottoclassi.map<Widget>((sub) => Chip(
                label: Text(sub),
                backgroundColor: const Color(0xFF8B4513).withOpacity(0.1),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showSpellDetails(dynamic spell) {
    MobileBottomSheet.show(
      context: context,
      title: spell.nome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getSpellLevelColor(spell.livello),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  spell.livello == 0 ? 'Cantrip' : 'Livello ${spell.livello}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  spell.scuola,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Descrizione',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(spell.descrizione),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Raggio', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(spell.raggio),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Durata', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(spell.durata),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSpellLevelColor(int level) {
    switch (level) {
      case 0: return Colors.grey;
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      case 5: return Colors.purple;
      default: return Colors.black;
    }
  }
}