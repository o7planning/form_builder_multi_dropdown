part of 'form_builder_multi_dropdown.dart';

/// Typedef for the dropdown item builder.
typedef DropdownItemBuilder<T> =
    Widget Function(DropdownItem<T> item, int index, VoidCallback onTap);

/// Typedef for the callback when the selection changes.
typedef OnSelectionChanged<T> = void Function(List<T> selectedItems);

/// Typedef for the callback when the search field value changes.
typedef OnSearchChanged = ValueChanged<String>;

/// Typedef for the selected item builder (Custom Chips).
typedef SelectedItemBuilder<T> = Widget Function(DropdownItem<T> item);

/// Typedef for asynchronous data fetching.
typedef FutureRequest<T> = Future<List<DropdownItem<T>>> Function();
