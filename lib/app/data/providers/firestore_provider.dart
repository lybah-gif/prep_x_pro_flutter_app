// lib/app/data/providers/firestore_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Call this ONCE from a temporary button to seed data
  Future<void> seedQuestions() async {
    final questions = [
      QuestionModel(
        id: 'q_flutter_001',
        role: 'Flutter Developer',
        category: 'State Management',
        question: 'What is the difference between GetX, Provider, and Riverpod?',
        answer: 'GetX is a lightweight, all-in-one solution for state management, dependency injection, and routing. Provider is a wrapper around InheritedWidget for dependency injection. Riverpod is an evolution of Provider with compile-time safety and better testing support.',
        difficulty: 'Medium',
        companies: ['Google', 'Amazon', 'Microsoft'],
        tags: ['getx', 'provider', 'riverpod', 'state-management'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_002',
        role: 'Flutter Developer',
        category: 'Widgets',
        question: 'Explain the difference between StatefulWidget and StatelessWidget.',
        answer: 'StatelessWidget is immutable and cannot change its state during runtime. StatefulWidget is mutable and can change its state using setState(). Use StatelessWidget for static UI and StatefulWidget for interactive UI that needs to update.',
        difficulty: 'Easy',
        companies: ['Google', 'Meta', 'Uber'],
        tags: ['widgets', 'stateless', 'stateful'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_003',
        role: 'Flutter Developer',
        category: 'Performance',
        question: 'What is const constructor and when should you use it?',
        answer: 'A const constructor creates a compile-time constant object. Use it when the widget properties won\'t change, allowing Flutter to reuse the widget instance instead of rebuilding it. This improves performance significantly in lists and static layouts.',
        difficulty: 'Medium',
        companies: ['Amazon', 'Netflix'],
        tags: ['performance', 'const', 'optimization'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_004',
        role: 'Flutter Developer',
        category: 'State Management',
        question: 'How does GetX reactive state management work?',
        answer: 'GetX uses Rx (Reactive Extensions) variables like RxString, RxInt, RxList. When an Rx variable changes, only the widgets wrapped in Obx() rebuild. This is more efficient than setState() which rebuilds the entire widget tree.',
        difficulty: 'Hard',
        companies: ['Google', 'Microsoft', 'Tesla'],
        tags: ['getx', 'reactive', 'obs', 'obx'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_005',
        role: 'Flutter Developer',
        category: 'Networking',
        question: 'How do you handle API calls in Flutter with proper error handling?',
        answer: 'Use Dio or http package with try-catch blocks. Implement interceptors for logging and token refresh. Parse JSON responses into models. Show loading states with skeleton screens and handle timeouts, 404, 500 errors with user-friendly messages.',
        difficulty: 'Medium',
        companies: ['Uber', 'Airbnb', 'Amazon'],
        tags: ['api', 'dio', 'http', 'error-handling'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_006',
        role: 'Flutter Developer',
        category: 'System Design',
        question: 'Design a news feed app like Twitter using Flutter.',
        answer: 'Architecture: Clean Architecture with GetX. State: RxList for feed, pagination with ScrollController. Backend: REST API with pagination. Cache: GetStorage for offline. Images: CachedNetworkImage. Real-time: Firebase or WebSockets for notifications.',
        difficulty: 'Hard',
        companies: ['Meta', 'Twitter', 'LinkedIn'],
        tags: ['system-design', 'architecture', 'pagination'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_007',
        role: 'Flutter Developer',
        category: 'Testing',
        question: 'What is the difference between unit tests, widget tests, and integration tests?',
        answer: 'Unit tests test individual functions/classes. Widget tests test UI components in isolation. Integration tests test the complete app flow. Use mockito for mocking, flutter_test for widget tests, and integration_test package for E2E tests.',
        difficulty: 'Medium',
        companies: ['Google', 'Microsoft'],
        tags: ['testing', 'unit-test', 'widget-test'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_008',
        role: 'Flutter Developer',
        category: 'Behavioral',
        question: 'Tell me about a time you had to optimize a slow Flutter app.',
        answer: 'Use STAR method: Situation (app was lagging), Task (needed 60fps), Action (profiled with DevTools, reduced rebuilds with const, used ListView.builder, cached images), Result (FPS improved from 30 to 60, load time reduced by 40%).',
        difficulty: 'Medium',
        companies: ['All'],
        tags: ['behavioral', 'star-method', 'optimization'],
        isTechnical: false,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_009',
        role: 'Flutter Developer',
        category: 'Dart',
        question: 'Explain Futures, Streams, and async/await in Dart.',
        answer: 'Future represents a value that will be available later. Stream is a sequence of asynchronous events. async/await is syntactic sugar for handling Futures without nested callbacks. Use StreamBuilder for reactive UI updates from Streams.',
        difficulty: 'Medium',
        companies: ['Google', 'Amazon', 'Netflix'],
        tags: ['dart', 'future', 'stream', 'async'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_flutter_010',
        role: 'Flutter Developer',
        category: 'Navigation',
        question: 'Compare GetX navigation with Navigator 2.0.',
        answer: 'GetX navigation is simpler: Get.to(), Get.back(), Get.offAll(). No BuildContext needed. Navigator 2.0 is declarative and better for deep linking but verbose. GetX also supports named routes, middleware, and transition animations out of the box.',
        difficulty: 'Easy',
        companies: ['Google', 'Meta'],
        tags: ['navigation', 'getx', 'navigator-2'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      // React Native questions
      QuestionModel(
        id: 'q_rn_001',
        role: 'React Native Developer',
        category: 'Architecture',
        question: 'Explain the Bridge architecture in React Native.',
        answer: 'The Bridge is a communication layer that allows JavaScript and Native modules to interact asynchronously through JSON messages.',
        difficulty: 'Medium',
        companies: ['Meta', 'Shopify', 'Uber'],
        tags: ['bridge', 'architecture', 'react-native'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_rn_002',
        role: 'React Native Developer',
        category: 'Performance',
        question: 'What are the best practices for FlatList optimization?',
        answer: 'Use getItemLayout, keyExtractor, removeClippedSubviews, and avoid anonymous functions in renderItem to prevent unnecessary re-renders.',
        difficulty: 'Hard',
        companies: ['Meta', 'Discord'],
        tags: ['flatlist', 'performance', 'optimization'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      // Backend questions
      QuestionModel(
        id: 'q_backend_001',
        role: 'Backend Engineer',
        category: 'Database',
        question: 'What is the difference between SQL and NoSQL databases?',
        answer: 'SQL databases are relational, structured, and use schemas. NoSQL databases are non-relational, distributed, and schema-less. SQL is better for complex queries, NoSQL for high-write loads and scalability.',
        difficulty: 'Easy',
        companies: ['Amazon', 'Google', 'Microsoft'],
        tags: ['sql', 'nosql', 'database'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_backend_002',
        role: 'Backend Engineer',
        category: 'System Design',
        question: 'Design a system that handles 1 million requests per second.',
        answer: 'Key components: Load Balancers, horizontal scaling of stateless services, caching with Redis, database sharding/partitioning, and asynchronous processing using message queues like Kafka.',
        difficulty: 'Hard',
        companies: ['Netflix', 'Uber', 'Twitter'],
        tags: ['system-design', 'scalability', 'redis'],
        isTechnical: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'q_pm_001',
        role: 'Product Manager',
        category: 'Strategy',
        question: 'How would you measure the success of a new feature?',
        answer: 'Define key metrics (AARRR framework), conduct A/B testing, monitor user retention, track engagement rates, and collect qualitative user feedback through surveys.',
        difficulty: 'Medium',
        companies: ['Google', 'Meta'],
        tags: ['product-management', 'metrics', 'strategy'],
        isTechnical: false,
        createdAt: DateTime.now(),
      ),
    ];

    final batch = _firestore.batch();
    for (final q in questions) {
      final ref = _firestore.collection('questions').doc(q.id);
      batch.set(ref, q.toJson());
    }
    await batch.commit();
  }

  // Fetch questions by role
  Future<List<QuestionModel>> getQuestionsByRole(String role) async {
    try {
      print('Firestore: Fetching all questions and filtering in memory for role: $role');
      // For demo purposes, we'll fetch all and filter in memory to avoid index issues
      final snapshot = await _firestore.collection('questions').get();
      
      final all = snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data()))
          .toList();
      
      final results = all.where((q) => q.role == role).toList();
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('Firestore: Found ${results.length} questions for role $role (out of ${all.length} total)');
      return results;
    } catch (e) {
      print('Firestore Error in getQuestionsByRole: $e');
      rethrow;
    }
  }

  // Fetch all questions (for "All Roles" filter)
  Future<List<QuestionModel>> getAllQuestions({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('questions')
        .limit(limit)
        .get();

    final results = snapshot.docs
        .map((doc) => QuestionModel.fromJson(doc.data()))
        .toList();
        
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }
}