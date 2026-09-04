// lib/ui/pages/community/community_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prepx_pro/app/ui/pages/community/peer_match_page.dart';
import '../../../controllers/community_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/difficulty_badge.dart';

class CommunityPage extends GetView<CommunityController> {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Experiences', icon: Icon(Icons.forum)),
              Tab(text: 'Find Peers', icon: Icon(Icons.people)),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(Routes.ADD_EXPERIENCE),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _ExperienceFeedTab(),
            PeerMatchPage(),  // ← Yahan change karein
          ],
        ),
      ),
    );
  }
}

class _ExperienceFeedTab extends GetView<CommunityController> {
  const _ExperienceFeedTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingFeed.value && controller.experiences.isEmpty) {
        return _buildShimmer();
      }

      return RefreshIndicator(
        onRefresh: controller.fetchExperiences,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.experiences.length,
          itemBuilder: (context, index) {
            final exp = controller.experiences[index];
            return _buildExperienceCard(exp);
          },
        ),
      );
    });
  }

  Widget _buildExperienceCard(dynamic exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp.company,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${exp.role} • ${DateFormat('MMM d, yyyy').format(exp.createdAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              DifficultyBadge(difficulty: exp.difficulty),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exp.experience,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.likeExperience(exp.id, exp.likes),
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined, color: AppColors.textMuted, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${exp.likes}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.comment_outlined, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 4),
              const Text(
                'Comment',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: AppColors.textMuted, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 40, height: 40, color: AppColors.surfaceLight),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Container(width: double.infinity, height: 14, color: AppColors.surfaceLight),
                      const SizedBox(height: 6),
                      Container(width: 120, height: 10, color: AppColors.surfaceLight),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 60, color: AppColors.surfaceLight),
          ],
        ),
      ),
    );
  }
}

class _PeerMatchTab extends GetView<CommunityController> {
  const _PeerMatchTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPeers.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.peers.isEmpty) {
        return _buildEmptyPeers();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.peers.length,
        itemBuilder: (context, index) {
          final peer = controller.peers[index];
          return _buildPeerCard(peer);
        },
      );
    });
  }

  Widget _buildPeerCard(Map<String, dynamic> peer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peer['role'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${peer['experience']} • Targets: ${peer['targetCompanies'].take(2).join(', ')}',
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.invitePeer(peer['uid'], peer['role']),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPeers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No peers found yet', style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Be the first to join!', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}