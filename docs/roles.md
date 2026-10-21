# Phân quyền tài khoản

Vai trò được lưu tại `users/{Firebase Auth UID}` trong Cloud Firestore.

| Vai trò | Khu vực trong app | Quyền dữ liệu tài khoản |
| --- | --- | --- |
| `user` | Home, tìm kiếm, đặt lịch, lịch sử, hồ sơ và cài đặt | Quản lý thú cưng/cài đặt của mình; đặt và hủy lịch chưa diễn ra |
| `doctor` | Lịch khám được phân công | Xem thông tin thú cưng trong lịch được giao; xác nhận, hủy và ghi kết quả |
| `admin` | Tài khoản, danh mục, lịch khám | Đổi vai trò tài khoản khác; quản lý phòng khám, dịch vụ, bác sĩ, khung giờ và lịch khám |

Lịch khám được lưu tại `appointments/{id}` với `ownerId` và `doctorUid`.
Người dùng chỉ truy vấn lịch của mình; bác sĩ chỉ truy vấn lịch được phân công.
Giá, tên dịch vụ và thông tin thú cưng tại thời điểm đặt được giữ trong lịch.
Kết quả khám đã hoàn tất không thể sửa bằng client. Chủ nuôi không được ghi
kết quả này; lịch chăm sóc trong hồ sơ thú cưng là thông tin chủ nuôi tự nhập.

## Kích hoạt trên Firebase

1. Trong Firebase project `vetconnect-149d7`, bật Email/Password ở Authentication
   và tạo Cloud Firestore database `(default)` nếu chưa có.
2. Rà soát và triển khai `firestore.rules`. Từ thư mục gốc repo, dùng Firebase CLI
   đã đăng nhập tài khoản có quyền quản lý project:

   ```powershell
   firebase deploy --only firestore:rules --project vetconnect-149d7
   ```

   Có thể dán nội dung `firestore.rules` vào tab Rules của Cloud Firestore và
   Publish nếu không dùng CLI. Rules bảo vệ tài khoản, thú cưng, cài đặt,
   danh mục và lịch khám theo quyền sở hữu/phân công.
3. Đăng ký hoặc đăng nhập một tài khoản. App tự tạo hồ sơ `users/{uid}` với
   `role: "user"`, `email`, `createdAt` và `updatedAt`. Tài khoản cũ chưa có hồ sơ
   cũng được khởi tạo như vậy. Vai trò đã có không bị ghi đè khi đăng nhập.
4. Chủ project vào Firebase Console, sửa trường `role` của **đúng UID** thành
   `admin` để tạo admin đầu tiên. Không tạo chức năng tự nhận quyền admin trong
   app và không dùng email cố định để suy ra vai trò.
5. Admin vào app để đổi vai trò người dùng khác thành `doctor`, `admin` hoặc
   `user`. App yêu cầu xác nhận và không cho admin đổi vai trò của chính mình.

Rules đã được triển khai cho `vetconnect-149d7` ngày 21/10/2026. Build/test
không tự triển khai rules hoặc tạo admin. Admin đầu tiên vẫn do chủ project
cấp cho một tài khoản thật; không có tài khoản/mật khẩu admin mặc định.

## Chuẩn bị danh mục và đặt lịch

1. Admin cấp vai trò `doctor` cho tài khoản bác sĩ đã đăng ký.
2. Tab **Dịch vụ và lịch**: tạo phòng khám, dịch vụ (giá VND, thời lượng), hồ sơ
   bác sĩ gắn với tài khoản trên, rồi tạo khung giờ trong tương lai.
3. Người dùng tạo hồ sơ thú cưng, chọn phòng khám/dịch vụ/khung giờ và gửi yêu cầu.
   Giao dịch ghi lịch `pending` và giữ khung giờ `reserved` cùng lúc. Rules kiểm
   tra giá/danh tính/thông tin từ server và từ chối đặt trùng.
4. Bác sĩ tiếp nhận (`confirmed`), đến giờ khám có thể hoàn tất với kết quả
   (`completed`). Chủ nuôi thấy kết quả trong Lịch sử. Hủy (`cancelled`) trả
   khung giờ về `available` trong cùng giao dịch.

Các lịch cũ tại `users/{uid}/appointments` vẫn được đọc để giữ tương thích,
không tự di chuyển hoặc ghi đè. Thao tác nghiệp vụ áp dụng cho lịch mới ở
collection chung. Khung giờ cũ cần được admin chỉnh sửa để bổ sung
`startsAtTime` (Firestore Timestamp); `startsAt` vẫn là chuỗi ISO UTC để hiển thị.

## Kiểm soát truy cập

- Không đăng nhập: chỉ có các màn hình xác thực.
- Tài khoản mới chỉ tự tạo được hồ sơ `user`; rules từ chối tự cấp quyền bằng
  request trực tiếp, ghi thêm trường hoặc tạo hồ sơ cho UID khác.
- Admin chỉ đổi `role` và `updatedAt`, không sửa danh tính hay xóa tài khoản.
- App theo dõi vai trò từ server. Quyền bị thu hồi sẽ thay toàn bộ stack màn
  hình của phiên hiện tại; rules kiểm tra vai trò hiện hành cho từng request.
- Không dùng vai trò từ cache hoặc ghi local chưa được server xác nhận để mở
  giao diện có quyền. Mất kết nối lúc xác minh sẽ chặn truy cập và hiện thông báo.
- Lỗi đọc hồ sơ hoặc vai trò lạ không được mặc định thành bác sĩ/admin.
- Hồ sơ thú cưng được lưu tại `users/{uid}/pets`, cài đặt tại
  `users/{uid}/settings/preferences`. Giao diện đồng bộ qua snapshot; cache phiên
  được xóa khi đăng xuất/đổi tài khoản. Chỉ báo lưu thành công sau khi server xác nhận.

Thiết kế dùng vai trò trong tài liệu và kiểm tra tại Firestore theo hướng dẫn
[role-based access của Firebase](https://firebase.google.com/docs/firestore/solutions/role-based-access).

## Kiểm thử

```powershell
flutter test --no-pub
cd tools/rules-tests
npm ci
$env:JAVA_HOME='D:\jdk17'
npm test
```

Bộ test rules chạy trên emulator với project `demo-vetconnect`, không kết nối
database sản xuất. Dùng Node và JDK phù hợp với Firebase CLI trong package lock.

Nếu `flutter pub get` báo thiếu symlink trên Windows khi chỉ build Android, có
thể bỏ tạo plugin desktop trong tiến trình hiện tại, không đổi cấu hình toàn máy:

```powershell
$env:FLUTTER_WINDOWS='false'
$env:FLUTTER_LINUX='false'
flutter pub get
flutter build apk --release --no-pub
```

Muốn build desktop thì bật Windows Developer Mode theo hướng dẫn của Flutter.
