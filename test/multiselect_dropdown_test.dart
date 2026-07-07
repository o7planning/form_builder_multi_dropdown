import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_multi_dropdown/form_builder_multi_dropdown.dart';

void main() {
  group('FormBuilderMultiDropdown Regression & Update Tests', () {
    const itemsSource = ['Apple', 'Banana', 'Cherry', 'Date'];

    Widget buildTestFramework({required Widget child}) {
      return MaterialApp(home: Scaffold(body: FormBuilder(child: child)));
    }

    testWidgets('Should initialize correctly with initialValue', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestFramework(
          child: FormBuilderMultiDropdown<String>(
            name: 'fruits',
            items: itemsSource,
            initialValue: const ['Banana', 'Cherry'],
            getItemText: (item) => item,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final state = tester.state<FormFieldState<List<String>>>(
        find.byType(FormBuilderMultiDropdown<String>),
      );

      expect(state.value, equals(['Banana', 'Cherry']));
    });

    testWidgets(
      'Should update internal selection states dynamically when parent configuration changes',
      (WidgetTester tester) async {
        // 1. Render with initial values
        await tester.pumpWidget(
          buildTestFramework(
            child: FormBuilderMultiDropdown<String>(
              name: 'fruits',
              items: itemsSource,
              initialValue: const ['Apple'],
              getItemText: (item) => item,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 2. Re-pump with updated initialValue from parent widget
        await tester.pumpWidget(
          buildTestFramework(
            child: FormBuilderMultiDropdown<String>(
              name: 'fruits',
              items: itemsSource,
              initialValue: const ['Cherry', 'Date'],
              getItemText: (item) => item,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 3. Verify internal FormField value updated correctly
        final dynamic state = tester.state(
          find.byType(FormBuilderMultiDropdown<String>),
        );
        expect(state.value, equals(['Cherry', 'Date']));
      },
    );

    testWidgets(
      'Should reset to initial layout configuration when form standard reset is triggered',
      (WidgetTester tester) async {
        final GlobalKey<FormBuilderState> formKey =
            GlobalKey<FormBuilderState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FormBuilder(
                key: formKey,
                child: FormBuilderMultiDropdown<String>(
                  name: 'fruits',
                  items: itemsSource,
                  initialValue: const ['Apple'],
                  getItemText: (item) => item,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final dynamic state = tester.state(
          find.byType(FormBuilderMultiDropdown<String>),
        );

        // Simulate programmatic selection mutation
        state.didChange(['Banana']);
        expect(state.value, equals(['Banana']));

        // Execute standard reset sequence
        formKey.currentState?.reset();
        await tester.pumpAndSettle();

        expect(state.value, equals(['Apple']));
      },
    );

    testWidgets(
      'TƯƠNG TÁC CHIP: Bấm nút close trên Chip phải xóa được item ra khỏi danh sách lựa chọn',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FormBuilder(
                child: FormBuilderMultiDropdown<String>(
                  name: 'fruits',
                  items: const ['Apple', 'Banana', 'Cherry'],
                  initialValue: const ['Apple', 'Banana'], // Chọn sẵn 2 item
                  getItemText: (item) => item,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Xác thực ban đầu Form thu thập được cả 2 quả
        final state = tester.state<FormFieldState<List<String>>>(
          find.byType(FormBuilderMultiDropdown<String>),
        );
        expect(state.value, equals(['Apple', 'Banana']));

        // 2. Nhắm chuẩn xác vào nút close của riêng Chip 'Apple'
        final appleDeleteButton = find.descendant(
          of: find.ancestor(
            of: find.text('Apple'),
            matching: find.byType(Chip),
          ),
          matching: find.byIcon(Icons.cancel),
        );

        // 3. Thực hiện hành động tap xóa
        await tester.tap(appleDeleteButton);
        await tester.pumpAndSettle();

        // KHẢO SÁT: Quả 'Apple' phải biến mất, Form chỉ còn lại giữ duy nhất quả 'Banana'
        expect(state.value, equals(['Banana']));
        expect(find.text('Apple'), findsNothing);
        expect(find.text('Banana'), findsOneWidget);
      },
    );
  });
}
