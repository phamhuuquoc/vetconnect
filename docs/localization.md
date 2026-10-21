# Ngôn ngữ giao diện

App hỗ trợ Tiếng Việt (`vi`, mặc định) và English (`en`).

- Đổi tại **Profile → Ngôn ngữ**, áp dụng cho người dùng, bác sĩ và admin.
- Màn đăng nhập có nút **VI/EN** nhỏ để đổi trước khi đăng nhập.
- Lựa chọn được lưu trên thiết bị bằng SharedPreferences, giữ lại khi mở app
  hoặc đăng xuất. Không thay đổi tài khoản, vai trò, tên thú cưng hay ghi chú.
- Flutter Material/Cupertino widgets dùng `flutter_localizations` và locale của
  MaterialApp, gồm các nhãn hệ thống và trợ năng.

Các bản dịch nằm tại `lib/l10n/translations.dart`. `AppText` phụ thuộc vào
Localizations nên cả nhãn `const` và các route đã mở đều cập nhật ngay.
`AppTextField` và `AppTextFormField` dịch nhãn/hint/thông báo kiểm tra mà giữ
nguyên controller và giá trị nhập. Dữ liệu định danh và nội dung người dùng nhập
dùng `Text` trực tiếp, không đưa qua danh mục dịch. Giá vẫn dùng VND; không có
chuyển đổi tiền tệ. Nội dung bệnh án hoặc ghi chú không được dịch tự động.

Thêm ngôn ngữ mới cần bổ sung danh mục và hàm `translateFor`, `LocaleController.supportedLocales`,
menu chọn ngôn ngữ và kiểm thử. Không thêm ngôn ngữ vào menu khi chưa có bản dịch.

```powershell
flutter test --no-pub
```

Kiểm thử gồm lưu/khôi phục lựa chọn, đổi hai chiều, giữ nguyên nội dung ô nhập,
menu trong Profile cho ba vai trò và nội dung thông báo có biến.
