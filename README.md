
**FormBuilderMultiDropdown** is a library that creates a Dropdown that allows the user to select one or more options from a dropdown menu. It complies with the **FormBuilder** library standards.

[https://pub.dev/packages/flutter_form_builder](https://pub.dev/packages/flutter_form_builder "https://pub.dev/packages/flutter_form_builder")

The source code of **FormBuilderMultiDropdown** is a modification of **multi_dropdown 3.0.1+**

[https://pub.dev/packages/multi_dropdown](https://pub.dev/packages/multi_dropdown "https://pub.dev/packages/multi_dropdown")

![](https://raw.githubusercontent.com/o7planning/form_builder_multi_dropdown/refs/heads/main/doc/images/image.png)

## Usage:

```dart
// <ID, ITEM> = <String, String>
FormBuilderMultiDropdown<String, String> (
  name: "language",
  items: ["Java", "Javascript", "Swift"],
  initialValue: ["Java", "Swift"],
  validator: FormBuilderValidators.compose(
    [
      FormBuilderValidators.required(),
    ],
  ),
  getItemId: (String item)  {
     return item;
  },
  getItemText: (String item)  {
     return item;
  }
)
```