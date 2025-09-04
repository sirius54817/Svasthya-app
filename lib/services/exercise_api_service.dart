import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prescription_exercise.dart';

class ExerciseApiService {
  static const String baseUrl = 'https://exercisedb-api-azure.vercel.app/api/v1/exercises';
  
  /// Get exercises with optional search, pagination, and sorting
  static Future<ExerciseApiResponse> getExercises({
    int offset = 0,
    int limit = 20,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ExerciseApiResponse.fromJson(jsonData);
      } else {
        print('❌ ExerciseDB API error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(search ?? '');
      }
    } catch (e) {
      print('❌ Error fetching exercises from ExerciseDB: $e');
      return _getFallbackResponse(search ?? '');
    }
  }

  /// Search exercises by body part
  static Future<List<Exercise>> getExercisesByBodyPart(String bodyPart) async {
    try {
      final response = await getExercises(
        search: bodyPart,
        sortBy: 'targetMuscles',
        limit: 50,
      );
      
      if (response.success) {
        // Filter exercises that actually match the body part
        final filteredExercises = response.data.where((exercise) {
          return exercise.bodyParts.any((part) => 
            part.toLowerCase().contains(bodyPart.toLowerCase()));
        }).toList();
        
        return filteredExercises.isNotEmpty ? filteredExercises : response.data;
      } else {
        return _getFallbackExercisesForBodyPart(bodyPart);
      }
    } catch (e) {
      print('❌ Error fetching exercises for body part $bodyPart: $e');
      return _getFallbackExercisesForBodyPart(bodyPart);
    }
  }

  /// Search exercises by target muscle
  static Future<List<Exercise>> getExercisesByTargetMuscle(String muscle) async {
    try {
      final response = await getExercises(
        search: muscle,
        sortBy: 'targetMuscles',
        limit: 30,
      );
      
      if (response.success) {
        // Filter exercises that actually target the specified muscle
        final filteredExercises = response.data.where((exercise) {
          return exercise.targetMuscles.any((targetMuscle) => 
            targetMuscle.toLowerCase().contains(muscle.toLowerCase()));
        }).toList();
        
        return filteredExercises.isNotEmpty ? filteredExercises : response.data;
      } else {
        return _getFallbackExercisesForMuscle(muscle);
      }
    } catch (e) {
      print('❌ Error fetching exercises for muscle $muscle: $e');
      return _getFallbackExercisesForMuscle(muscle);
    }
  }

  /// Search exercises by equipment
  static Future<List<Exercise>> getExercisesByEquipment(String equipment) async {
    try {
      final response = await getExercises(
        search: equipment,
        sortBy: 'equipments',
        limit: 30,
      );
      
      if (response.success) {
        // Filter exercises that actually use the specified equipment
        final filteredExercises = response.data.where((exercise) {
          return exercise.equipments.any((equip) => 
            equip.toLowerCase().contains(equipment.toLowerCase()));
        }).toList();
        
        return filteredExercises.isNotEmpty ? filteredExercises : response.data;
      } else {
        return _getFallbackExercisesForEquipment(equipment);
      }
    } catch (e) {
      print('❌ Error fetching exercises for equipment $equipment: $e');
      return _getFallbackExercisesForEquipment(equipment);
    }
  }

  /// General search exercises
  static Future<List<Exercise>> searchExercises(String query) async {
    try {
      final response = await getExercises(
        search: query,
        sortBy: 'name',
        limit: 50,
      );
      
      return response.success ? response.data : _getFallbackSearchResults(query);
    } catch (e) {
      print('❌ Error searching exercises with query "$query": $e');
      return _getFallbackSearchResults(query);
    }
  }

  /// Get popular exercises (no search filter)
  static Future<List<Exercise>> getPopularExercises() async {
    try {
      final response = await getExercises(
        limit: 20,
        sortBy: 'name',
        sortOrder: 'asc',
      );
      
      return response.success ? response.data : _getFallbackPopularExercises();
    } catch (e) {
      print('❌ Error fetching popular exercises: $e');
      return _getFallbackPopularExercises();
    }
  }

  // Fallback methods for when API is unavailable
  static ExerciseApiResponse _getFallbackResponse(String search) {
    final fallbackExercises = _getFallbackSearchResults(search);
    return ExerciseApiResponse(
      success: true,
      metadata: ExerciseApiMetadata(
        totalExercises: fallbackExercises.length,
        totalPages: 1,
        currentPage: 1,
        previousPage: null,
        nextPage: null,
      ),
      data: fallbackExercises,
    );
  }

  static List<Exercise> _getFallbackExercisesForBodyPart(String bodyPart) {
    return [
      Exercise(
        exerciseId: 'fallback_${bodyPart.toLowerCase()}_1',
        name: 'Basic ${bodyPart.toLowerCase()} exercise',
        gifUrl: '',
        targetMuscles: [bodyPart.toLowerCase()],
        bodyParts: [bodyPart],
        equipments: ['bodyweight'],
        secondaryMuscles: [],
        instructions: ['Perform basic ${bodyPart.toLowerCase()} movements', 'Focus on proper form'],
      ),
    ];
  }

  static List<Exercise> _getFallbackExercisesForMuscle(String muscle) {
    return [
      Exercise(
        exerciseId: 'fallback_muscle_${muscle.toLowerCase()}_1',
        name: '${muscle} strengthening exercise',
        gifUrl: '',
        targetMuscles: [muscle],
        bodyParts: [muscle],
        equipments: ['bodyweight'],
        secondaryMuscles: [],
        instructions: ['Target the ${muscle} muscle group', 'Maintain controlled movements'],
      ),
    ];
  }

  static List<Exercise> _getFallbackExercisesForEquipment(String equipment) {
    return [
      Exercise(
        exerciseId: 'fallback_equipment_${equipment.toLowerCase()}_1',
        name: '${equipment} exercise',
        gifUrl: '',
        targetMuscles: ['general'],
        bodyParts: ['full body'],
        equipments: [equipment],
        secondaryMuscles: [],
        instructions: ['Use ${equipment} for this exercise', 'Follow proper safety guidelines'],
      ),
    ];
  }

  static List<Exercise> _getFallbackSearchResults(String query) {
    return [
      Exercise(
        exerciseId: 'fallback_search_${query.toLowerCase()}_1',
        name: 'Search result for "$query"',
        gifUrl: '',
        targetMuscles: ['general'],
        bodyParts: ['general'],
        equipments: ['bodyweight'],
        secondaryMuscles: [],
        instructions: ['Exercise related to "$query"', 'Follow proper form and technique'],
      ),
    ];
  }

  static List<Exercise> _getFallbackPopularExercises() {
    return [
      Exercise(
        exerciseId: 'fallback_popular_1',
        name: 'Push-ups',
        gifUrl: '',
        targetMuscles: ['chest', 'triceps'],
        bodyParts: ['chest', 'arms'],
        equipments: ['bodyweight'],
        secondaryMuscles: ['shoulders', 'core'],
        instructions: ['Start in plank position', 'Lower body to ground', 'Push back up'],
      ),
      Exercise(
        exerciseId: 'fallback_popular_2',
        name: 'Squats',
        gifUrl: '',
        targetMuscles: ['quadriceps', 'glutes'],
        bodyParts: ['legs'],
        equipments: ['bodyweight'],
        secondaryMuscles: ['hamstrings', 'calves'],
        instructions: ['Stand with feet hip-width apart', 'Lower into squat position', 'Return to standing'],
      ),
    ];
  }
}
