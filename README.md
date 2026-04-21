# 🌍 Smart Travel App

<div align="center">

![Smart Travel Logo](assets/images/app_logo.png)

**Ứng dụng quản lý chuyến du lịch thông minh**

[![Flutter](https://img.shields.io/badge/Flutter-3.11.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.4-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Tính năng](#-tính-năng) • [Cài đặt](#-cài-đặt) • [Sử dụng](#-sử-dụng) • [Kiến trúc](#-kiến-trúc) • [Đóng góp](#-đóng-góp)

</div>

---

## 📖 Giới thiệu

**Smart Travel App** là ứng dụng di động toàn diện giúp bạn lập kế hoạch, quản lý và tối ưu hóa chuyến du lịch của mình. Với giao diện thân thiện và các tính năng thông minh, Smart Travel là người bạn đồng hành lý tưởng cho mọi chuyến đi.

### 🎯 Mục tiêu

- ✅ Đơn giản hóa việc lập kế hoạch du lịch
- ✅ Tối ưu hóa lộ trình di chuyển
- ✅ Quản lý chi tiêu nhóm minh bạch
- ✅ Lưu trữ và quản lý vé điện tử
- ✅ Khám phá địa điểm xung quanh

---

## ✨ Tính năng

### 1. 📅 Quản lý lịch trình (Itinerary Management)

<details>
<summary><b>Xem chi tiết</b></summary>

#### Tạo chuyến đi
- Nhập điểm đến
- Chọn số ngày
- Chọn ngày bắt đầu
- Tự động tạo lịch trình theo ngày

#### Thêm hoạt động
- Nhập tên hoạt động
- Chọn địa điểm trên bản đồ
- Đặt thời gian bắt đầu/kết thúc
- Nhập chi phí dự kiến
- Thêm ghi chú

#### Chỉnh sửa & Xóa
- Sửa thông tin hoạt động
- Xóa hoạt động
- Sắp xếp lại thứ tự
- Tính tổng chi phí tự động

</details>

### 2. 🗺️ Tối ưu hóa tuyến đường (Route Optimization)

<details>
<summary><b>Xem chi tiết</b></summary>

#### Thuật toán thông minh
- **Greedy Nearest Neighbor Algorithm**
- Tối ưu thứ tự các điểm tham quan
- Giảm thiểu quãng đường di chuyển
- Tiết kiệm thời gian và chi phí

#### Hiển thị bản đồ
- Bản đồ tương tác với OpenStreetMap
- Markers cho từng địa điểm
- Vẽ routes giữa các điểm
- Tính khoảng cách và thời gian
- Zoom và pan mượt mà

#### OSRM Integration
- Routing API từ OSRM
- Tính toán route thực tế
- Cache để tăng tốc độ
- Hỗ trợ offline (cached routes)

</details>

### 3. 🔍 Tìm kiếm địa điểm (Place Discovery)

<details>
<summary><b>Xem chi tiết</b></summary>

#### Tìm kiếm thông minh
- Search bar với debouncing
- Tìm theo tên địa điểm
- Tìm theo loại (ăn uống, tham quan, mua sắm)
- Gợi ý địa điểm phổ biến

#### Địa điểm xung quanh
- Hiển thị địa điểm gần vị trí hiện tại
- Lọc theo khoảng cách
- Xem thông tin chi tiết
- Thêm trực tiếp vào lịch trình

#### Database địa điểm
- 100+ địa điểm du lịch Việt Nam
- 50+ nhà hàng và quán ăn
- Thông tin đầy đủ (tọa độ, mô tả, giá)
- Cập nhật liên tục

</details>

### 4. 🎫 Quản lý vé (Ticket Management)

<details>
<summary><b>Xem chi tiết</b></summary>

#### Loại vé hỗ trợ
- 🚌 **Xe khách** (Bus)
- 🚂 **Tàu hỏa** (Train)
- ✈️ **Máy bay** (Flight)
- 🏨 **Khách sạn** (Hotel)

#### Tính năng
- Thêm vé thủ công
- Upload ảnh vé
- Lưu thông tin: mã vé, giờ, điểm đi/đến
- Trạng thái: Chưa đặt / Đã đặt / Đã sử dụng
- Liên kết với hoạt động trong lịch trình
- Lọc theo loại vé
- Xem chi tiết vé

#### Gợi ý đặt vé
- Link đến Vexere (xe khách)
- Link đến VNR (tàu hỏa)
- Link đến Traveloka, Skyscanner (máy bay)
- Link đến Booking.com, Agoda (khách sạn)

</details>

### 5. 💰 Chia tiền nhóm (Group Expense Splitting)

<details>
<summary><b>Xem chi tiết</b></summary>

#### Quản lý thành viên
- Thêm/xóa thành viên
- Hiển thị balance (được nhận/cần trả)
- Kiểm tra trước khi xóa

#### Hai kiểu chia tiền

**🟢 Chia đều (Equal Split)**
- Chọn người trả tiền
- Chọn người tham gia
- Tự động chia đều số tiền
- Hiển thị preview

**🟠 Chia custom (Custom Split)**
- Nhập số tiền từng người
- Validation: tổng phải bằng tổng chi tiêu
- Hiển thị progress real-time
- Cảnh báo nếu chưa khớp

#### Tính toán thanh toán
- **Greedy Debt Simplification Algorithm**
- Tối ưu số lượng giao dịch
- Hiển thị ai nợ ai bao nhiêu
- Đánh dấu đã thanh toán

#### Liên kết với hoạt động
- Link chi tiêu với activity
- Tracking chi tiêu theo hoạt động
- Báo cáo chi tiết

</details>

---

## 🚀 Cài đặt

### Yêu cầu hệ thống

- **Flutter SDK**: 3.11.4 trở lên
- **Dart SDK**: 3.11.4 trở lên
- **Android Studio** / **VS Code** với Flutter extension
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+

### Các bước cài đặt

#### 1. Clone repository

```bash
git clone https://github.com/tienphse181722/Smart-travel-app.git
cd Smart-travel-app
```

#### 2. Cài đặt dependencies

```bash
flutter pub get
```

#### 3. Chạy ứng dụng

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

#### 4. Build production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## 📱 Sử dụng

### Tạo chuyến đi mới

1. Mở app, tap nút **"Tạo chuyến đi mới"**
2. Nhập **điểm đến** (VD: Đà Nẵng)
3. Chọn **số ngày** (VD: 3 ngày)
4. Chọn **ngày bắt đầu**
5. Tap **"Tạo chuyến đi"**

### Thêm hoạt động

1. Vào chi tiết chuyến đi
2. Chọn ngày muốn thêm hoạt động
3. Tap **"Thêm hoạt động"**
4. Nhập thông tin:
   - Tên hoạt động
   - Địa điểm (chọn trên bản đồ hoặc search)
   - Thời gian bắt đầu/kết thúc
   - Chi phí
   - Ghi chú (tùy chọn)
5. Tap **"Lưu"**

### Tối ưu hóa lịch trình

1. Vào chi tiết chuyến đi
2. Tap nút **"Tối ưu hóa"** (icon ⚡)
3. Chọn ngày muốn tối ưu
4. Xác nhận
5. Hệ thống tự động sắp xếp lại thứ tự các điểm

### Thêm vé

1. Vào chi tiết chuyến đi
2. Tap tab **"Vé"**
3. Tap **"Thêm vé"**
4. Chọn loại vé (xe/tàu/máy bay/khách sạn)
5. Nhập thông tin:
   - Tên vé
   - Mã vé
   - Ngày giờ
   - Điểm đi/đến
   - Upload ảnh (tùy chọn)
6. Tap **"Lưu"**

### Chia tiền nhóm

1. Vào chi tiết chuyến đi
2. Tap **"Chia tiền"**
3. **Tab Thành viên**: Thêm các thành viên trong nhóm
4. **Tab Chi tiêu**: 
   - Tap **"Thêm chi tiêu"**
   - Nhập mô tả và số tiền
   - Chọn người trả
   - Chọn kiểu chia (đều hoặc custom)
   - Nếu custom: nhập số tiền từng người
   - Tap **"Thêm"**
5. **Tab Thanh toán**: Xem ai nợ ai bao nhiêu

---

## 🏗️ Kiến trúc

### Tech Stack

- **Framework**: Flutter 3.11.4
- **Language**: Dart 3.11.4
- **State Management**: StatefulWidget (built-in)
- **Storage**: SharedPreferences
- **Maps**: flutter_map + OpenStreetMap
- **Routing**: OSRM API
- **Image Picker**: image_picker
- **HTTP**: http package

### Cấu trúc project

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── trip.dart               # Trip model
│   ├── activity.dart           # Activity model
│   ├── ticket.dart             # Ticket model
│   ├── member.dart             # Member model
│   ├── expense.dart            # Expense model
│   ├── debt.dart               # Debt model
│   ├── place.dart              # Place model
│   └── food_place.dart         # Food place model
├── screens/                     # UI screens
│   ├── home_screen.dart        # Home screen
│   ├── create_trip_screen.dart # Create trip
│   ├── trip_detail_screen.dart # Trip details
│   ├── add_activity_screen.dart # Add activity
│   ├── edit_activity_screen.dart # Edit activity
│   ├── hybrid_map_screen.dart  # Map view
│   ├── nearby_places_screen.dart # Nearby places
│   ├── ticket_list_screen_v2.dart # Ticket list
│   ├── add_ticket_screen_v2.dart # Add ticket
│   ├── ticket_detail_screen_v2.dart # Ticket detail
│   ├── booking_suggestions_screen.dart # Booking links
│   ├── split_bill_screen.dart  # Split bill
│   └── add_expense_screen.dart # Add expense
├── services/                    # Business logic
│   ├── trip_service.dart       # Trip CRUD
│   ├── ticket_service.dart     # Ticket CRUD
│   ├── split_bill_service.dart # Debt calculation
│   ├── itinerary_service.dart  # Itinerary optimization
│   ├── route_optimizer_service.dart # Route optimization
│   ├── osrm_service.dart       # OSRM API
│   ├── search_service.dart     # Search logic
│   ├── data_service.dart       # Data loading
│   └── cache_service.dart      # Caching
├── widgets/                     # Reusable widgets
│   ├── ticket_card_v2.dart     # Ticket card
│   └── map_settings_dialog.dart # Map settings
└── utils/                       # Utilities

assets/
├── data/
│   ├── places.json             # Places database
│   └── foods.json              # Food places database
└── images/
    └── app_logo.png            # App logo
```

### Design Patterns

#### 1. Service Layer Pattern
```dart
// Services handle business logic
class TripService {
  static Future<void> saveTrip(Trip trip) async { }
  static Future<List<Trip>> loadTrips() async { }
  static Future<void> deleteTrip(String tripId) async { }
}
```

#### 2. Repository Pattern
```dart
// SharedPreferences as data source
class TripService {
  static final _prefs = SharedPreferences.getInstance();
  // CRUD operations
}
```

#### 3. Model-View Pattern
```dart
// Models with toJson/fromJson
class Trip {
  Map<String, dynamic> toJson() { }
  factory Trip.fromJson(Map<String, dynamic> json) { }
}
```

### Algorithms

#### 1. Route Optimization
```
Algorithm: Greedy Nearest Neighbor
Complexity: O(n²)
Input: List of activities with coordinates
Output: Optimized order of activities
```

#### 2. Debt Settlement
```
Algorithm: Greedy Debt Simplification
Complexity: O(n log n)
Input: List of expenses and members
Output: Minimum number of transactions
```

---

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  intl: ^0.19.0                 # Internationalization
  uuid: ^4.5.1                  # UUID generation
  flutter_map: ^7.0.2           # Map widget
  latlong2: ^0.9.1              # Lat/Lng handling
  http: ^1.2.0                  # HTTP requests
  shared_preferences: ^2.2.2    # Local storage
  image_picker: ^1.0.7          # Image picking
  path_provider: ^2.1.2         # Path utilities
  url_launcher: ^6.2.4          # URL launching
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0         # Linting
  flutter_launcher_icons: ^0.13.1 # Icon generation
```

---

## 🎨 UI/UX Design

### Design System

#### Colors
```dart
Primary: #2F80ED (Blue)
Secondary: #56CCF2 (Light Blue)
Surface: #F7F9FC (Light Gray)
Accent: #FF9500 (Orange)
Error: #FF3B30 (Red)
Success: #34C759 (Green)
```

#### Typography
```dart
Font Family: Inter
Headline Large: 32px, Bold
Headline Medium: 24px, Bold
Title Large: 20px, SemiBold
Title Medium: 16px, SemiBold
Body Large: 16px, Regular
Body Medium: 14px, Regular
```

#### Components
- **Cards**: Border radius 20px, Shadow 2px
- **Buttons**: Border radius 16px, Height 50px
- **Inputs**: Border radius 16px, Filled white
- **Icons**: Rounded style, 24px default

### Material Design 3
- ✅ Material You components
- ✅ Dynamic color schemes
- ✅ Adaptive layouts
- ✅ Smooth animations

---

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

---

## 📊 Performance

### Optimization Techniques

1. **Lazy Loading**: Load data on demand
2. **Caching**: Cache OSRM routes and search results
3. **Debouncing**: Debounce search input (500ms)
4. **Image Optimization**: Compress images before saving
5. **List Virtualization**: Use ListView.builder for long lists

### Benchmarks

- **App Size**: ~15 MB (release APK)
- **Cold Start**: <2s
- **Hot Reload**: <1s
- **Route Optimization**: <500ms for 10 points
- **Debt Calculation**: <100ms for 10 members

---

## 🔒 Security & Privacy

### Data Storage
- ✅ All data stored locally (SharedPreferences)
- ✅ No cloud sync (privacy-first)
- ✅ No user authentication required
- ✅ No personal data collection

### Permissions
- 📍 **Location**: For nearby places (optional)
- 📷 **Camera**: For ticket photos (optional)
- 📁 **Storage**: For saving images (optional)

---

## 🌐 Localization

### Supported Languages
- 🇻🇳 **Tiếng Việt** (Vietnamese) - Default
- 🇬🇧 **English** - Coming soon

### Add New Language
```dart
// lib/l10n/app_en.arb
{
  "appTitle": "Smart Travel",
  "createTrip": "Create Trip",
  ...
}
```

---

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! Hãy làm theo các bước sau:

### 1. Fork repository
```bash
# Click "Fork" button on GitHub
```

### 2. Clone fork của bạn
```bash
git clone https://github.com/YOUR_USERNAME/Smart-travel-app.git
cd Smart-travel-app
```

### 3. Tạo branch mới
```bash
git checkout -b feature/amazing-feature
```

### 4. Commit changes
```bash
git add .
git commit -m "Add amazing feature"
```

### 5. Push to branch
```bash
git push origin feature/amazing-feature
```

### 6. Tạo Pull Request
- Mở GitHub
- Click "New Pull Request"
- Mô tả changes của bạn
- Submit!

### Coding Guidelines

- ✅ Follow Dart style guide
- ✅ Write meaningful commit messages
- ✅ Add comments for complex logic
- ✅ Test before submitting PR
- ✅ Update README if needed

---

## 📝 Changelog

### Version 1.0.0 (2026-04-21)

#### ✨ Features
- ✅ Quản lý lịch trình du lịch
- ✅ Tối ưu hóa tuyến đường
- ✅ Tìm kiếm địa điểm
- ✅ Quản lý vé (4 loại)
- ✅ Chia tiền nhóm (equal + custom split)
- ✅ Bản đồ tương tác
- ✅ Gợi ý đặt vé
- ✅ Material Design 3 UI

#### 🐛 Bug Fixes
- ✅ Fix data persistence issue
- ✅ Fix cascade delete
- ✅ Fix custom split validation

#### 🎨 UI/UX
- ✅ Gradient colors
- ✅ Smooth animations
- ✅ Empty states
- ✅ Loading indicators

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 Smart Travel Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👥 Team

### Developers
- **Tiến** - Lead Developer - [@tienphse181722](https://github.com/tienphse181722)

### Contributors
- Xem danh sách đầy đủ tại [Contributors](https://github.com/tienphse181722/Smart-travel-app/graphs/contributors)

---

## 📞 Liên hệ

- **GitHub**: [@tienphse181722](https://github.com/tienphse181722)
- **Repository**: [Smart-travel-app](https://github.com/tienphse181722/Smart-travel-app)
- **Issues**: [Report Bug](https://github.com/tienphse181722/Smart-travel-app/issues)
- **Discussions**: [Discussions](https://github.com/tienphse181722/Smart-travel-app/discussions)

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [OpenStreetMap](https://www.openstreetmap.org) - Map data
- [OSRM](http://project-osrm.org) - Routing engine
- [Material Design](https://m3.material.io) - Design system
- [Flutter Community](https://flutter.dev/community) - Support and packages

---

## 🗺️ Roadmap

### Version 1.1.0 (Q3 2026)
- [ ] Cloud sync với Firebase
- [ ] User authentication
- [ ] Share trip với bạn bè
- [ ] Export PDF itinerary
- [ ] Weather integration
- [ ] Currency converter

### Version 1.2.0 (Q4 2026)
- [ ] AI trip suggestions
- [ ] Budget tracking
- [ ] Expense analytics
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Offline maps

### Version 2.0.0 (2027)
- [ ] Social features
- [ ] Trip reviews
- [ ] Photo gallery
- [ ] Travel blog
- [ ] Gamification
- [ ] AR navigation

---

<div align="center">

**Made with ❤️ by Smart Travel Team**

⭐ Star us on GitHub — it motivates us a lot!

[⬆ Back to top](#-smart-travel-app)

</div>
