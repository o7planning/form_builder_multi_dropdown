import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

part 'controllers/future_controller.dart';

part 'controllers/multiselect_controller.dart';

part 'enum/enums.dart';

part 'models/decoration.dart';

part 'models/dropdown_item.dart';

part 'typedef.dart';

part 'widgets/dropdown.dart';

/// The 2026 Pro Version: FormBuilderMultiDropdown
/// Merged with the latest multi_dropdown core features (ExpandDirection.auto, Animations, etc.)
class FormBuilderMultiDropdown<ITEM extends Object>
    extends FormBuilderFieldDecoration<List<ITEM>> {
  final List<ITEM> items;
  final bool singleSelect;
  final ChipDecoration chipDecoration;
  final FieldDecoration fieldDecoration;
  final DropdownDecoration dropdownDecoration;
  final SearchFieldDecoration searchDecoration;
  final DropdownItemDecoration dropdownItemDecoration;
  final DropdownItemBuilder<ITEM>? itemBuilder;
  final SelectedItemBuilder<ITEM>? selectedItemBuilder;
  final Widget? itemSeparator;
  final MultiSelectController<ITEM>? controller;
  final int maxSelections;
  final bool searchEnabled;
  final FutureRequest<ITEM>? future;
  final OnSelectionChanged<ITEM>? onSelectionChange;
  final OnSearchChanged? onSearchChange;
  final bool closeOnBackButton;
  final String Function(ITEM item) getItemText;

  final FloatingLabelBehavior? floatingLabelBehavior;

  FormBuilderMultiDropdown({
    super.key,
    required this.getItemText,
    required super.name,
    required this.items,
    super.initialValue,
    this.fieldDecoration = const FieldDecoration(),
    this.dropdownDecoration = const DropdownDecoration(),
    this.searchDecoration = const SearchFieldDecoration(),
    this.dropdownItemDecoration = const DropdownItemDecoration(),
    super.autovalidateMode,
    this.singleSelect = false,
    this.itemSeparator,
    this.controller,
    super.validator,
    this.itemBuilder,
    super.enabled = true,
    this.chipDecoration = const ChipDecoration(),
    this.searchEnabled = false,
    this.maxSelections = 0,
    this.selectedItemBuilder,
    super.focusNode,
    this.onSelectionChange,
    this.onSearchChange,
    this.closeOnBackButton = false,
    this.future,
    this.floatingLabelBehavior,
  }) : super(
         builder: (FormFieldState<List<ITEM>?> field) {
           final state = field as _FormBuilderMultiSelectChipFieldState<ITEM>;

           return ListenableBuilder(
             listenable: state._listenable,
             builder: (context, _) {
               return OverlayPortal(
                 controller: state._portalController,
                 overlayChildBuilder: (context) {
                   final renderBox =
                       state.context.findRenderObject() as RenderBox?;
                   if (renderBox == null || !renderBox.attached) {
                     return const SizedBox.shrink();
                   }

                   final renderBoxSize = renderBox.size;
                   final renderBoxOffset = renderBox.localToGlobal(Offset.zero);

                   final screenHeight = MediaQuery.of(context).size.height;
                   final spaceBelow =
                       screenHeight - renderBoxOffset.dy - renderBoxSize.height;
                   final spaceAbove = renderBoxOffset.dy;

                   final bool showOnTop;
                   switch (dropdownDecoration.expandDirection) {
                     case ExpandDirection.down:
                       showOnTop = false;
                       break;
                     case ExpandDirection.up:
                       showOnTop = true;
                       break;
                     case ExpandDirection.auto:
                       showOnTop =
                           spaceBelow < dropdownDecoration.maxHeight &&
                           spaceAbove > spaceBelow;
                       break;
                   }

                   final marginOffset = Offset(
                     0,
                     showOnTop
                         ? -dropdownDecoration.marginTop
                         : dropdownDecoration.marginTop,
                   );

                   return Stack(
                     children: [
                       Positioned.fill(
                         child: Listener(
                           behavior: HitTestBehavior.translucent,
                           onPointerDown: state._handleOutsideTap,
                         ),
                       ),
                       CompositedTransformFollower(
                         link: state._layerLink,
                         showWhenUnlinked: false,
                         targetAnchor:
                             showOnTop
                                 ? Alignment.topLeft
                                 : Alignment.bottomLeft,
                         followerAnchor:
                             showOnTop
                                 ? Alignment.bottomLeft
                                 : Alignment.topLeft,
                         offset: marginOffset,
                         child: RepaintBoundary(
                           child: _Dropdown<ITEM>(
                             decoration: dropdownDecoration,
                             onItemTap: state._handleDropdownItemTap,
                             width: renderBoxSize.width,
                             items: state._dropdownController.items,
                             searchEnabled: searchEnabled,
                             dropdownItemDecoration: dropdownItemDecoration,
                             itemBuilder: itemBuilder,
                             itemSeparator: itemSeparator,
                             searchDecoration: searchDecoration,
                             maxSelections: maxSelections,
                             singleSelect: singleSelect,
                             onSearchChange:
                                 state._dropdownController._setSearchQuery,
                           ),
                         ),
                       ),
                     ],
                   );
                 },
                 child: AnimatedSize(
                   duration: const Duration(milliseconds: 200),
                   curve: Curves.easeInOut,
                   alignment: Alignment.topCenter,
                   child: CompositedTransformTarget(
                     link: state._layerLink,
                     child: Semantics(
                       label: fieldDecoration.labelText ?? 'Dropdown field',
                       button: true,
                       enabled: enabled,
                       child: InkWell(
                         onTap: enabled ? state._handleTap : null,
                         focusNode: state._focusNode,
                         borderRadius: state._getFieldBorderRadius(),
                         child: InputDecorator(
                           decoration: state._buildDecoration().copyWith(
                             errorText: state.errorText,
                           ),
                           isEmpty:
                               state._dropdownController.selectedItems.isEmpty,
                           isFocused:
                               state._dropdownController.isOpen ||
                               state._focusNode.hasFocus,
                           child: state._buildField(),
                         ),
                       ),
                     ),
                   ),
                 ),
               );
             },
           );
         },
       );

  @override
  FormBuilderFieldDecorationState<FormBuilderMultiDropdown<ITEM>, List<ITEM>>
  createState() => _FormBuilderMultiSelectChipFieldState<ITEM>();
}

class _FormBuilderMultiSelectChipFieldState<ITEM extends Object>
    extends
        FormBuilderFieldDecorationState<
          FormBuilderMultiDropdown<ITEM>,
          List<ITEM>
        > {
  final LayerLink _layerLink = LayerLink();
  final _FutureController _futureLoadingController = _FutureController();
  final OverlayPortalController _portalController = OverlayPortalController();
  late MultiSelectController<ITEM> _dropdownController =
      widget.controller ?? MultiSelectController<ITEM>();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  bool _lastIsOpenState = false;

  late final Listenable _listenable = Listenable.merge([
    _dropdownController,
    _focusNode,
  ]);

  @override
  void initState() {
    super.initState();
    _lastIsOpenState = _dropdownController.isOpen;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeController(isUpdate: false);
    });
  }

  void _initializeController({required bool isUpdate}) async {
    if (_dropdownController.isDisposed) return;

    if (widget.future != null) {
      try {
        _futureLoadingController.start();
        final remoteDropdownItems = await widget.future!();

        if (_dropdownController.isDisposed || !mounted) return;

        final initializedItems =
            remoteDropdownItems.map((item) {
              return item.copyWith(
                selected: value?.contains(item.value) ?? false,
              );
            }).toList();

        _dropdownController
          .._initialize()
          ..setItems(initializedItems);
      } catch (e) {
        debugPrint('FormBuilderMultiDropdown async load error: $e');
      } finally {
        if (mounted && !_dropdownController.isDisposed) {
          _futureLoadingController.stop();
        }
      }
    } else {
      final dropdownItems =
          widget.items
              .map(
                (item) => DropdownItem<ITEM>(
                  label: widget.getItemText(item),
                  value: item,
                  selected: value?.contains(item) ?? false,
                ),
              )
              .toList();

      _dropdownController
        .._initialize()
        ..setItems(dropdownItems);
    }

    _dropdownController.removeListener(_controllerListener);
    _dropdownController.addListener(_controllerListener);

    _dropdownController._setOnSelectionChange((selectedItems) {
      if (mounted) {
        didChange(selectedItems);
        widget.onSelectionChange?.call(selectedItems);
      }
    });

    if (isUpdate) {
      didChange(_dropdownController.selectedItems.map((e) => e.value).toList());
    }
  }

  @override
  void didUpdateWidget(covariant FormBuilderMultiDropdown<ITEM> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool itemsChanged = !listEquals(oldWidget.items, widget.items);
    final bool futureChanged = oldWidget.future != widget.future;
    final bool controllerChanged = oldWidget.controller != widget.controller;

    final formBuilderState = FormBuilder.of(context);
    final parentInitialValues =
        formBuilderState?.initialValue[widget.name] as List<ITEM>?;
    final List<ITEM> effectiveParentValue =
        parentInitialValues ?? widget.initialValue ?? <ITEM>[];

    final bool isOutofSyncWithTask =
        !_sameItems(
          effectiveParentValue,
          _dropdownController.selectedItems.map((e) => e.value).toList(),
        );

    if (controllerChanged) {
      oldWidget.controller?.removeListener(_controllerListener);
      _dropdownController = widget.controller ?? MultiSelectController<ITEM>();
    }

    if (itemsChanged ||
        futureChanged ||
        controllerChanged ||
        isOutofSyncWithTask) {
      if (!mounted) return;

      setValue(effectiveParentValue);
      _dropdownController._setOnSelectionChange(null);

      if (widget.future == null) {
        final dropdownItems =
            widget.items.map((item) {
              return DropdownItem<ITEM>(
                label: widget.getItemText(item),
                value: item,
                selected: _containItem(effectiveParentValue, item),
              );
            }).toList();

        _dropdownController
          .._initialize()
          ..setItems(dropdownItems);

        _dropdownController._setOnSelectionChange((selectedItems) {
          if (mounted) {
            didChange(selectedItems);
            widget.onSelectionChange?.call(selectedItems);
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _initializeController(isUpdate: true);
        });
      }
    }
  }

  void _controllerListener() {
    if (_lastIsOpenState == _dropdownController.isOpen) return;
    _lastIsOpenState = _dropdownController.isOpen;

    if (_dropdownController.isOpen) {
      _portalController.show();
    } else {
      _dropdownController._clearSearchQuery();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _portalController.hide();
        }
      });
    }
  }

  bool _containItem(List<ITEM>? list, ITEM item) {
    for (var it in list ?? []) {
      if (it == item) return true;
      if (widget.getItemText(it) == widget.getItemText(item)) return true;
    }
    return false;
  }

  bool _containsItems(List<ITEM> list, List<ITEM>? sub) {
    if (sub == null || sub.isEmpty) return true;
    for (ITEM item in sub) {
      if (!_containItem(list, item)) return false;
    }
    return true;
  }

  bool _sameItems(List<ITEM> list1, List<ITEM> list2) {
    return _containsItems(list1, list2) && _containsItems(list2, list1);
  }

  @override
  void reset() {
    super.reset();
    if (!_dropdownController.isDisposed) {
      _dropdownController.clearSearch();
      _initializeController(isUpdate: false);
    }
  }

  void _handleDropdownItemTap(DropdownItem<ITEM> item) {
    if (widget.singleSelect) {
      _dropdownController._toggleOnly(item);
      _dropdownController.closeDropdown();
    } else {
      _dropdownController.toggleWhere((e) => e == item);
    }
  }

  void _handleTap() {
    if (widget.enabled) {
      FocusManager.instance.primaryFocus?.unfocus();
      _focusNode.requestFocus();
      _dropdownController.openDropdown();
    }
  }

  void _handleOutsideTap(PointerDownEvent event) {
    if (!_dropdownController.isOpen) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.attached) {
      final localPosition = renderBox.globalToLocal(event.position);
      if (renderBox.paintBounds.contains(localPosition)) return;
    }
    _dropdownController.closeDropdown();
  }

  InputDecoration _buildDecoration() {
    final deco = widget.fieldDecoration;
    if (deco.inputDecoration != null) {
      return deco.inputDecoration!.copyWith(
        enabled: widget.enabled,
        errorText: errorText,
      );
    }
    return InputDecoration(
      isDense: false,
      filled: true,
      floatingLabelBehavior: widget.floatingLabelBehavior,
      enabled: widget.enabled,
      labelText: deco.labelText,
      enabledBorder: deco.border,
      focusedErrorBorder: deco.errorBorder,
      border: deco.border ?? const OutlineInputBorder(),
      focusedBorder: deco.focusedBorder,
      errorBorder: deco.errorBorder,
      disabledBorder: deco.disabledBorder,
      contentPadding: deco.padding,
      suffixIcon: AnimatedRotation(
        turns: _dropdownController.isOpen ? 0.5 : 0,
        duration: const Duration(milliseconds: 200),
        child: deco.suffixIcon ?? const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget _buildField() {
    final selected = _dropdownController.selectedItems;
    if (selected.isEmpty) return const SizedBox.shrink();
    if (widget.singleSelect) return Text(selected.first.label);

    return _buildSelectedItems(selected);
  }

  Widget _buildSelectedItems(List<DropdownItem<ITEM>> selectedOptions) {
    final chipDeco = widget.chipDecoration;
    return Wrap(
      spacing: chipDeco.spacing,
      runSpacing: chipDeco.runSpacing,
      children: selectedOptions.map((opt) => _buildChip(opt)).toList(),
    );
  }

  Widget _buildChip(DropdownItem<ITEM> option) {
    return Chip(
      label: Text(option.label, style: widget.chipDecoration.labelStyle),
      backgroundColor: widget.chipDecoration.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: widget.chipDecoration.borderRadius,
        side: BorderSide.none,
      ),
      onDeleted:
          () =>
              _dropdownController.unselectWhere((e) => e.value == option.value),
    );
  }

  BorderRadius _getFieldBorderRadius() =>
      BorderRadius.circular(widget.fieldDecoration.borderRadius);

  @override
  void dispose() {
    _dropdownController.removeListener(_controllerListener);
    _futureLoadingController.dispose();
    if (widget.controller == null) _dropdownController.dispose();
    super.dispose();
  }
}
