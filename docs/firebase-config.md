# Cấu hình Firebase ngoài Git

Các file cấu hình thật được giữ trên máy lập trình và bị `.gitignore` loại khỏi
commit. Repo chỉ lưu file mẫu:

| File dùng khi build — không commit | File mẫu — được commit |
| --- | --- |
| `lib/firebase_options.dart` | `lib/firebase_options.example.dart` |
| `android/app/google-services.json` | `android/app/google-services.example.json` |

`GoogleService-Info.plist` trong `ios/Runner` và `macos/Runner` cũng không được
commit. `firebase.json` và `firestore.rules` vẫn được theo dõi vì chứa cấu hình
deploy/emulator và quy tắc bảo vệ dữ liệu, không phải khóa truy cập bí mật.

## Máy hiện tại

File thật vẫn nằm đúng vị trí, không bị xóa hoặc thay giá trị. Cách khởi chạy và
build không đổi. Không dùng `git add -f` cho các file cấu hình đã được ignore.

## Máy mới

Cách khuyến nghị là đăng nhập Firebase CLI và chạy FlutterFire CLI bằng tài khoản
có quyền với project:

```powershell
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=<PROJECT_ID> --platforms=android --out=lib/firebase_options.dart
```

Đảm bảo có `android/app/google-services.json` của đúng ứng dụng Android; tải từ
Firebase Console → Project settings → Your apps nếu chưa được tạo. Package name
phải khớp `applicationId` trong `android/app/build.gradle`. Nếu build nền tảng khác,
chọn thêm nền tảng đó trong FlutterFire configure và lấy file native tương ứng.

Tham khảo [hướng dẫn thiết lập Flutter chính thức của Firebase](https://firebase.google.com/docs/flutter/setup).

Cũng có thể sao chép cấu hình từ máy tin cậy qua kênh riêng. File `.example` chỉ
mô tả cấu trúc; không thể kết nối Firebase bằng các giá trị `REPLACE_WITH_*`.
Không ghi đè file thật trên máy đang hoạt động bằng file mẫu.

Sau `flutterfire configure`, kiểm tra `git diff` vì công cụ có thể cập nhật
metadata trong `firebase.json` hoặc file native khác; không commit khóa hay file
cấu hình thật. Các mẫu không cần thay đổi khi xoay khóa.

## CI / GitHub Actions

Lưu toàn bộ nội dung hai file thật vào hai GitHub Actions repository secrets:
`FIREBASE_OPTIONS_DART` và `GOOGLE_SERVICES_JSON`. Khôi phục file sau checkout,
trước `flutter analyze`, `flutter test` hoặc build. Ví dụ cho runner Linux:

```yaml
- name: Restore Firebase client configuration
  env:
    FIREBASE_OPTIONS_DART: ${{ secrets.FIREBASE_OPTIONS_DART }}
    GOOGLE_SERVICES_JSON: ${{ secrets.GOOGLE_SERVICES_JSON }}
  shell: bash
  run: |
    test -n "$FIREBASE_OPTIONS_DART"
    test -n "$GOOGLE_SERVICES_JSON"
    mkdir -p lib android/app
    printf '%s' "$FIREBASE_OPTIONS_DART" > lib/firebase_options.dart
    printf '%s' "$GOOGLE_SERVICES_JSON" > android/app/google-services.json
```

Không in nội dung ra log hoặc đưa các file khôi phục vào artifact. Secrets không
được cấp cho pull request từ fork; job build đó cần bỏ qua hoặc dùng project test
riêng có cấu hình phù hợp. Chưa tạo workflow hay tải cấu hình lên GitHub Secrets
tự động trong thay đổi này.

## Khóa đã có trong lịch sử

Bỏ theo dõi file chỉ loại cấu hình khỏi commit mới. Các commit cũ vẫn chứa khóa,
nên GitHub có thể tiếp tục cảnh báo. Thay đổi này không rewrite lịch sử hoặc
thu hồi khóa đang được APK sử dụng. Nếu cần xử lý khóa cũ, thay khóa và kiểm thử
app trước khi thu hồi; xử lý lịch sử Git là một thao tác riêng.

Tách cấu hình giúp tránh commit lại; không làm khóa biến mất khỏi APK. Tiếp tục
giới hạn API key và bảo vệ dữ liệu bằng Firebase Security Rules/App Check.
