import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamController());
    final bool isWide = kIsWeb && MediaQuery.of(context).size.width >= Breakpoints.mobile;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            const Text(
              'Team Members',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => controller.passkey.isNotEmpty
                  ? Text(
                      'Passkey: ${controller.passkey.value}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
            child: Container(
              color: Colors.grey.shade50,
              child: RefreshIndicator(
                onRefresh: controller.fetchTeamMembers,
                color: AppColors.primaryBlue,
                child: Column(
            children: [
              // Search & Header Counter Box
              Container(
                color: AppColors.whiteColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.filterMembers,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search_rounded,
                              color: AppColors.primaryBlue, size: 22),
                          hintText: 'Search by name, email or role...',
                          hintStyle: TextStyle(
                              color: Colors.black38, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Member count badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            'Total Team Members: ${controller.filteredMembers.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              color: AppColors.primaryBlue, size: 20),
                          onPressed: controller.fetchTeamMembers,
                          tooltip: 'Refresh',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.black12),

              // Users List View
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: AppColors.primaryBlue),
                          SizedBox(height: 12),
                          Text(
                            'Loading team members...',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredMembers.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_off_rounded,
                                size: 54,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No team members found',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'No users logged in with this passkey yet.',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    itemCount: controller.filteredMembers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = controller.filteredMembers[index];
                      final String displayName =
                          (user.name != null && user.name!.trim().isNotEmpty)
                              ? user.name!.trim()
                              : 'User';
                      final String initial = displayName[0].toUpperCase();
                      final bool isSetup = user.isSetupComplete == true;

                      return InkWell(
                        onTap: () => controller.openMemberProgressDialog(context, user),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Profile Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryBlue
                                    .withValues(alpha: 0.12),
                                backgroundImage: (user.profileUrl != null &&
                                        user.profileUrl!.isNotEmpty)
                                    ? NetworkImage(user.profileUrl!)
                                    : null,
                                child: (user.profileUrl == null ||
                                        user.profileUrl!.isEmpty)
                                    ? Text(
                                        initial,
                                        style: const TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                        if (user.role != null &&
                                            user.role!.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: user.role == 'admin'
                                                  ? Colors.orange.shade100
                                                  : AppColors.primaryBlue
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              user.role!.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: user.role == 'admin'
                                                    ? Colors.orange.shade900
                                                    : AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (user.email != null &&
                                        user.email!.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        user.email!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Joined: ${controller.formatDate(user.createdAt)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSetup
                                                ? Colors.green.shade50
                                                : Colors.amber.shade50,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isSetup ? 'Active' : 'Pending',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isSetup
                                                  ? Colors.green.shade700
                                                  : Colors.amber.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),
);
}
}
