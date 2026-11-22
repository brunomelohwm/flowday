import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/themes/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

class TaskSyncFeedback extends StatelessWidget {
  const TaskSyncFeedback({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final writeError = controller.writeErrorMessage;
      if (writeError == null && !controller.isSyncPending) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (writeError != null)
              _notice(
                icon: Icons.cloud_off_outlined,
                color: AppColors.error,
                message:
                    'Uma alteração não foi sincronizada. Verifique sua conexão e tente salvar novamente.',
                trailing: TextButton(
                  onPressed: controller.clearWriteError,
                  child: const Text('Entendi'),
                ),
              ),
            if (controller.isSyncPending)
              _notice(
                icon: Icons.cloud_upload_outlined,
                color: AppColors.textSecondary,
                message: 'Aguardando sincronização',
              ),
          ],
        ),
      );
    },
  );

  Widget _notice({
    required IconData icon,
    required Color color,
    required String message,
    Widget? trailing,
  }) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 13)),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}
