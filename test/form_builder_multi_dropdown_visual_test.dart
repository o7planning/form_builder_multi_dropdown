import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_multi_dropdown/form_builder_multi_dropdown.dart';

void main() {
  group('FormBuilderMultiDropdown Visual & Overlay Integrity Tests', () {
    final List<String> dummyItems = ['Alpha', 'Beta', 'Gamma', 'Delta'];

    Widget buildTestWidget(Widget child) {
      return MaterialApp(home: Scaffold(body: FormBuilder(child: child)));
    }

    testWidgets('1. Verification of Layout Items Rendering inside Overlay Portal', (
      WidgetTester tester,
    ) async {
      // Khởi tạo widget với cấu hình cơ bản, bật tính năng tìm kiếm để kiểm tra kết cấu dropdown
      await tester.pumpWidget(
        buildTestWidget(
          FormBuilderMultiDropdown<String>(
            name: 'test_dropdown',
            items: dummyItems,
            searchEnabled: true,
            getItemText: (item) => item,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Kiểm tra xem Field chính có render Text đầu vào hoặc label không
      expect(find.byType(InputDecorator), findsOneWidget);

      // Kích hoạt hành động tap vào InkWell để mở OverlayPortal hiển thị danh sách
      await tester.tap(find.bySemanticsLabel('Dropdown field'));
      await tester.pumpAndSettle();

      // Kiểm tra xem ListView trong overlay có được hiển thị hay không
      // Nếu lỗi "không hiển thị gì cả" xảy ra, ListView.separated hoặc các text item sẽ không tìm thấy
      expect(find.byType(ListView), findsOneWidget);

      // Xác thực xem các text item của danh sách dữ liệu gốc có xuất hiện trên màn hình overlay hay không
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('2. Search Interaction Filter Mutation Test', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          FormBuilderMultiDropdown<String>(
            name: 'test_dropdown',
            items: dummyItems,
            searchEnabled: true,
            getItemText: (item) => item,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mở menu dropdown overlay
      await tester.tap(find.bySemanticsLabel('Dropdown field'));
      await tester.pumpAndSettle();

      // Tìm kiếm khung TextField nhập liệu của bộ lọc Search
      final searchFieldFinder = find.byType(TextField);
      expect(searchFieldFinder, findsOneWidget);

      // Giả lập hành vi gõ chữ 'G' để lọc ra từ 'Gamma'
      await tester.enterText(searchFieldFinder, 'G');
      await tester.pumpAndSettle();

      // Sau khi lọc, item 'Gamma' phải giữ lại, còn item 'Alpha' phải biến mất khỏi danh sách hiển thị
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
    });
  });

  testWidgets('3. Manual Item Tap Interaction Mutation Test', (
    WidgetTester tester,
  ) async {
    final List<String> fruits = ['Apple', 'Banana'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormBuilder(
            child: FormBuilderMultiDropdown<String>(
              name: 'fruits_select',
              items: fruits,
              initialValue: const ['Apple'], // Ban đầu chọn Apple
              getItemText: (item) => item,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Xác thực ban đầu Form nắm giữ 'Apple' chuẩn chỉnh
    final state = tester.state<FormFieldState<List<String>>>(
      find.byType(FormBuilderMultiDropdown<String>),
    );
    expect(state.value, equals(['Apple']));

    // 2. Mở overlay bằng cách tap vào field
    await tester.tap(find.bySemanticsLabel('Dropdown field'));
    await tester.pumpAndSettle();

    // 3. Tìm item 'Banana' trên danh sách hiển thị và tap chọn nó bằng tay
    final bananaTileFinder = find.text('Banana');
    expect(bananaTileFinder, findsOneWidget);
    await tester.tap(bananaTileFinder);
    await tester.pumpAndSettle();

    // 4. KIỂM TRA ĐỘT PHÁ: Giá trị của Form bây giờ phải cập nhật thêm 'Banana' thành công mà không bị đơ
    expect(state.value, equals(['Apple', 'Banana']));
  });
}
