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
// part 'models/network_request.dart';
part 'widgets/dropdown.dart';

/// A multiselect dropdown widget.
///
class FormBuilderMultiDropdown<T extends Object>
    extends FormBuilderFieldDecoration<List<T>> {
  /// The list of dropdown items.
  final List<T> items;

  /// The selection type of the dropdown.
  final bool singleSelect;

  /// The configuration for the chips.
  final ChipDecoration chipDecoration;

  /// The decoration of the field.
  final FieldDecoration fieldDecoration;

  /// The decoration of the dropdown.
  final DropdownDecoration dropdownDecoration;

  /// The decoration of the search field.
  final SearchFieldDecoration searchDecoration;

  /// The decoration of the dropdown items.
  final DropdownItemDecoration dropdownItemDecoration;

  /// The builder for the dropdown items.
  final DropdownItemBuilder<T>? itemBuilder;

  /// The builder for the selected items.
  final SelectedItemBuilder<T>? selectedItemBuilder;

  /// The separator between the dropdown items.
  final Widget? itemSeparator;

  /// The controller for the dropdown.
  final MultiSelectController<T>? controller;

  /// The maximum number of selections allowed.
  final int maxSelections;

  /// Whether the search field is enabled.
  final bool searchEnabled;

  /// The future request for the dropdown items.
  final FutureRequest<T>? future;

  /// The callback when the item is changed.
  ///
  /// This callback is called when any item is selected or unselected.
  final OnSelectionChanged<T>? onSelectionChange;

  /// The callback when the search field value changes.
  final OnSearchChanged? onSearchChange;

  /// Whether to close the dropdown when the back button is pressed.
  ///
  /// Note: This option requires the app to have a router, such as MaterialApp.router, in order to work properly.
  final bool closeOnBackButton;

  final String Function(T item) getItemIdString;
  final String Function(T item) getItemText;

  /// Creates a multiselect dropdown widget.
  ///
  /// The [items] are the list of dropdown items. It is required.
  ///
  /// The [fieldDecoration] is the decoration of the field. The default value is FieldDecoration().
  /// It can be used to customize the field decoration.
  ///
  /// The [dropdownDecoration] is the decoration of the dropdown. The default value is DropdownDecoration().
  /// It can be used to customize the dropdown decoration.
  ///
  /// The [searchDecoration] is the decoration of the search field. The default value is SearchFieldDecoration().
  /// It can be used to customize the search field decoration.
  /// If [searchEnabled] is true, then the search field will be displayed.
  ///
  /// The [dropdownItemDecoration] is the decoration of the dropdown items. The default value is DropdownItemDecoration().
  /// It can be used to customize the dropdown item decoration.
  ///
  /// The [autovalidateMode] is the autovalidate mode for the dropdown. The default value is AutovalidateMode.disabled.
  ///
  /// The [singleSelect] is the selection type of the dropdown. The default value is false.
  /// If true, only one item can be selected at a time.
  ///
  /// The [itemSeparator] is the separator between the dropdown items.
  ///
  /// The [controller] is the controller for the dropdown. It can be used to control the dropdown programmatically.
  ///
  /// The [validator] is the validator for the dropdown. It can be used to validate the dropdown.
  ///
  /// The [itemBuilder] is the builder for the dropdown items. If not provided, the default ListTile will be used.
  ///
  /// The [enabled] is whether the dropdown is enabled. The default value is true.
  ///
  /// The [chipDecoration] is the configuration for the chips. The default value is ChipDecoration().
  /// It can be used to customize the chip decoration. The chips are displayed when an item is selected.
  ///
  /// The [searchEnabled] is whether the search field is enabled. The default value is false.
  ///
  /// The [maxSelections] is the maximum number of selections allowed. The default value is 0.
  ///
  /// The [selectedItemBuilder] is the builder for the selected items. If not provided, the default Chip will be used.
  ///
  /// The [focusNode] is the focus node for the dropdown.
  ///
  /// The [onSelectionChange] is the callback when the item is changed.
  ///
  /// The [closeOnBackButton] is whether to close the dropdown when the back button is pressed. The default value is false.
  /// Note: This option requires the app to have a router, such as MaterialApp.router, in order to work properly.
  ///
  FormBuilderMultiDropdown({
    super.key,
    required this.getItemIdString,
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
  }) : future = null,
       super(
         builder: (FormFieldState<List<T>?> field) {
           final state = field as _FormBuilderMultiSelectChipFieldState<T>;
           // Selected Items:
           final List<T> fieldValue = field.value ?? [];

           //

           return FormField<List<DropdownItem<T>>?>(
             key: state._formFieldKey,
             // TODO: Tam rao` lai. ??????????????????????????????????????????????????????????????????????
             // validator: validator ?? (_) => null,
             autovalidateMode: autovalidateMode,
             initialValue: state._dropdownController.selectedItems,
             enabled: enabled,
             builder: (_) {
               return OverlayPortal(
                 controller: state._portalController,
                 overlayChildBuilder: (_) {
                   final renderBox =
                       state.context.findRenderObject() as RenderBox?;

                   if (renderBox == null || !renderBox.attached) {
                     state._showError('Failed to build the dropdown\nCode: 08');
                     return const SizedBox();
                   }

                   final renderBoxSize = renderBox.size;
                   final renderBoxOffset = renderBox.localToGlobal(Offset.zero);

                   final availableHeight =
                       MediaQuery.of(state.context).size.height -
                       renderBoxOffset.dy -
                       renderBoxSize.height;

                   final showOnTop =
                       availableHeight < dropdownDecoration.maxHeight;

                   final stack = Stack(
                     children: [
                       Positioned.fill(
                         child: GestureDetector(
                           behavior: HitTestBehavior.translucent,
                           onTap: state._handleOutsideTap,
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
                         offset:
                             dropdownDecoration.marginTop == 0
                                 ? Offset.zero
                                 : Offset(0, dropdownDecoration.marginTop),
                         child: RepaintBoundary(
                           child: _Dropdown<T>(
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
                   return stack;
                 },
                 child: CompositedTransformTarget(
                   link: state._layerLink,
                   child: ListenableBuilder(
                     listenable: state._listenable,
                     builder: (_, __) {
                       return InkWell(
                         mouseCursor:
                             enabled
                                 ? SystemMouseCursors.grab
                                 : SystemMouseCursors.forbidden,
                         onTap: enabled ? state._handleTap : null,
                         focusNode: state._focusNode,
                         canRequestFocus: enabled,
                         borderRadius: state._getFieldBorderRadius(),
                         child: InputDecorator(
                           isEmpty:
                               state._dropdownController.selectedItems.isEmpty,
                           isFocused: state._dropdownController.isOpen,
                           decoration: state._buildDecoration(),
                           textAlign: TextAlign.start,
                           textAlignVertical: TextAlignVertical.center,
                           child: state._buildField(),
                         ),
                       );
                     },
                   ),
                 ),
               );
             },
           );
         },
       );

  @override
  FormBuilderFieldDecorationState<FormBuilderMultiDropdown<T>, List<T>>
  createState() => _FormBuilderMultiSelectChipFieldState<T>();
}

class _FormBuilderMultiSelectChipFieldState<T extends Object>
    extends
        FormBuilderFieldDecorationState<FormBuilderMultiDropdown<T>, List<T>> {
  final LayerLink _layerLink = LayerLink();

  final OverlayPortalController _portalController = OverlayPortalController();

  late MultiSelectController<T> _dropdownController =
      widget.controller ?? MultiSelectController<T>();
  final _FutureController _loadingController = _FutureController();

  late FocusNode _focusNode = widget.focusNode ?? FocusNode();

  late final Listenable _listenable = Listenable.merge([
    _dropdownController,
    _loadingController,
  ]);

  // the global key for the form field state to update the form field state when the controller changes
  final GlobalKey<FormFieldState<List<DropdownItem<T>>?>> _formFieldKey =
      GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (_dropdownController.isDisposed) {
      throw StateError('DropdownController is disposed');
    }

    if (widget.future != null) {
      unawaited(_handleFuture());
    }

    if (!_dropdownController._initialized) {
      List<DropdownItem<T>> dropdownItems =
          widget.items
              .map(
                (item) => DropdownItem<T>(
                  label: widget.getItemText(item),
                  value: item,
                  selected: _containItem(value, item, widget.getItemIdString),
                ),
              )
              .toList();
      //
      _dropdownController
        .._initialize()
        ..setItems(dropdownItems);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropdownController
        ..addListener(_controllerListener)
        .._setOnSelectionChange((List<T> selectedItems) {
          //
          // IMPORTANT: didChange (FormBuilder lib).
          //
          didChange(selectedItems);
          if (widget.onSelectionChange != null) {
            widget.onSelectionChange!(selectedItems);
          }
        })
        .._setOnSearchChange(widget.onSearchChange);

      // if close on back button is enabled, then add the listener
      _listenBackButton();
    });
  }

  void _listenBackButton() {
    if (!widget.closeOnBackButton) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _registerBackButtonDispatcherCallback();
      } catch (e) {
        debugPrint('Error: $e');
      }
    });
  }

  void _registerBackButtonDispatcherCallback() {
    final rootBackDispatcher = Router.of(context).backButtonDispatcher;

    if (rootBackDispatcher != null) {
      rootBackDispatcher.createChildBackButtonDispatcher()
        ..addCallback(() {
          if (_dropdownController.isOpen) {
            _dropdownController.closeDropdown();
          }

          return Future.value(true);
        })
        ..takePriority();
    }
  }

  Future<void> _handleFuture() async {
    // we need to wait for the future to complete
    // before we can set the items to the dropdown controller.

    try {
      _loadingController.start();
      final items = await widget.future!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadingController.stop();
        _dropdownController.setItems(items);
      });
    } catch (e) {
      _loadingController.stop();
      rethrow;
    }
  }

  void _controllerListener() {
    // update the form field state when the controller changes
    _formFieldKey.currentState?.didChange(_dropdownController.selectedItems);

    if (_dropdownController.isOpen) {
      _portalController.show();
    } else {
      _dropdownController._clearSearchQuery();
      _portalController.hide();
    }
  }

  void _handleDropdownItemTap(DropdownItem<T> item) {
    if (widget.singleSelect) {
      _dropdownController._toggleOnly(item);
    } else {
      _dropdownController.toggleWhere((element) => element == item);
    }
    _formFieldKey.currentState?.didChange(_dropdownController.selectedItems);

    if (widget.singleSelect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dropdownController.closeDropdown();
      });
    }
  }

  InputDecoration _buildDecoration() {
    final theme = Theme.of(context);

    final border =
        widget.fieldDecoration.border ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.fieldDecoration.borderRadius,
          ),
          borderSide:
              theme.inputDecorationTheme.border?.borderSide ??
              const BorderSide(),
        );

    final fieldDecoration = widget.fieldDecoration;

    final prefixIcon =
        fieldDecoration.prefixIcon != null
            ? IconTheme.merge(
              data: IconThemeData(color: widget.enabled ? null : Colors.grey),
              child: fieldDecoration.prefixIcon!,
            )
            : null;

    return InputDecoration(
      enabled: widget.enabled,
      labelText: fieldDecoration.labelText,
      labelStyle: fieldDecoration.labelStyle,
      hintText: fieldDecoration.hintText,
      hintStyle: fieldDecoration.hintStyle,
      errorText: _formFieldKey.currentState?.errorText,
      filled: fieldDecoration.backgroundColor != null,
      fillColor: fieldDecoration.backgroundColor,
      border: fieldDecoration.border ?? border,
      enabledBorder: fieldDecoration.border ?? border,
      disabledBorder: fieldDecoration.disabledBorder,
      prefixIcon: prefixIcon,
      focusedBorder: fieldDecoration.focusedBorder ?? border,
      errorBorder: fieldDecoration.errorBorder,
      suffixIcon: _buildSuffixIcon(),
      contentPadding: fieldDecoration.padding,
    );
  }

  Widget? _buildSuffixIcon() {
    if (_loadingController.value) {
      return const CircularProgressIndicator.adaptive();
    }

    if (widget.fieldDecoration.showClearIcon &&
        _dropdownController.selectedItems.isNotEmpty) {
      return GestureDetector(
        child: const Icon(Icons.clear),
        onTap: () {
          _dropdownController.clearAll();
          _formFieldKey.currentState?.didChange(
            _dropdownController.selectedItems,
          );
        },
      );
    }

    if (widget.fieldDecoration.suffixIcon == null) {
      return null;
    }

    if (!widget.fieldDecoration.animateSuffixIcon) {
      return widget.fieldDecoration.suffixIcon;
    }

    return AnimatedRotation(
      turns: _dropdownController.isOpen ? 0.5 : 0,
      duration: const Duration(milliseconds: 200),
      child: widget.fieldDecoration.suffixIcon,
    );
  }

  Widget _buildField() {
    if (_dropdownController.selectedItems.isEmpty) {
      return const SizedBox();
    }

    final selectedOptions = _dropdownController.selectedItems;

    if (widget.singleSelect) {
      return Text(selectedOptions.first.label);
    }

    return _buildSelectedItems(selectedOptions);
  }

  /// Build the selected items for the dropdown.
  Widget _buildSelectedItems(List<DropdownItem<T>> selectedOptions) {
    final chipDecoration = widget.chipDecoration;

    if (widget.selectedItemBuilder != null) {
      return Wrap(
        spacing: chipDecoration.spacing,
        runSpacing: chipDecoration.runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children:
            selectedOptions
                .map((option) => widget.selectedItemBuilder!(option))
                .toList(),
      );
    }

    if (chipDecoration.wrap) {
      return Wrap(
        spacing: chipDecoration.spacing,
        runSpacing: chipDecoration.runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children:
            selectedOptions
                .map((option) => _buildChip(option, chipDecoration))
                .toList(),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size(double.infinity, 32)),
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        itemCount: selectedOptions.length,
        itemBuilder: (context, index) {
          final option = selectedOptions[index];
          return _buildChip(option, chipDecoration);
        },
      ),
    );
  }

  Widget _buildChip(
    DropdownItem<dynamic> option,
    ChipDecoration chipDecoration,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: chipDecoration.borderRadius,
        color:
            widget.enabled
                ? chipDecoration.backgroundColor
                : Colors.grey.shade100,
        border: chipDecoration.border,
      ),
      padding: chipDecoration.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(option.label, style: chipDecoration.labelStyle),
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              _dropdownController.unselectWhere(
                (element) => element.label == option.label,
              );
            },
            child: SizedBox(
              width: 16,
              height: 16,
              child:
                  chipDecoration.deleteIcon ??
                  const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius? _getFieldBorderRadius() {
    if (widget.fieldDecoration.border is OutlineInputBorder) {
      return (widget.fieldDecoration.border! as OutlineInputBorder)
          .borderRadius;
    }

    return BorderRadius.circular(widget.fieldDecoration.borderRadius);
  }

  void _handleTap() {
    if (!widget.enabled || _loadingController.value) {
      return;
    }

    if (_portalController.isShowing && _dropdownController.isOpen) return;

    _dropdownController.openDropdown();
  }

  void _handleOutsideTap() {
    if (!_dropdownController.isOpen) return;

    _dropdownController.closeDropdown();
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }

  @override
  void dispose() {
    _dropdownController.removeListener(_controllerListener);

    if (widget.controller == null) {
      _dropdownController.dispose();
    }

    _loadingController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormBuilderMultiDropdown<T> oldWidget) {
    // if the controller is changed, then dispose the old controller
    // and initialize the new controller.
    if (oldWidget.controller != widget.controller) {
      _dropdownController
        ..removeListener(_controllerListener)
        ..dispose();

      _dropdownController = widget.controller ?? MultiSelectController<T>();

      _initializeController();
    } else {
      List<T> oldItems = oldWidget.items;
      List<T> currentItems = widget.items;
      //
      bool contains = _containsItems(
        list: currentItems,
        sub: initialValue,
        itemToIdString: widget.getItemIdString,
      );
      if (!contains) {
        assert(
          contains,
          'The initialValue [$initialValue] is not in the list of items or is not null or empty. '
          'Please provide one of the items as the initialValue or update your initial value. '
          'By default, will apply [null] to field value',
        );
      }
      //
      bool isSameItems = _sameItems(
        list1: oldItems,
        list2: currentItems,
        itemToIdString: widget.getItemIdString,
      );
      //
      List<T> oldSelectedItems = _dropdownController._selectedValues;
      bool isSameSelected = _sameItems(
        list1: oldSelectedItems,
        list2: value ?? <T>[],
        itemToIdString: widget.getItemIdString,
      );
      //
      if (!isSameItems || !isSameSelected) {
        _dropdownController
          ..removeListener(_controllerListener)
          ..dispose();

        _dropdownController = widget.controller ?? MultiSelectController<T>();
        _initializeController();
      }
    }

    // if the focus node is changed, then dispose the old focus node
    // and initialize the new focus node.
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
    }

    super.didUpdateWidget(oldWidget);
  }
}

/// typedef for the dropdown item builder.
typedef DropdownItemBuilder<T> =
    Widget Function(DropdownItem<T> item, int index, VoidCallback onTap);

/// typedef for the callback when the item is selected/de-selected/disabled.
typedef OnSelectionChanged<T> = void Function(List<T> selectedItems);

/// typedef for the callback when the search field value changes.
typedef OnSearchChanged = ValueChanged<String>;

/// typedef for the selected item builder.
typedef SelectedItemBuilder<T> = Widget Function(DropdownItem<T> item);

/// typedef for the future request.
typedef FutureRequest<T> = Future<List<DropdownItem<T>>> Function();

bool _containItem<T>(
  List<T>? list,
  T item,
  String Function(T item) itemToIdString,
) {
  String itemId = itemToIdString(item);
  for (var it in list ?? []) {
    if (itemToIdString(it) == itemId) {
      return true;
    }
  }
  return false;
}

bool _containsItems<T>({
  required List<T> list,
  required List<T>? sub,
  required String Function(T item) itemToIdString,
}) {
  if (sub == null || sub.isEmpty) {
    return true;
  }
  for (T item in sub) {
    bool contain = _containItem(list, item, itemToIdString);
    if (!contain) {
      return false;
    }
  }
  return true;
}

bool _sameItems<T>({
  required List<T> list1,
  required List<T> list2,
  required String Function(T item) itemToIdString,
}) {
  return _containsItems(
        list: list1,
        sub: list2,
        itemToIdString: itemToIdString,
      ) &&
      _containsItems(
        list: list2, //
        sub: list1,
        itemToIdString: itemToIdString,
      );
}
