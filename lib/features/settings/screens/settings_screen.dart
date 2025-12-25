import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';

/// Screen for configuring app settings/preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            // Theme Section
            const _SectionHeader(title: 'Appearance'),

            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: getThemeModeLabel(currentTheme),
              onTap: () => _showThemeDialog(context, ref, currentTheme),
            ),

            const Divider(),

            // About Section
            const _SectionHeader(title: 'About'),

            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About ${AppStrings.appName}',
              subtitle: 'Version info, licenses',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const AboutAppScreen()),
              ),
            ),

            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Open Source Licenses',
              subtitle: 'Third-party software',
              onTap: () => showLicensePage(
                context: context,
                applicationName: AppStrings.appName,
                applicationVersion: '1.0.0',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Icon(
                    Icons.auto_stories,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            const Divider(),

            // Data Section
            const _SectionHeader(title: 'Data'),

            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear All Articles',
              subtitle: 'Delete all saved articles',
              onTap: () => _showClearDataDialog(context, ref),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            final isSelected = mode == current;
            return ListTile(
              leading: Icon(
                getThemeModeIcon(mode),
                color: isSelected
                    ? Theme.of(dialogContext).colorScheme.primary
                    : null,
              ),
              title: Text(
                getThemeModeLabel(mode),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(dialogContext).colorScheme.primary
                      : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await ref
                    .read(settingsViewModelProvider.notifier)
                    .setThemeMode(mode);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showClearDataDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Clear All Articles?'),
        content: const Text(
          'This will permanently delete all saved articles. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      await ref.read(settingsViewModelProvider.notifier).clearAllData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All articles deleted')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.p16,
        AppSizes.p16,
        AppSizes.p16,
        AppSizes.p8,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.p32),

            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.auto_stories,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: AppSizes.p16),

            // App Name
            Text(
              AppStrings.appName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.p4),

            // Version
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: AppSizes.p24),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
              child: Text(
                'Save articles from the web and read them offline, '
                'anytime, anywhere. Clean, distraction-free reading experience.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSizes.p32),

            // Info Cards
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Column(
                children: [
                  _AboutCard(
                    icon: Icons.code,
                    title: 'Made with Flutter',
                    subtitle: 'Cross-platform app development',
                  ),
                  SizedBox(height: AppSizes.p12),
                  _AboutCard(
                    icon: Icons.offline_bolt,
                    title: 'Offline First',
                    subtitle: 'Articles saved locally on your device',
                  ),
                  SizedBox(height: AppSizes.p12),
                  _AboutCard(
                    icon: Icons.lock_outline,
                    title: 'Privacy Focused',
                    subtitle: 'No tracking, no analytics, no ads',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.p32),

            // Footer
            Text(
              '© ${DateTime.now().year} ${AppStrings.appName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: AppSizes.p48),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
