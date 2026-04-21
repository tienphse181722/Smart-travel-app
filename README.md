# 🌍 Smart Travel App

Ứng dụng du lịch thông minh giúp lên kế hoạch, quản lý lịch trình và chi phí cho chuyến đi của bạn.

![Flutter](https://img.shields.io/badge/Flutter-3.11.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Tính năng

### 🎯 Phase 1-3: Quản lý chuyến đi cơ bản
- ✅ Tạo và quản lý chuyến đi
- ✅ Lên lịch trình theo ngày
- ✅ Thêm hoạt động (ăn uống, vui chơi)
- ✅ Tính toán chi phí
- ✅ Chia tiền nhóm
- ✅ Xem bản đồ và tìm địa điểm gần đây
- ✅ Tối ưu hóa lộ trình

### 🎫 Phase 4: Quản lý vé (MỚI!)
- ✅ **Thêm vé**: Lưu thông tin vé máy bay, tàu, xe, khách sạn
- ✅ **Upload ảnh vé**: Chụp hoặc chọn ảnh từ thư viện
- ✅ **Quản lý mã vé**: Lưu và sao chép mã booking
- ✅ **Liên kết lịch trình**: Gắn vé với hoạt động cụ thể
- ✅ **Link đặt vé**: Lưu và mở link booking trực tiếp
- ✅ **Xem chi tiết**: Hiển thị đầy đủ thông tin vé
- ✅ **Chỉnh sửa & xóa**: Quản lý vé dễ dàng

## 📱 Screenshots

_Coming soon..._

## 🚀 Bắt đầu

### Yêu cầu
- Flutter SDK 3.11.4 trở lên
- Dart 3.0 trở lên
- Android Studio / VS Code
- Git

### Cài đặt

1. **Clone repository**
```bash
git clone https://github.com/tienphse181722/Smart-travel-app.git
cd Smart-travel-app/smart_travel_app
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Chạy ứng dụng**
```bash
flutter run
```

### Build cho production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📦 Dependencies chính

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI & Navigation
  cupertino_icons: ^1.0.8
  
  # State Management & Data
  shared_preferences: ^2.2.2
  
  # Date & Time
  intl: ^0.19.0
  
  # Maps & Location
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  
  # Network
  http: ^1.2.0
  
  # Image & Media (Phase 4)
  image_picker: ^1.0.7
  path_provider: ^2.1.2
  url_launcher: ^6.2.4
  
  # Utilities
  uuid: ^4.5.1
```

## 🏗️ Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── trip.dart
│   ├── activity.dart
│   ├── ticket.dart          # Phase 4
│   ├── member.dart
│   ├── expense.dart
│   └── ...
├── screens/                  # UI Screens
│   ├── home_screen.dart
│   ├── trip_detail_screen.dart
│   ├── ticket_list_screen.dart      # Phase 4
│   ├── add_ticket_screen.dart       # Phase 4
│   ├── ticket_detail_screen.dart    # Phase 4
│   └── ...
├── services/                 # Business Logic
│   ├── ticket_service.dart          # Phase 4
│   ├── data_service.dart
│   ├── split_bill_service.dart
│   └── ...
├── widgets/                  # Reusable Widgets
│   ├── ticket_card.dart             # Phase 4
│   └── ...
└── utils/                    # Utilities
    ├── app_theme.dart
    └── logger.dart
```

## 📖 Tài liệu

- [Phase 4 - Ticket Management](PHASE4_TICKET_MANAGEMENT.md) - Tài liệu kỹ thuật
- [Usage Guide](USAGE_GUIDE.md) - Hướng dẫn sử dụng
- [Checklist](PHASE4_CHECKLIST.md) - Danh sách tính năng

## 🎯 Roadmap

### Phase 4 ✅ (Hoàn thành)
- [x] Quản lý vé
- [x] Upload ảnh vé
- [x] Liên kết với lịch trình
- [x] Link đặt vé

### Phase 5 (Kế hoạch)
- [ ] Quét QR code/barcode
- [ ] Nhắc nhở trước giờ khởi hành
- [ ] Xuất vé ra PDF
- [ ] Chia sẻ vé cho thành viên

### Phase 6 (Tương lai)
- [ ] Đồng bộ với Google Calendar
- [ ] Backup/restore dữ liệu
- [ ] Import vé từ email
- [ ] Dark mode
- [ ] Multi-language support

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📝 License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 👥 Tác giả

- **Tiến** - [tienphse181722](https://github.com/tienphse181722)

## 🙏 Cảm ơn

- [Flutter](https://flutter.dev/) - Framework tuyệt vời
- [OpenStreetMap](https://www.openstreetmap.org/) - Dữ liệu bản đồ
- [OSRM](http://project-osrm.org/) - Routing service
- Cộng đồng Flutter Việt Nam

## 📞 Liên hệ

- GitHub: [@tienphse181722](https://github.com/tienphse181722)
- Email: tienphse181722@fpt.edu.vn

---

⭐ Nếu bạn thấy dự án hữu ích, hãy cho một star nhé!
