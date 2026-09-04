// lib/app/controllers/flashcard_controller.dart

import 'package:get/get.dart';
import '../data/models/question_model.dart';
import '../services/storage_service.dart';

class FlashcardController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxList<QuestionModel> flashcards = <QuestionModel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isFlipped = false.obs;
  final RxBool isShuffled = false.obs;

  // Demo flashcards (in production, load from bookmarks or weak topics)
  final List<QuestionModel> _demoCards = [
    QuestionModel(
      id: 'fc_001',
      role: 'Flutter Developer',
      category: 'State Management',
      question: 'What is the difference between setState, Provider, and GetX?',
      answer: 'setState: Rebuilds entire widget tree. Provider: DI + InheritedWidget wrapper. GetX: Lightweight, combines state, DI, and routing with reactive programming.',
      difficulty: 'Medium',
      companies: ['Google', 'Amazon'],
      tags: ['state-management', 'getx'],
      isTechnical: true,
      createdAt: DateTime.now(),
    ),
    QuestionModel(
      id: 'fc_002',
      role: 'Flutter Developer',
      category: 'Performance',
      question: 'How does const constructor improve performance?',
      answer: 'const creates compile-time constants. Flutter can reuse the widget instance instead of rebuilding, reducing widget tree calculations and improving frame rates.',
      difficulty: 'Medium',
      companies: ['Meta', 'Netflix'],
      tags: ['performance', 'const'],
      isTechnical: true,
      createdAt: DateTime.now(),
    ),
    QuestionModel(
      id: 'fc_003',
      role: 'Flutter Developer',
      category: 'Widgets',
      question: 'When should you use Keys in Flutter?',
      answer: 'Keys are used when widgets move around in the tree (like in lists), when you need to preserve state across widget rebuilds, or when Flutter needs help identifying which widget changed.',
      difficulty: 'Easy',
      companies: ['Google'],
      tags: ['widgets', 'keys'],
      isTechnical: true,
      createdAt: DateTime.now(),
    ),
    QuestionModel(
      id: 'fc_004',
      role: 'Flutter Developer',
      category: 'System Design',
      question: 'Design a scalable chat app architecture in Flutter.',
      answer: 'Client: Flutter with GetX + WebSockets. Backend: Node.js + Socket.io. Database: MongoDB for messages, Redis for presence. State: Rx streams for real-time updates. Offline: SQLite local cache.',
      difficulty: 'Hard',
      companies: ['WhatsApp', 'Telegram'],
      tags: ['system-design', 'chat'],
      isTechnical: true,
      createdAt: DateTime.now(),
    ),
    QuestionModel(
      id: 'fc_005',
      role: 'Flutter Developer',
      category: 'Behavioral',
      question: 'Tell me about a time you had a conflict with a teammate.',
      answer: 'STAR: Situation - tight deadline, Task - needed to merge conflicting PRs, Action - scheduled pair programming session to align, Result - merged on time and improved team communication process.',
      difficulty: 'Medium',
      companies: ['All'],
      tags: ['behavioral', 'star'],
      isTechnical: false,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadFlashcards();
  }

  void loadFlashcards() {
    final role = _storage.userRole ?? 'Flutter Developer';
    
    if (role == 'React Native Developer') {
      flashcards.value = [
        QuestionModel(
          id: 'fc_rn_001',
          role: 'React Native Developer',
          category: 'Architecture',
          question: 'What is the Bridge in React Native?',
          answer: 'The Bridge is a communication layer that allows JavaScript and Native code to talk to each other asynchronously.',
          difficulty: 'Medium',
          companies: ['Meta', 'Uber'],
          tags: ['bridge', 'architecture'],
          isTechnical: true,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          id: 'fc_rn_002',
          role: 'React Native Developer',
          category: 'UI',
          question: 'Difference between ScrollView and FlatList?',
          answer: 'ScrollView renders all children at once. FlatList is lazy, rendering only visible items, making it far more efficient for long lists.',
          difficulty: 'Easy',
          companies: ['Shopify'],
          tags: ['ui', 'flatlist'],
          isTechnical: true,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          id: 'fc_rn_003',
          role: 'React Native Developer',
          category: 'Logic',
          question: 'What are Hooks in React?',
          answer: 'Hooks are functions that let you "hook into" React state and lifecycle features from functional components (e.g., useState, useEffect).',
          difficulty: 'Medium',
          companies: ['Meta'],
          tags: ['hooks', 'react'],
          isTechnical: true,
          createdAt: DateTime.now(),
        ),
      ];
    } else if (role == 'Backend Engineer') {
      flashcards.value = [
        QuestionModel(
          id: 'fc_be_001',
          role: 'Backend Engineer',
          category: 'Database',
          question: 'What is Database Normalization?',
          answer: 'It is the process of organizing data to reduce redundancy and improve data integrity by dividing large tables into smaller ones.',
          difficulty: 'Medium',
          companies: ['Amazon', 'Oracle'],
          tags: ['database', 'normalization'],
          isTechnical: true,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          id: 'fc_be_002',
          role: 'Backend Engineer',
          category: 'Networking',
          question: 'What is REST?',
          answer: 'Representational State Transfer is an architectural style for providing standards between computer systems on the web, making it easier for systems to communicate.',
          difficulty: 'Easy',
          companies: ['Google'],
          tags: ['rest', 'api'],
          isTechnical: true,
          createdAt: DateTime.now(),
        ),
      ];
    } else {
      // Default Flutter cards
      flashcards.value = List.from(_demoCards);
    }
    
    currentIndex.value = 0;
    isFlipped.value = false;
  }

  void nextCard() {
    if (currentIndex.value < flashcards.length - 1) {
      currentIndex.value++;
      isFlipped.value = false;
    }
  }

  void previousCard() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      isFlipped.value = false;
    }
  }

  void flipCard() {
    isFlipped.value = !isFlipped.value;
  }

  void shuffleCards() {
    flashcards.shuffle();
    currentIndex.value = 0;
    isFlipped.value = false;
    isShuffled.value = true;
  }

  void resetOrder() {
    flashcards.value = List.from(_demoCards);
    currentIndex.value = 0;
    isFlipped.value = false;
    isShuffled.value = false;
  }

  void markAsKnown() {
    // In production: track known cards to reduce frequency
    Get.snackbar('Marked', 'You know this one! Great job.');
    nextCard();
  }

  void markForReview() {
    // In production: add to review queue
    Get.snackbar('Review', 'Added to review queue.');
    nextCard();
  }

  double get progress {
    if (flashcards.isEmpty) return 0;
    return (currentIndex.value + 1) / flashcards.length;
  }
}