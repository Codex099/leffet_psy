import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'state_placeholder.dart';

/// Item metadata definition for SearchablePicker
class SearchableItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final String? initials;
  final String? category;
  final Widget? leading;

  const SearchableItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.initials,
    this.category,
    this.leading,
  });
}

/// A modern iOS-styled field that opens a searchable bottom sheet when tapped.
class SearchablePickerField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final String? title;
  final List<SearchableItem<T>> items;
  final T? selectedValue;
  final List<T>? selectedValues;
  final bool isMultiSelect;
  final ValueChanged<T?>? onSingleChanged;
  final ValueChanged<List<T>>? onMultiChanged;
  final IconData leadingIcon;

  const SearchablePickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    this.title,
    this.selectedValue,
    this.selectedValues,
    this.isMultiSelect = false,
    this.onSingleChanged,
    this.onMultiChanged,
    this.leadingIcon = Icons.search_rounded,
  });

  String _getDisplayText() {
    if (isMultiSelect) {
      final count = selectedValues?.length ?? 0;
      if (count == 0) return hintText;
      if (count == 1) {
        final item = items.firstWhereOrNull((i) => i.value == selectedValues!.first);
        return item?.label ?? '1 sélectionné';
      }
      return '$count sélectionnés';
    } else {
      if (selectedValue == null) return hintText;
      final item = items.firstWhereOrNull((i) => i.value == selectedValue);
      return item?.label ?? hintText;
    }
  }

  bool _hasSelection() {
    if (isMultiSelect) {
      return (selectedValues?.length ?? 0) > 0;
    }
    return selectedValue != null;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVal = _hasSelection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(label, style: AppTextStyles.fieldLabel),
          ),
        ],
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasVal ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
                width: hasVal ? 1.2 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  leadingIcon,
                  size: 20,
                  color: hasVal ? AppColors.primary : AppColors.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: hasVal
                        ? AppTextStyles.fieldValue.copyWith(fontWeight: FontWeight.w600)
                        : AppTextStyles.fieldHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMultiSelect && (selectedValues?.length ?? 0) > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${selectedValues!.length}'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Icon(
                  Icons.unfold_more_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPicker(BuildContext context) {
    if (isMultiSelect) {
      SearchablePicker.showMulti<T>(
        context: context,
        title: title ?? label,
        items: items,
        initialSelected: selectedValues ?? [],
        onConfirm: onMultiChanged ?? (_) {},
      );
    } else {
      SearchablePicker.showSingle<T>(
        context: context,
        title: title ?? label,
        items: items,
        initialSelected: selectedValue,
        onSelected: onSingleChanged ?? (_) {},
      );
    }
  }
}

/// Modal Sheet Handler for SearchablePicker
class SearchablePicker {
  SearchablePicker._();

  /// Show Single-Select Searchable Sheet
  static Future<void> showSingle<T>({
    required BuildContext context,
    required String title,
    required List<SearchableItem<T>> items,
    T? initialSelected,
    required ValueChanged<T?> onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SingleSelectSheet<T>(
        title: title,
        items: items,
        selected: initialSelected,
        onSelected: (val) {
          onSelected(val);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  /// Show Multi-Select Searchable Sheet
  static Future<void> showMulti<T>({
    required BuildContext context,
    required String title,
    required List<SearchableItem<T>> items,
    required List<T> initialSelected,
    required ValueChanged<List<T>> onConfirm,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MultiSelectSheet<T>(
        title: title,
        items: items,
        initialSelected: initialSelected,
        onConfirm: (vals) {
          onConfirm(vals);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

/// ─── Single Select BottomSheet ───
class _SingleSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<SearchableItem<T>> items;
  final T? selected;
  final ValueChanged<T?> onSelected;

  const _SingleSelectSheet({
    required this.title,
    required this.items,
    this.selected,
    required this.onSelected,
  });

  @override
  State<_SingleSelectSheet<T>> createState() => _SingleSelectSheetState<T>();
}

class _SingleSelectSheetState<T> extends State<_SingleSelectSheet<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SearchableItem<T>> get _filteredItems {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((item) {
      final labelMatch = item.label.toLowerCase().contains(q);
      final subMatch = item.subtitle?.toLowerCase().contains(q) ?? false;
      final catMatch = item.category?.toLowerCase().contains(q) ?? false;
      return labelMatch || subMatch || catMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: AppTextStyles.screenTitleMedium),
                ),
                if (widget.selected != null)
                  TextButton(
                    onPressed: () => widget.onSelected(null),
                    child: Text('Effacer'.tr, style: TextStyle(color: AppColors.error)),
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _query = val),
                style: AppTextStyles.iosBody,
                decoration: InputDecoration(
                  hintText: 'Rechercher...'.tr,
                  hintStyle: AppTextStyles.iosSubhead.copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Items List
          Expanded(
            child: filtered.isEmpty
                ? StatePlaceholder(
                    type: StatePlaceholderType.empty,
                    title: 'Aucun résultat'.tr,
                    message: 'Aucun élément ne correspond à votre recherche.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (ctx, index) {
                      final item = filtered[index];
                      final isSelected = widget.selected == item.value;

                      return InkWell(
                        onTap: () => widget.onSelected(item.value),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (item.leading != null)
                                item.leading!
                              else
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondaryLight,
                                  child: Text(
                                    item.initials ??
                                        (item.label.isNotEmpty ? item.label[0].toUpperCase() : '?'),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.label,
                                      style: AppTextStyles.cardName.copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// ─── Multi Select BottomSheet ───
class _MultiSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<SearchableItem<T>> items;
  final List<T> initialSelected;
  final ValueChanged<List<T>> onConfirm;

  const _MultiSelectSheet({
    required this.title,
    required this.items,
    required this.initialSelected,
    required this.onConfirm,
  });

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final Set<T> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = Set<T>.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SearchableItem<T>> get _filteredItems {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((item) {
      final labelMatch = item.label.toLowerCase().contains(q);
      final subMatch = item.subtitle?.toLowerCase().contains(q) ?? false;
      final catMatch = item.category?.toLowerCase().contains(q) ?? false;
      return labelMatch || subMatch || catMatch;
    }).toList();
  }

  void _toggleItem(T value) {
    setState(() {
      if (_selected.contains(value)) {
        _selected.remove(value);
      } else {
        _selected.add(value);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selected.addAll(widget.items.map((e) => e.value));
    });
  }

  void _clearAll() {
    setState(() {
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppTextStyles.screenTitleMedium),
                      Text(
                        '${_selected.length} sélectionné${_selected.length > 1 ? '.trs' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _selected.length == widget.items.length ? _clearAll : _selectAll,
                  child: Text(_selected.length == widget.items.length ? 'Tout décocher' : 'Tout sélectionner'),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _query = val),
                style: AppTextStyles.iosBody,
                decoration: InputDecoration(
                  hintText: 'Rechercher...'.tr,
                  hintStyle: AppTextStyles.iosSubhead.copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Items List
          Expanded(
            child: filtered.isEmpty
                ? StatePlaceholder(
                    type: StatePlaceholderType.empty,
                    title: 'Aucun résultat'.tr,
                    message: 'Aucun élément ne correspond à votre recherche.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (ctx, index) {
                      final item = filtered[index];
                      final isSelected = _selected.contains(item.value);

                      return InkWell(
                        onTap: () => _toggleItem(item.value),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (item.leading != null)
                                item.leading!
                              else
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondaryLight,
                                  child: Text(
                                    item.initials ??
                                        (item.label.isNotEmpty ? item.label[0].toUpperCase() : '?'),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.label,
                                      style: AppTextStyles.cardName.copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (_) => _toggleItem(item.value),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: AppButton(
              label: 'Confirmer la sélection (${_selected.length})'.tr,
              onPressed: () => widget.onConfirm(_selected.toList()),
            ),
          ),
        ],
      ),
    );
  }
}
