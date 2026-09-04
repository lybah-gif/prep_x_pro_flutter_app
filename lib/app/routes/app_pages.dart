import 'package:get/get.dart';
import '../bindings/app_binding.dart';
import '../bindings/coding_problems_binding.dart';
import '../bindings/community_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/flashcard_binding.dart';
import '../bindings/mock_interview_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../bindings/question_bank_binding.dart';
import '../bindings/resume_binding.dart';
import '../ui/pages/cheat_sheets/cheat_sheet_detail_page.dart';
import '../ui/pages/cheat_sheets/cheat_sheets_page.dart';
import '../ui/pages/coding_problems/coding_problem_detail_page.dart';
import '../ui/pages/coding_problems/coding_problems_page.dart';
import '../ui/pages/community/add_experience_page.dart';
import '../ui/pages/community/community_page.dart';
import '../ui/pages/flashcards/flashcard_page.dart';
import '../ui/pages/main_shell.dart';
import '../ui/pages/mock_interview/interview_result_page.dart';
import '../ui/pages/mock_interview/mock_interview_page.dart';
import '../ui/pages/mock_interview/mock_interview_setup_page.dart';
import '../ui/pages/onboarding/onboarding_page.dart';
import '../ui/pages/profile/profile_page.dart';
import '../ui/pages/question_bank/question_bank_page.dart';
import '../ui/pages/question_bank/question_detail_page.dart';
import '../ui/pages/resume/resume_upload_page.dart';
import '../ui/pages/splash/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashPage(), binding: AppBinding()),
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingPage(), binding: OnboardingBinding()),
    GetPage(name: Routes.DASHBOARD, page: () => const MainShell(), binding: DashboardBinding()),
    GetPage(name: Routes.QUESTION_BANK, page: () => const QuestionBankPage(), binding: QuestionBankBinding()),
    GetPage(name: Routes.QUESTION_DETAIL, page: () => const QuestionDetailPage()),
    GetPage(name: Routes.CODING_PROBLEMS, page: () => const CodingProblemsPage(), binding: CodingProblemsBinding()),
    GetPage(name: Routes.CODING_PROBLEM_DETAIL, page: () => const CodingProblemDetailPage()),
    GetPage(name: Routes.MOCK_INTERVIEW_SETUP, page: () => const MockInterviewSetupPage(), binding: MockInterviewBinding()),
    GetPage(name: Routes.MOCK_INTERVIEW, page: () => const MockInterviewPage()),
    GetPage(name: Routes.INTERVIEW_RESULT, page: () => const InterviewResultPage()),
    // NEW
    GetPage(name: Routes.RESUME_UPLOAD, page: () => const ResumeUploadPage(), binding: ResumeBinding()),
    GetPage(name: Routes.FLASHCARDS, page: () => const FlashcardPage(), binding: FlashcardBinding()),
    GetPage(name: Routes.PROFILE, page: () => const ProfilePage()),
    GetPage(name: Routes.COMMUNITY, page: () => const CommunityPage(), binding: CommunityBinding()),
    GetPage(name: Routes.ADD_EXPERIENCE, page: () => const AddExperiencePage()),
    GetPage(name: Routes.CHEAT_SHEETS, page: () => CheatSheetsPage()),
    GetPage(name: Routes.CHEAT_SHEET_DETAIL, page: () => const CheatSheetDetailPage()),
  ];
}