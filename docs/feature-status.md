# Trạng thái chức năng — 21/10/2026

## Đã triển khai

- Đăng ký/đăng nhập email, đặt lại mật khẩu, chuyển cảnh chào mừng, đăng xuất ở Profile.
- Quyền user/doctor/admin từ server, thu hồi quyền và quy tắc Firestore.
- Tiếng Việt/English, lưu lựa chọn trên thiết bị.
- Trang chủ pastel, tiêu đề xanh đậm, nền xám; thanh điều hướng nổi và CTA đặt lịch.
- Hồ sơ thú cưng lưu Firebase: thêm/sửa/xóa, cân nặng, lịch vaccine/tẩy giun tự nhập.
- Tìm phòng khám, xem dịch vụ/giá/giờ mở cửa/liên hệ, mở đặt lịch theo phòng khám.
- Đặt lịch có xác nhận, giữ khung giờ trong transaction, chống đặt trùng và giả giá.
- Lịch sử cập nhật theo thời gian thực; hủy lịch trả lại khung giờ.
- Bác sĩ xem lịch được phân công, tiếp nhận và ghi kết quả sau giờ hẹn.
- Admin quản lý vai trò, phòng khám, dịch vụ, hồ sơ bác sĩ gắn UID và khung giờ.
- Profile: địa chỉ, chọn phòng khám yêu thích, bật/tắt nhắc lịch trong app, chi phí
  các lần khám hoàn tất, hướng dẫn/liên hệ và gửi email đặt lại mật khẩu.
- Firebase rules đã deploy vào project `vetconnect-149d7`.

Danh mục trống được hiển thị đúng trạng thái; không thêm dữ liệu phòng khám,
người dùng, ưu đãi hay bệnh án giả vào Firebase thật. Cần admin nhập danh mục thực
để người dùng đặt lịch. Chi phí khám là bảng theo dõi, không phải biên nhận thanh toán.

## Còn cần dịch vụ/cấu hình bên ngoài

1. **Thanh toán trực tuyến:** cần lựa chọn nhà cung cấp và tài khoản merchant,
   backend tạo giao dịch/xác thực webhook. Chưa có cổng thanh toán hay ví nội bộ.
2. **Thông báo đẩy:** hiện chỉ có nhắc lịch trong trang chủ. Cần FCM, quyền thiết bị,
   xử lý token và tác vụ server gửi thông báo để nhận khi app đã đóng.
3. **Google/Facebook:** Google native và popup web đã có mã tích hợp. Provider mặc
   định ẩn vì `google-services.json` hiện chưa có OAuth clients. Theo
   [hướng dẫn Firebase](https://firebase.google.com/docs/auth/flutter/federated-auth),
   bật Google trong Authentication, đăng ký SHA của khóa ký APK, tải lại cấu hình,
   rồi build với `--dart-define=GOOGLE_SIGN_IN_ENABLED=true`. Facebook popup chỉ
   hỗ trợ web khi bật `FACEBOOK_SIGN_IN_ENABLED`; Facebook native chưa tích hợp SDK
   và cần Meta App ID/cấu hình redirect. Không còn nút đăng nhập bấm nhưng không xử lý.

Không lưu khóa merchant, OAuth secret, keystore hoặc service-account vào repository.

## Kiểm tra

```powershell
flutter analyze --no-pub
flutter test --no-pub
cd tools/rules-tests
npm ci
npm test
```

Rules chạy bằng Firebase Emulator project `demo-vetconnect`; gồm chống nâng quyền,
phân quyền dữ liệu, sửa giá, hủy/hoàn tất, quyền bị thu hồi và hai transaction đặt
cùng khung giờ. Các bài test không tạo dữ liệu trong Firebase thật.
