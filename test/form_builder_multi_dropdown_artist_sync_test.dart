import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_multi_dropdown/form_builder_multi_dropdown.dart';

// 1. Định nghĩa một Model giả lập cấu trúc dữ liệu thực tế của FlutterArtist
class ContributorInfo {
  final int id;
  final String name;

  const ContributorInfo({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributorInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

void main() {
  group('FormBuilderMultiDropdown - FlutterArtist Synchronization Regression Suite', () {
    final List<ContributorInfo> totalContributors = const [
      ContributorInfo(id: 1, name: 'Contributor 1'),
      ContributorInfo(id: 2, name: 'Contributor 2'),
      ContributorInfo(id: 3, name: 'Contributor 3'),
    ];

    // Helper đóng gói Widget kiểm thử tự động thay đổi trạng thái từ lớp cha
    Widget buildArtistFormFramework({
      required GlobalKey<FormBuilderState> formKey,
      required List<ContributorInfo> activeSelection,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: FormBuilder(
            key: formKey,
            initialValue: {'contributors': activeSelection},
            child: FormBuilderMultiDropdown<ContributorInfo>(
              name: 'contributors',
              items: totalContributors, // Kho 10 items gốc không đổi
              getItemText: (item) => item.name,
            ),
          ),
        ),
      );
    }

    testWidgets(
      'MÔ PHỎNG FLUTTER_ARTIST: Chuyển đổi Task phải cập nhật hiển thị lập tức (Không đơ UI)',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormBuilderState>();

        await tester.pumpWidget(
          buildArtistFormFramework(
            formKey: formKey,
            activeSelection: [totalContributors[0]], // [Contributor 1]
          ),
        );
        await tester.pumpAndSettle();

        // Xác thực ban đầu hiển thị đúng Contributor 1
        final state = tester.state<FormFieldState<List<ContributorInfo>>>(
          find.byType(FormBuilderMultiDropdown<ContributorInfo>),
        );
        expect(state.value, equals([totalContributors[0]]));

        // KỊCH BẢN 2: Người dùng tương tác bằng tay (Thêm Contributor 2)
        // Giả lập luồng didChange giống hệt như khi người dùng mở overlay và chọn bằng tay
        state.didChange([totalContributors[0], totalContributors[1]]);
        await tester.pumpAndSettle();
        expect(
          state.value,
          equals([totalContributors[0], totalContributors[1]]),
        );

        // KỊCH BẢN 3: Ông giáo click chuyển sang Task 2 trên Sidebar của FlutterArtist
        // Hệ thống FormModel ép cập nhật lại initialValue mới từ bên ngoài xuống (Task 2 chỉ có Contributor 3)
        await tester.pumpWidget(
          buildArtistFormFramework(
            formKey: formKey,
            activeSelection: [totalContributors[2]], // Ép về [Contributor 3]
          ),
        );

        // ĐỂ Ý: Lần này chúng ta KHÔNG dùng pumpAndSettle lùi frame bất đồng bộ,
        // mà ép render đồng thì để kiểm tra tính Synchronous Mutation
        await tester.pump();

        // KHẢO SÁT: Controller và FormFieldState PHẢI phục tùng giá trị mới của lớp cha lập tức,
        // xóa sạch vết tích tương tác bằng tay trước đó mà không bị khóa cứng (đơ).
        expect(state.value, equals([totalContributors[2]]));

        // Đảm bảo không có chip cũ nào sót lại trên màn hình hiển thị
        expect(find.text('Contributor 1'), findsNothing);
        expect(find.text('Contributor 3'), findsOneWidget);
      },
    );

    testWidgets(
      'MÔ PHỎNG FLUTTER_ARTIST NÂNG CAO 1: Hàm resetForm() của Task hiện tại phải khôi phục đúng cấu hình của chính Task đó',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormBuilderState>();

        // 1. Đang ở Task 2 (Có sẵn Contributor 2)
        await tester.pumpWidget(
          buildArtistFormFramework(
            formKey: formKey,
            activeSelection: [totalContributors[1]], // [Contributor 2]
          ),
        );
        await tester.pumpAndSettle();

        final state = tester.state<FormFieldState<List<ContributorInfo>>>(
          find.byType(FormBuilderMultiDropdown<ContributorInfo>),
        );

        // 2. Người dùng dùng tay phá vỡ cấu trúc (Xóa sạch, chọn Contributor 3)
        state.didChange([totalContributors[2]]);
        await tester.pumpAndSettle();
        expect(state.value, equals([totalContributors[2]]));

        // 3. Gọi hàm phục hồi reset() của FormBuilder (Mô phỏng block.formModel!.resetForm())
        formKey.currentState?.reset();
        await tester.pump(); // Ép render đồng thì

        // KHẢO SÁT: Trạng thái hiển thị bắt buộc phải quay về cấu hình gốc ban đầu của Task 2 (Contributor 2)
        expect(state.value, equals([totalContributors[1]]));
        expect(find.text('Contributor 2'), findsOneWidget);
        expect(find.text('Contributor 3'), findsNothing);
      },
    );

    testWidgets(
      'MÔ PHỎNG FLUTTER_ARTIST NÂNG CAO 2: Đổi Task đồng thời kho Items nền thay đổi số lượng (Chặn đứng lỗi Option Not Found)',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormBuilderState>();

        // Task 1: Có đầy đủ cả 3 Contributors trong kho items nền
        await tester.pumpWidget(
          buildArtistFormFramework(
            formKey: formKey,
            activeSelection: [totalContributors[0]], // Chọn Contributor 1
          ),
        );
        await tester.pumpAndSettle();

        final state = tester.state<FormFieldState<List<ContributorInfo>>>(
          find.byType(FormBuilderMultiDropdown<ContributorInfo>),
        );

        // Mô phỏng kịch bản ngặt nghèo: Chuyển sang Task mới, lúc này phân quyền hoặc API trả về
        // làm kho Items nền của widget bị co hẹp lại (Chỉ còn đúng Contributor 3)
        final List<ContributorInfo> shrinkedContributors = [
          totalContributors[2],
        ]; // Chỉ còn mẫu số 3

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FormBuilder(
                key: formKey,
                initialValue: {
                  'contributors': [
                    totalContributors[2],
                  ], // Task mới chọn Contributor 3
                },
                child: FormBuilderMultiDropdown<ContributorInfo>(
                  name: 'contributors',
                  items:
                      shrinkedContributors, // Kho items nền bị co hẹp đồng thời
                  getItemText: (item) => item.name,
                ),
              ),
            ),
          ),
        );
        await tester.pump(); // Render đồng thì

        // KHẢO SÁT: Hệ thống deep-check _sameItems phải nhận diện kho mới mượt mà,
        // gán chính xác Contributor 3 mà không quăng lỗi crash hay đẩy giá trị về null.
        expect(state.value, equals([totalContributors[2]]));
        expect(find.text('Contributor 3'), findsOneWidget);
        expect(find.text('Contributor 1'), findsNothing);
      },
    );

    testWidgets(
      'MÔ PHỎNG FLUTTER_ARTIST NÂNG CAO 3: Tránh Race Condition khi người dùng click đổi Task liên tục với tốc độ cao',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormBuilderState>();

        // Bước 1: Click Task 1 (Chọn Contributor 1)
        await tester.pumpWidget(
          buildArtistFormFramework(
            formKey: formKey,
            activeSelection: [totalContributors[0]],
          ),
        );

        // Bước 2: Click cực nhanh sang Task 2 khi frame cũ chưa kịp settling (Chọn Contributor 2)
        await tester.pumpWidget(
          buildArtistFormFramework(
            formKey: formKey,
            activeSelection: [totalContributors[1]],
          ),
        );

        // Bước 3: Click tiếp tắp lự sang Task 3 (Chọn Contributor 3)
        await tester.pumpWidget(
          buildArtistFormFramework(
            formKey: formKey,
            activeSelection: [totalContributors[2]],
          ),
        );

        // Lúc này mới cho phép frame ổn định hoàn toàn
        await tester.pump();

        final state = tester.state<FormFieldState<List<ContributorInfo>>>(
          find.byType(FormBuilderMultiDropdown<ContributorInfo>),
        );

        // KHẢO SÁT: Cơ chế Synchronous Mutation phải đảm bảo giá trị cuối cùng thuộc về Task 3,
        // không bị hiện tượng chồng chéo bộ đệm (stale state) làm sai lệch dữ liệu hiển thị.
        expect(state.value, equals([totalContributors[2]]));
        expect(find.text('Contributor 3'), findsOneWidget);
        expect(find.text('Contributor 2'), findsNothing);
        expect(find.text('Contributor 1'), findsNothing);
      },
    );
  });
}
