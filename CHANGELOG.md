# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project follows [Semantic Versioning](https://semver.org/).



---


## 1.0.0

### Graduation to Production Ready 

After rigorous regression testing and production environment validation, `form_builder_multi_dropdown` is officially stable, fully optimized, and ready for high-scale enterprise applications.

### Added
- **Deep Collection Equality Engine**: Introduced pure object-level collection evaluation (`_sameItems` and `_containsItems`) mirroring advanced identification mechanisms without forcing developers to provide rigid entity IDs. Completely eliminates the notorious "Item not found in options" assertion errors during external mutations.
- **FlutterArtist Framework Compatibility**: Optimized internal form state subscription mechanics to gracefully react to unidirectional data flow pipelines (`FormModel`, `Block` state switches). Form values now refresh instantly across views without dropping data states.
- **Dynamic Semantics**: Enhanced accessibility layer support by wiring predictable semantics labels directly onto the component boundaries for cleaner automated UI widget testing.

### Fixed
- **Synchronous Mutation Lag & Flickering**: Banished dependency on excessive `WidgetsBinding.instance.addPostFrameCallback` delays during parent configuration updates. State reconciliation now runs synchronously inside `didUpdateWidget`, completely eradicating layout flickering and accidental `null` value initialization drops.
- **Overlay Framework Lifecycle Crash**: Fixed a severe Flutter framework crash (`SchedulerPhase.persistentCallbacks` assertion error) triggered when `OverlayPortalController.hide()` was invoked during active layout/rebuild callbacks. Implemented a tracked state guard with safe post-frame scheduling fallback mechanisms.
- **Render Tree ListTile Assertion Warning**: Resolved an issue where wrapping option items in localized `AnimatedContainer` backgrounds masked nearest `Material` splash layers. Refactored color rendering natively into `ListTile.tileColor` and `selectedTileColor` properties, unblocking smooth Ink Ripple effects.
- **Feedback Mutation Loops**: Resolved a locked frozen state bug where controller interactions and form change events concurrently fought for the single-source-of-truth state, occasionally freezing UI selection checks. Added callback toggle guards during item setup routines.

## 0.9.7

- Add Examples

## 0.9.6

- Fix README documentation.

## 0.9.5

- Update README documentation, add DEMO.

## 0.9.4

- Add `future` property to FormBuilderMultiDropdown.

## 0.9.3

- Fix web support.

## 0.9.1

- Update README documentation.

## 0.9.0

### Added

- Full integration with `flutter_form_builder`
- Generic object support with `FormBuilderMultiDropdown<T>`
- Searchable dropdown support
- Single select mode
- Multiple selection mode
- Async data loading support
- Selection change callback
- Search change callback
- Validation support
- Controller support via `MultiSelectController`
- Custom dropdown item builder
- Custom selected item builder
- Custom separator support
- Accessibility improvements
- Overlay-based dropdown rendering
- Smooth open/close animations
- Auto expand direction support (`up`, `down`, `auto`)
- Improved outside tap detection
- Floating label behavior support
- Chip customization
- Dropdown customization
- Search field customization
- Support for dynamic item updates

### Improved

- Upgraded internal dropdown core based on `multi_dropdown 3.1.1`
- Improved dropdown positioning logic
- Improved keyboard behavior
- Improved form integration behavior
- Improved field focus handling
- Improved selected item rendering
- Improved overlay stability
- Improved generic type safety

### Notes

- This package is inspired by and built upon:
  https://pub.dev/packages/multi_dropdown

- Redesigned specifically for:
  https://pub.dev/packages/flutter_form_builder

--- 

## 0.0.1

### Added

- Initial release

