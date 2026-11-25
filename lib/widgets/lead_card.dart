import 'package:start3x_app/exports.dart';

class LeadCardWidget extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback? onTap;

  const LeadCardWidget({
    super.key,
    required this.lead,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Get.toNamed(AppRoutes.callingScreen, arguments: lead);
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              lead.rank,
              style: AppTextStyles.rankText,
            ),
            Container(
              height: 32,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white24,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lead.location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 125),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lead.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTagBold,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (lead.scheduledDate??"").split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTagLight,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (lead.scheduledDate??"").split(' ').skip(1).join(' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTagLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
