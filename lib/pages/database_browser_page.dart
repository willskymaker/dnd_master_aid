import 'package:flutter/material.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import '../widgets/mobile/mobile_search_bar.dart';
import '../widgets/mobile/mobile_list_tile.dart';
import '../widgets/mobile/mobile_bottom_sheet.dart';
import '../repositories/json_data_repository.dart';
import '../core/logger.dart';

/// Pagina per navigare i database D&D 5e ottimizzata per mobile
class DatabaseBrowserPage extends StatefulWidget {
  const DatabaseBrowserPage({Key? key}) : super(key: key);

  @override
  State<DatabaseBrowserPage> createState() => _DatabaseBrowserPageState();
}

class _DatabaseBrowserPageState extends State<DatabaseBrowserPage> {
  String _searchQuery = '';

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
    if (_searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Inizia a digitare per cercare...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, List<dynamic>>>(
      future: _performGlobalSearch(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Errore nella ricerca: ${snapshot.error}'),
          );
        }

        final results = snapshot.data ?? {};
        final hasResults = results.values.any((list) => list.isNotEmpty);

        if (!hasResults) {
          return Center(
            child: Text(
              'Nessun risultato per "$_searchQuery"',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView(
          children: [
            if (results['species']?.isNotEmpty ?? false) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Specie (${results['species']!.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...results['species']!.map((item) => MobileListTile(
                title: item.nome,
                subtitle: item.descrizione.substring(0, item.descrizione.length > 50 ? 50 : item.descrizione.length),
                onTap: () => _showSpecieDetails(item),
                showDivider: true,
              )),
            ],
            if (results['classes']?.isNotEmpty ?? false) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Classi (${results['classes']!.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...results['classes']!.map((item) => MobileListTile(
                title: item.nome,
                subtitle: item.descrizione.substring(0, item.descrizione.length > 50 ? 50 : item.descrizione.length),
                onTap: () => _showClasseDetails(item),
                showDivider: true,
              )),
            ],
            if (results['spells']?.isNotEmpty ?? false) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Incantesimi (${results['spells']!.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...results['spells']!.map((item) => MobileListTile(
                title: item.nome,
                subtitle: 'Livello ${item.livello} - ${item.scuola}',
                onTap: () => _showSpellDetails(item),
                showDivider: true,
              )),
            ],
          ],
        );
      },
    );
  }

  Future<Map<String, List<dynamic>>> _performGlobalSearch(String query) async {
    final results = <String, List<dynamic>>{};

    try {
      // Cerca in parallelo in tutte le categorie
      final futures = await Future.wait([
        JsonDataRepository.searchSpecies(query),
        JsonDataRepository.searchClasses(query),
        JsonDataRepository.searchSpells(query: query),
      ]);

      results['species'] = futures[0];
      results['classes'] = futures[1];
      results['spells'] = futures[2];
    } catch (e) {
      AppLogger.error('Errore nella ricerca globale', e);
    }

    return results;
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
    MobileBottomSheet.show(
      context: context,
      title: 'Equipaggiamento',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataRepository.searchEquipment(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final equipment = snapshot.data ?? [];

          if (equipment.isEmpty) {
            return const Center(child: Text('Nessun equipaggiamento disponibile'));
          }

          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: equipment.map((item) => MobileListTile(
              title: item['italian_name'] ?? item['name'] ?? 'Sconosciuto',
              subtitle: '${item['cost'] ?? 'N/A'} - ${item['weight'] ?? 'N/A'}',
              onTap: () => _showEquipmentDetails(item),
              showDivider: true,
            )).toList(),
          );
        },
      ),
    );
  }

  void _showEquipmentDetails(Map<String, dynamic> item) {
    MobileBottomSheet.show(
      context: context,
      title: item['italian_name'] ?? item['name'] ?? 'Sconosciuto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item['name'] != null && item['name'] != item['italian_name']) ...[
            Text(
              'Nome originale: ${item['name']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
          ],
          _buildDetailRow('Costo', item['cost'] ?? 'N/A'),
          _buildDetailRow('Peso', item['weight'] ?? 'N/A'),
          if (item['damage'] != null) _buildDetailRow('Danno', item['damage']),
          if (item['armor_class'] != null) _buildDetailRow('CA', item['armor_class'].toString()),
          if (item['properties'] != null && (item['properties'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Proprietà',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (item['properties'] as List).map<Widget>((prop) => Chip(
                label: Text(prop.toString()),
                backgroundColor: const Color(0xFF8B4513).withOpacity(0.1),
              )).toList(),
            ),
          ],
          if (item['description'] != null) ...[
            const SizedBox(height: 12),
            Text(
              'Descrizione',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(item['description']),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showBackgroundsBottomSheet() {
    MobileBottomSheet.show(
      context: context,
      title: 'Background',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataRepository.loadBackgrounds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final backgrounds = snapshot.data ?? [];

          if (backgrounds.isEmpty) {
            return const Center(child: Text('Nessun background disponibile'));
          }

          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: backgrounds.map((bg) => MobileListTile(
              title: bg['italian_name'] ?? bg['name'] ?? 'Sconosciuto',
              subtitle: bg['description']?.toString().substring(0, bg['description'].toString().length > 60 ? 60 : bg['description'].toString().length) ?? '',
              onTap: () => _showBackgroundDetails(bg),
              showDivider: true,
            )).toList(),
          );
        },
      ),
    );
  }

  void _showBackgroundDetails(Map<String, dynamic> bg) {
    MobileBottomSheet.show(
      context: context,
      title: bg['italian_name'] ?? bg['name'] ?? 'Sconosciuto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bg['name'] != null && bg['name'] != bg['italian_name']) ...[
            Text(
              'Nome originale: ${bg['name']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (bg['description'] != null) ...[
            Text(
              'Descrizione',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(bg['description']),
            const SizedBox(height: 12),
          ],
          if (bg['skill_proficiencies'] != null) ...[
            _buildDetailRow('Competenze abilità', (bg['skill_proficiencies'] as List).join(', ')),
          ],
          if (bg['tool_proficiencies'] != null) ...[
            _buildDetailRow('Competenze strumenti', bg['tool_proficiencies']),
          ],
          if (bg['languages'] != null) ...[
            _buildDetailRow('Linguaggi', bg['languages']),
          ],
          if (bg['equipment'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Equipaggiamento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(bg['equipment']),
          ],
          if (bg['feature'] != null) ...[
            const SizedBox(height: 12),
            Text(
              bg['feature']['name'] ?? 'Capacità',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(bg['feature']['description'] ?? ''),
          ],
        ],
      ),
    );
  }

  void _showFeatsBottomSheet() {
    MobileBottomSheet.show(
      context: context,
      title: 'Talenti',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataRepository.loadFeats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final feats = snapshot.data ?? [];

          if (feats.isEmpty) {
            return const Center(child: Text('Nessun talento disponibile'));
          }

          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: feats.map((feat) => MobileListTile(
              title: feat['italian_name'] ?? feat['name'] ?? 'Sconosciuto',
              subtitle: feat['prerequisite'] ?? 'Nessun prerequisito',
              onTap: () => _showFeatDetails(feat),
              showDivider: true,
            )).toList(),
          );
        },
      ),
    );
  }

  void _showFeatDetails(Map<String, dynamic> feat) {
    MobileBottomSheet.show(
      context: context,
      title: feat['italian_name'] ?? feat['name'] ?? 'Sconosciuto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (feat['name'] != null && feat['name'] != feat['italian_name']) ...[
            Text(
              'Nome originale: ${feat['name']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (feat['prerequisite'] != null) ...[
            _buildDetailRow('Prerequisito', feat['prerequisite']),
            const SizedBox(height: 8),
          ],
          if (feat['description'] != null) ...[
            Text(
              'Descrizione',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(feat['description']),
          ],
        ],
      ),
    );
  }

  void _showMonstersBottomSheet() {
    MobileBottomSheet.show(
      context: context,
      title: 'Mostri',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataRepository.loadMonsters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final monsters = snapshot.data ?? [];

          if (monsters.isEmpty) {
            return const Center(child: Text('Nessun mostro disponibile'));
          }

          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: monsters.map((monster) => MobileListTile(
              title: monster['italian_name'] ?? monster['name'] ?? 'Sconosciuto',
              subtitle: 'GS ${monster['challenge_rating'] ?? '?'} - ${monster['type'] ?? '?'}',
              onTap: () => _showMonsterDetails(monster),
              showDivider: true,
            )).toList(),
          );
        },
      ),
    );
  }

  void _showMonsterDetails(Map<String, dynamic> monster) {
    MobileBottomSheet.show(
      context: context,
      title: monster['italian_name'] ?? monster['name'] ?? 'Sconosciuto',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (monster['name'] != null && monster['name'] != monster['italian_name']) ...[
              Text(
                'Nome originale: ${monster['name']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildDetailRow('Tipo', monster['type'] ?? 'N/A'),
            _buildDetailRow('Taglia', monster['size'] ?? 'N/A'),
            _buildDetailRow('Allineamento', monster['alignment'] ?? 'N/A'),
            _buildDetailRow('Grado di Sfida', monster['challenge_rating']?.toString() ?? 'N/A'),
            const SizedBox(height: 12),
            Text(
              'Statistiche',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (monster['armor_class'] != null) _buildDetailRow('CA', monster['armor_class'].toString()),
            if (monster['hit_points'] != null) _buildDetailRow('PF', monster['hit_points'].toString()),
            if (monster['speed'] != null) _buildDetailRow('Velocità', monster['speed'].toString()),
            const SizedBox(height: 12),
            if (monster['abilities'] != null) ...[
              Text(
                'Caratteristiche',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAbilityScore('FOR', monster['abilities']['str']),
                  _buildAbilityScore('DES', monster['abilities']['dex']),
                  _buildAbilityScore('COS', monster['abilities']['con']),
                  _buildAbilityScore('INT', monster['abilities']['int']),
                  _buildAbilityScore('SAG', monster['abilities']['wis']),
                  _buildAbilityScore('CAR', monster['abilities']['cha']),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (monster['actions'] != null && (monster['actions'] as List).isNotEmpty) ...[
              Text(
                'Azioni',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...(monster['actions'] as List).map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(action['description'] ?? ''),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAbilityScore(String label, dynamic value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          value?.toString() ?? '-',
          style: const TextStyle(fontSize: 16),
        ),
      ],
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