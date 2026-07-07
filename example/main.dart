import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_multi_dropdown/form_builder_multi_dropdown.dart';

void main() {
  runApp(const MyApp());
}

/// A standard MaterialApp entry point setup to run the declarative example suite.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormBuilder Multi Dropdown Workspace',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ExamplePage(),
    );
  }
}

/// A representation entity class mapping custom programming languages models.
class ProgrammingLanguage {
  final int id;
  final String name;
  final String creator;

  const ProgrammingLanguage({
    required this.id,
    required this.name,
    required this.creator,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgrammingLanguage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// The centralized showcase dashboard layout evaluating the dropdown field workflows.
class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _formKey = GlobalKey<FormBuilderState>();

  /// Mock static inventory data mapping language entities directly from the specifications.
  final List<ProgrammingLanguage> _languages = const [
    ProgrammingLanguage(id: 1, name: 'Dart', creator: 'Google'),
    ProgrammingLanguage(id: 2, name: 'Kotlin', creator: 'JetBrains'),
    ProgrammingLanguage(id: 3, name: 'Swift', creator: 'Apple'),
    ProgrammingLanguage(id: 4, name: 'TypeScript', creator: 'Microsoft'),
  ];

  late List<ProgrammingLanguage> _selectedMultiLanguages;
  late List<ProgrammingLanguage> _selectedSingleLanguage;

  @override
  void initState() {
    super.initState();
    _selectedMultiLanguages = [_languages.first];
    _selectedSingleLanguage = [];
  }

  void _triggerExternalUpdate() {
    setState(() {
      _selectedMultiLanguages = [
        _languages[1], // Kotlin
        _languages[3], // TypeScript
      ];

      // Đổi trạng thái Single-select: Chọn Swift
      _selectedSingleLanguage = [
        _languages[2], // Swift
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('External mutations pushed! Fields synced sequentially.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _handleFormReset() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedMultiLanguages = [_languages.first];
      _selectedSingleLanguage = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormBuilderMultiDropdown Pro Suite'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Stateless Unidirectional Form Field Verification Engine',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// ─── WORKSPACE TRACK 1: MULTI SELECT MODE WITH CHIPS ───
              FormBuilderMultiDropdown<ProgrammingLanguage>(
                name: 'languages_multi',
                items: _languages,
                searchEnabled: true,
                singleSelect: false,
                getItemText: (item) => item.name,
                initialValue: _selectedMultiLanguages,
                fieldDecoration: const FieldDecoration(
                  labelText: 'Primary Preferred Languages (Multi Select)',
                  hintText: 'Tap to select multiple tech stacks',
                ),
                chipDecoration: ChipDecoration(
                  backgroundColor: Colors.indigo.withAlpha(25),
                  labelStyle: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w500,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                dropdownDecoration: const DropdownDecoration(
                  maxHeight: 250,
                  noItemsFoundText: 'No matching stacks configured',
                ),
              ),
              const SizedBox(height: 24),

              /// ─── WORKSPACE TRACK 2: SINGLE SELECT MINIMALIST MODE ───
              FormBuilderMultiDropdown<ProgrammingLanguage>(
                name: 'language_single',
                items: _languages,
                searchEnabled: false,
                singleSelect: true,
                getItemText: (item) => item.name,
                initialValue: _selectedSingleLanguage,
                fieldDecoration: const FieldDecoration(
                  labelText: 'Deployment Framework Core (Single Select)',
                  hintText: 'Choose one target runtime platform',
                ),
                dropdownDecoration: const DropdownDecoration(maxHeight: 200),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _triggerExternalUpdate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: Colors.blueAccent,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        'Force External Update',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleFormReset,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.restore_rounded,
                        color: Colors.red.shade400,
                      ),
                      label: Text(
                        'Reset Standard Layout',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// ─── SUBMISSION BOUNDARY CONTROL INTERACTION HUGS ───
              ElevatedButton.icon(
                onPressed: _handleSubmitState,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: const Text(
                  'Validate & Submit Payload',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Extracts form data fields securely, validating requirements downstream safely.
  void _handleSubmitState() {
    final bool isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (isValid) {
      final Map<String, dynamic>? formPayload = _formKey.currentState?.value;

      debugPrint('Parsed Form Data Map Payload: $formPayload');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Form payload state validated and locked successfully!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
