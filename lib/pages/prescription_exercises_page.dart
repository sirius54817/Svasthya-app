import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prescription_exercise.dart';
import '../services/exercise_api_service.dart';
import '../services/database_service.dart';
import '../widgets/exercise_video_player.dart';

class PrescriptionExercisesPage extends StatefulWidget {
  const PrescriptionExercisesPage({super.key});

  @override
  State<PrescriptionExercisesPage> createState() => _PrescriptionExercisesPageState();
}

class _PrescriptionExercisesPageState extends State<PrescriptionExercisesPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Body parts for tabs
  final List<String> _bodyParts = [
    'chest',
    'back', 
    'arms',
    'legs',
    'core',
    'shoulders',
    'cardio',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _bodyParts.length + 2, vsync: this); // +2 for Popular and Search tabs
    _loadPopularExercises(); // Load popular exercises initially
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await ExerciseApiService.getPopularExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _exercises = [];
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load popular exercises');
    }
  }

  Future<void> _loadExercisesByBodyPart(String bodyPart) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await ExerciseApiService.getExercisesByBodyPart(bodyPart);
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _exercises = [];
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load $bodyPart exercises');
    }
  }

  Future<void> _searchExercises(String query) async {
    if (query.trim().isEmpty) {
      _loadPopularExercises();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await ExerciseApiService.searchExercises(query);
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _exercises = [];
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to search exercises');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'Popular'),
            ..._bodyParts.map((bodyPart) => Tab(text: _capitalizeFirst(bodyPart))),
            const Tab(text: 'Search'),
          ],
          onTap: (index) {
            if (index == 0) {
              // Popular tab
              _loadPopularExercises();
            } else if (index <= _bodyParts.length) {
              // Body part tabs
              final bodyPart = _bodyParts[index - 1];
              _loadExercisesByBodyPart(bodyPart);
            }
            // Search tab doesn't auto-load
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExerciseList(), // Popular
          ..._bodyParts.map((_) => _buildExerciseList()), // Body parts
          _buildSearchTab(), // Search
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading exercises...'),
          ],
        ),
      );
    }

    if (_exercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching for different exercises',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise GIF/Video thumbnail
            CompactExerciseVideo(
              videoUrl: exercise.gifUrl,
              exerciseName: exercise.name,
              onTap: () => _showExerciseDetails(exercise),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: exercise.targetMuscles.take(2).map((muscle) {
                      return Chip(
                        label: Text(
                          muscle,
                          style: const TextStyle(fontSize: 10),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  if (exercise.equipments.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Equipment: ${exercise.equipments.join(", ")}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showExerciseDetails(exercise),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search exercises...',
              hintText: 'Try "push up", "cardio", or "dumbbell"',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _loadPopularExercises();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (value) {
              _searchExercises(value);
            },
          ),
        ),
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _searchExercises(_searchQuery),
                    icon: const Icon(Icons.search),
                    label: Text('Search "$_searchQuery"'),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Expanded(child: _buildExerciseList()),
      ],
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise video/GIF
                      ExerciseVideoPlayer(
                        videoUrl: exercise.gifUrl,
                        exerciseName: exercise.name,
                        height: 250,
                        autoPlay: true,
                        showControls: true,
                      ),
                      const SizedBox(height: 20),
                      
                      // Exercise name
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Target muscles
                      if (exercise.targetMuscles.isNotEmpty) ...[
                        const Text(
                          'Target Muscles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: exercise.targetMuscles.map((muscle) {
                            return Chip(
                              label: Text(muscle),
                              backgroundColor: exercise.primaryMuscleColor.withOpacity(0.1),
                              labelStyle: TextStyle(color: exercise.primaryMuscleColor),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Secondary muscles
                      if (exercise.secondaryMuscles.isNotEmpty) ...[
                        const Text(
                          'Secondary Muscles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: exercise.secondaryMuscles.map((muscle) {
                            return Chip(
                              label: Text(muscle),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Body parts
                      if (exercise.bodyParts.isNotEmpty) ...[
                        const Text(
                          'Body Parts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.bodyParts.join(', '),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Equipment
                      if (exercise.equipments.isNotEmpty) ...[
                        const Text(
                          'Required Equipment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.equipments.join(', '),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Instructions
                      if (exercise.instructions.isNotEmpty) ...[
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...exercise.instructions.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: exercise.primaryMuscleColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                      ],
                      
                      // Add to prescription button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _addToPrescription(exercise),
                          icon: const Icon(Icons.add),
                          label: const Text('Add to Patient\'s Exercises'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: exercise.primaryMuscleColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }

  Future<void> _addToPrescription(Exercise exercise) async {
    // Show a dialog to get prescription details
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _buildPrescriptionDialog(exercise),
    );

    if (result != null) {
      try {
        // Create prescription exercise with user input
        final prescriptionExercise = PrescriptionExercise(
          id: '', // Will be generated by Supabase
          prescriptionId: result['prescriptionId'] ?? '',
          exerciseId: exercise.exerciseId,
          sets: result['sets'] ?? 3,
          reps: result['reps'] ?? 10,
          duration: result['duration'],
          frequency: result['frequency'] ?? 'Daily',
          specialInstructions: result['specialInstructions'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Add to database
        await DatabaseService.addPrescriptionExercise(prescriptionExercise);

        if (mounted) {
          Navigator.of(context).pop(); // Close exercise details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${exercise.name} added to prescription!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding exercise: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildPrescriptionDialog(Exercise exercise) {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final durationController = TextEditingController();
    final instructionsController = TextEditingController();
    String frequency = 'Daily';

    return AlertDialog(
      title: Text('Add ${exercise.name} to Prescription'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (optional)',
                hintText: 'e.g., 30 seconds',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: ['Daily', 'Every other day', '3x per week', '2x per week', 'Weekly']
                  .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                  .toList(),
              onChanged: (value) {
                if (value != null) frequency = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(
                labelText: 'Special Instructions (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'prescriptionId': 'current-prescription', // This should be dynamic
              'sets': int.tryParse(setsController.text) ?? 3,
              'reps': int.tryParse(repsController.text) ?? 10,
              'duration': durationController.text.isNotEmpty ? durationController.text : null,
              'frequency': frequency,
              'specialInstructions': instructionsController.text.isNotEmpty ? instructionsController.text : null,
            });
          },
          child: const Text('Add Exercise'),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}