import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../models/snack.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ui_kit.dart';
import 'checkout_screen.dart';

class SnacksScreen extends ConsumerStatefulWidget {
  const SnacksScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.seats,
  });

  final Movie movie;
  final SelectedShowtime showtime;
  final List<String> seats;

  @override
  ConsumerState<SnacksScreen> createState() => _SnacksScreenState();
}

class _SnacksScreenState extends ConsumerState<SnacksScreen> {
  int _category = 0;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(appStateProvider);
      if (state.cart.isEmpty) {
        final combo = MockData.snacks.firstWhere((s) => s.id == 'dune-combo');
        final popcorn = MockData.snacks.firstWhere(
          (s) => s.id == 'artisanal-popcorn',
        );
        state.addSnack(combo);
        state.addSnack(popcorn, size: popcorn.sizes[1]);
      }
    });
  }

  List<String> get _visibleSections {
    switch (_category) {
      case 1:
        return const ['Popcorn & Classic Snacks'];
      case 2:
        return const ['Craft Drinks & Refreshments'];
      default:
        return MockData.snackSections;
    }
  }

  void _openCheckout({bool skip = false}) {
    final state = ref.read(appStateProvider);
    if (skip) {
      state.clearCart();
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          movie: widget.movie,
          showtime: widget.showtime,
          seats: widget.seats,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final seatsLabel = widget.seats.join(', ');
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SubPageHeader(
            title: 'Pre Order Snacks & Concessions',
            subtitle:
                '${widget.movie.title} • ${widget.showtime.auditorium} • Seats $seatsLabel',
            trailing: const TimerChip(label: '09:42'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.event_seat_outlined,
                        title: 'Seat $seatsLabel',
                        subtitle: 'In-seat service before 4:40 PM',
                        badge: 'ACTIVE',
                        badgeColor: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: _InfoTile(
                        icon: Icons.storefront_outlined,
                        title: 'Express Bar',
                        subtitle: 'Turnstile Fast Track lane',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _CinePassBanner(
                  onApply: () {
                    showCineSnack(
                      context,
                      'CinePass Gold applied — free popcorn upgrade added.',
                      icon: Icons.stars_rounded,
                    );
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: MockData.snackCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return FilterChipPill(
                        label: MockData.snackCategories[index],
                        selected: _category == index,
                        onTap: () => setState(() => _category = index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                for (final section in _visibleSections) ...[
                  _buildSection(section, state),
                  const SizedBox(height: 18),
                ],
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.white06),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.room_service_outlined,
                        size: 18,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'Ordered items are delivered directly to Seats $seatsLabel ',
                                style: AppText.bodySmall.copyWith(
                                  fontSize: 9.5,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                              TextSpan(
                                text: 'before the movie previews conclude. Zero line waiting.',
                                style: AppText.bodySmall.copyWith(
                                  fontSize: 9.5,
                                  color: AppColors.outline,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(state),
    );
  }

  Widget _buildSection(String section, AppState state) {
    final items = MockData.snacks.where((s) => s.section == section).toList();
    final curated = section == 'Auditorium Exclusives';
    final title = section == 'Auditorium Exclusives'
        ? 'Auditorium Exclusives'
        : section;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppText.headlineSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (curated) ...[
              const SizedBox(width: 7),
              const FormatTag('IMAX SPECIALS', compact: true),
            ],
            const Spacer(),
            Text(
              section == 'Craft Drinks & Refreshments'
                  ? 'FAST POUR'
                  : '${items.length} CURATED',
              style: AppText.labelCaps.copyWith(
                fontSize: 7.5,
                color: AppColors.outline,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SnackCard(
              item: item,
              state: state,
              onChanged: () => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.98),
        border: const Border(top: BorderSide(color: AppColors.white10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xCC000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${state.cartCount} ${state.cartCount == 1 ? 'ITEM' : 'ITEMS'}',
                          style: AppText.labelFormat.copyWith(
                            fontSize: 8.5,
                            color: AppColors.tertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'In-seat fee: ',
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall.copyWith(
                              fontSize: 9,
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                        Text(
                          'FREE (VIP)',
                          style: AppText.labelCaps.copyWith(
                            fontSize: 8,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total: ',
                          style: AppText.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$${state.cartTotal.toStringAsFixed(2)}',
                          style: AppText.headlineSmall.copyWith(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _openCheckout(skip: true),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceLow,
                    border: Border.all(color: AppColors.white10),
                  ),
                  child: const Icon(
                    Icons.skip_next_rounded,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: PrimaryButton(
                  label: 'Review & Pay \$${state.cartTotal.toStringAsFixed(2)}',
                  height: 52,
                  fontSize: 11.5,
                  onTap: () => _openCheckout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.tertiary),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? AppColors.tertiary).withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          badge!,
                          style: AppText.labelCaps.copyWith(
                            fontSize: 6,
                            color: badgeColor ?? AppColors.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySmall.copyWith(
                    fontSize: 8.5,
                    height: 1.3,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CinePassBanner extends StatelessWidget {
  const _CinePassBanner({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white06),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceHigh,
            ),
            child: const Icon(
              Icons.stars_rounded,
              size: 18,
              color: AppColors.amber,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'VIP CINEPASS PERK',
                      style: AppText.labelCaps.copyWith(
                        fontSize: 7.5,
                        color: AppColors.amber,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'AVAILABLE',
                        style: AppText.labelCaps.copyWith(
                          fontSize: 6,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Free Large Popcorn upgrade eligible',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onApply,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.cyanGradient,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Apply',
                style: AppText.labelFormat.copyWith(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnackCard extends StatelessWidget {
  const _SnackCard({
    required this.item,
    required this.state,
    required this.onChanged,
  });

  final SnackItem item;
  final AppState state;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final quantity = state.quantityOf(item.id);
    final size = state.sizeOf(item.id);
    final price = size?.price ?? item.price;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white06),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(item.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: item.isChefPick
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLowest.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'CHEF\'S PICK',
                            style: AppText.labelCaps.copyWith(
                              fontSize: 5.5,
                              color: AppColors.tertiary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'POPULAR',
                              style: AppText.labelCaps.copyWith(
                                fontSize: 5.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (item.isVegetarian) const _DietTag('VEGETARIAN'),
                        if (item.isGlutenFree) const _DietTag('GLUTEN-FREE'),
                        if (item.badge != null &&
                            item.section != 'Auditorium Exclusives')
                          Text(
                            item.badge!,
                            style: AppText.labelCaps.copyWith(
                              fontSize: 6.5,
                              color: AppColors.outline,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMedium.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8.5,
                        color: AppColors.outline,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: AppText.headlineSmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (item.sizes.isNotEmpty && size != null)
                          Text(
                            '  was \$${item.price.toStringAsFixed(2)}',
                            style: AppText.bodySmall.copyWith(
                              fontSize: 7.5,
                              color: AppColors.outline,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const Spacer(),
                        _QuantityControl(
                          quantity: quantity,
                          onAdd: () {
                            state.addSnack(item, size: size);
                            onChanged();
                          },
                          onRemove: () {
                            state.removeSnack(item);
                            onChanged();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.sizes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: item.sizes.map((option) {
                final selected =
                    (size?.label ?? item.sizes[1].label) == option.label;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option == item.sizes.last ? 0 : 6,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        state.setSnackSize(item, option);
                        onChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryContainer.withValues(
                                  alpha: 0.18,
                                )
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryContainer.withValues(
                                    alpha: 0.5,
                                  )
                                : AppColors.white06,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              option.label,
                              style: AppText.bodySmall.copyWith(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '(\$${option.price.toStringAsFixed(2)})',
                              style: AppText.labelCaps.copyWith(
                                fontSize: 6.5,
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.85)
                                    : AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (item.flavours.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Selected: ${item.flavours}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 8,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    'EDIT',
                    style: AppText.labelCaps.copyWith(
                      fontSize: 6.5,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DietTag extends StatelessWidget {
  const _DietTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: AppText.labelCaps.copyWith(
          fontSize: 5.5,
          color: AppColors.tertiary,
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Add',
                style: AppText.bodySmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(Icons.remove_rounded, onRemove),
          SizedBox(
            width: 20,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppText.labelFormat.copyWith(fontSize: 11),
            ),
          ),
          _stepButton(Icons.add_rounded, onAdd, primary: true),
        ],
      ),
    );
  }

  Widget _stepButton(
    IconData icon,
    VoidCallback onTap, {
    bool primary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          gradient: primary ? AppColors.cyanGradient : null,
          color: primary ? null : AppColors.surfaceHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: primary ? Colors.white : AppColors.onSurface,
        ),
      ),
    );
  }
}
