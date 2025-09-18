import 'package:flutter/material.dart';
import '../services/gamification_service.dart' as gamification;
import '../theme/app_colors.dart';

class AnimatedBadge extends StatefulWidget {
  final gamification.Badge badge;
  final VoidCallback? onTap;
  final bool showAnimation;

  const AnimatedBadge({
    super.key,
    required this.badge,
    this.onTap,
    this.showAnimation = false,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.primary.withOpacity(0.3),
      end: AppColors.warning,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation && !oldWidget.showAnimation) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.badge.isEarned
                        ? [
                            AppColors.warning.withOpacity(0.1),
                            AppColors.warning.withOpacity(0.05),
                          ]
                        : [
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.badge.isEarned
                        ? AppColors.warning
                        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: widget.badge.isEarned ? 2 : 1,
                  ),
                  boxShadow: widget.badge.isEarned
                      ? [
                          BoxShadow(
                            color: AppColors.warning.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge icon with animation
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.badge.isEarned
                            ? AppColors.warning.withOpacity(0.1)
                            : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        widget.badge.icon,
                        style: TextStyle(
                          fontSize: 32 * _scaleAnimation.value,
                          color: widget.badge.isEarned
                              ? AppColors.warning
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Badge name
                    Text(
                      widget.badge.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.badge.isEarned
                            ? AppColors.warning
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Badge description
                    Text(
                      widget.badge.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.badge.isEarned
                            ? AppColors.warning.withOpacity(0.8)
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Badge category and points
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(widget.badge.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.badge.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(widget.badge.category),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Text(
                          '${widget.badge.points} XP',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.badge.isEarned
                                ? AppColors.warning
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    
                    // Earned indicator
                    if (widget.badge.isEarned) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'EARNED',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'skills':
        return AppColors.primary;
      case 'streaks':
        return AppColors.warning;
      case 'progression':
        return AppColors.success;
      case 'github':
        return AppColors.secondary;
      case 'special':
        return AppColors.error;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }
}

class BadgeCollection extends StatelessWidget {
  final List<gamification.Badge> badges;
  final Function(gamification.Badge)? onBadgeTap;

  const BadgeCollection({
    super.key,
    required this.badges,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Badges Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete achievements to earn badges!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return AnimatedBadge(
          badge: badge,
          onTap: () => onBadgeTap?.call(badge),
          showAnimation: badge.isEarned,
        );
      },
    );
  }
}