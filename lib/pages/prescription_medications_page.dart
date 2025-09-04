import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/prescription_medication.dart';

class PrescriptionMedicationsPage extends StatefulWidget {
  const PrescriptionMedicationsPage({super.key});

  @override
  State<PrescriptionMedicationsPage> createState() => _PrescriptionMedicationsPageState();
}

class _PrescriptionMedicationsPageState extends State<PrescriptionMedicationsPage> {
  List<PrescriptionMedication> medications = [];
  List<PrescriptionMedication> filteredMedications = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all'; // 'all', 'active', 'daily', 'twice', 'multiple'
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedications();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      List<PrescriptionMedication>? fetchedMedications;
      
      if (selectedFilter == 'active') {
        fetchedMedications = await DatabaseService.getActivePatientMedications();
      } else {
        fetchedMedications = await DatabaseService.getPatientMedications();
      }

      if (fetchedMedications != null) {
        setState(() {
          medications = fetchedMedications!;
          _applyFiltersAndSearch();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load medications';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    if (filter == 'active') {
      _loadMedications();
    } else {
      _applyFiltersAndSearch();
    }
  }

  void _onSearchChanged() {
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    List<PrescriptionMedication> filtered = List.from(medications);

    // Apply search filter
    String searchTerm = searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((med) =>
          med.medicationName.toLowerCase().contains(searchTerm) ||
          med.dosage.toLowerCase().contains(searchTerm) ||
          med.frequency.toLowerCase().contains(searchTerm)).toList();
    }

    // Apply frequency filter
    if (selectedFilter != 'all' && selectedFilter != 'active') {
      switch (selectedFilter) {
        case 'daily':
          filtered = filtered.where((med) =>
              med.frequency.toLowerCase().contains('once') ||
              med.frequency.toLowerCase().contains('daily')).toList();
          break;
        case 'twice':
          filtered = filtered.where((med) =>
              med.frequency.toLowerCase().contains('twice') ||
              med.frequency.toLowerCase().contains('2 times')).toList();
          break;
        case 'multiple':
          filtered = filtered.where((med) =>
              med.frequency.toLowerCase().contains('3 times') ||
              med.frequency.toLowerCase().contains('4 times') ||
              med.frequency.toLowerCase().contains('every 6 hours') ||
              med.frequency.toLowerCase().contains('every 4 hours')).toList();
          break;
      }
    }

    // Sort by priority (frequency) and then by name
    filtered.sort((a, b) {
      int priorityComparison = a.priorityLevel.compareTo(b.priorityLevel);
      if (priorityComparison != 0) return priorityComparison;
      return a.medicationName.compareTo(b.medicationName);
    });

    setState(() {
      filteredMedications = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadMedications,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search medications...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Daily', 'daily'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Twice Daily', 'twice'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Multiple', 'multiple'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _onFilterChanged(value);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMedications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchController.text.isNotEmpty
                  ? 'No medications found for "${searchController.text}"'
                  : selectedFilter == 'all'
                      ? 'No medications found'
                      : 'No $selectedFilter medications found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your prescribed medications will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredMedications.length,
        itemBuilder: (context, index) {
          final medication = filteredMedications[index];
          return _buildMedicationCard(medication);
        },
      ),
    );
  }

  Widget _buildMedicationCard(PrescriptionMedication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMedicationDetails(medication),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with medication icon and frequency color indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      medication.medicationIcon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.medicationName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          medication.dosage,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: medication.frequencyColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Frequency and duration
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: medication.frequencyColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      medication.frequency,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: medication.frequencyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Duration: ${medication.durationDisplay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              
              // Special instructions indicator
              if (medication.hasSpecialInstructions) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Special instructions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Added date
              const SizedBox(height: 8),
              Text(
                'Added ${_formatDate(medication.createdAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicationDetails(PrescriptionMedication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(medication.medicationIcon),
            const SizedBox(width: 8),
            Expanded(child: Text(medication.medicationName)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Medication', medication.medicationName),
              _buildDetailRow('Dosage', medication.dosage),
              _buildDetailRow('Frequency', medication.frequency),
              _buildDetailRow('Duration', medication.durationDisplay),
              if (medication.hasSpecialInstructions)
                _buildDetailRow('Special Instructions', medication.specialInstructions!),
              _buildDetailRow('Added On', _formatDate(medication.createdAt!)),
              if (medication.updatedAt != null && medication.updatedAt != medication.createdAt)
                _buildDetailRow('Last Updated', _formatDate(medication.updatedAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}