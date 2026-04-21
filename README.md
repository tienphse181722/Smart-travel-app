# Smart Travel App - Ứng dụng Du lịch Thông minh

Ứng dụng Flutter giúp tự động tạo lịch trình du lịch, quản lý chi tiêu và gợi ý địa điểm.

## ✨ Tính năng (Phase 1 - CORE)

### ✅ Đã hoàn thành

1. **Tạo chuyến đi**
   - Nhập địa điểm, số ngày, ngày bắt đầu
   - Tự động generate lịch trình

2. **Auto generate lịch trình**
   - Sáng → Place (địa điểm vui chơi)
   - Trưa → Food (ăn uống)
   - Chiều → Place
   - Tối → Food

3. **Timeline UI (kiểu TikTok)**
   - Scroll dọc
   - Card hiển thị: thời gian, tên, loại, chi phí
   - Icon phân biệt Food/Place

4. **Auto tính tiền**
   - Tính từ avg_cost
   - Hiển thị tổng tiền theo ngày
   - Hiển thị tổng tiền cả chuyến

5. **Chỉnh sửa lịch trình**
   - Thêm activity thủ công
   - Xóa activity (swipe left)
   - Sửa activity (tap vào card)
   - Tab chọn: Ăn uống / Vui chơi

6. **Dữ liệu tách riêng**
   - ✅ Place (places.json) - 8 địa điểm
   - ✅ FoodPlace (foods.json) - 10 địa điểm
   - Mỗi loại có: id, name, lat, lng, tags, avg_cost

7. **Search & Filter**
   - Tìm kiếm theo tên
   - Lọc theo tag

## 🏗️ Kiến trúc

```
lib/
├── models/
│   ├── activity.dart       # Model cho hoạt động trong lịch trình
│   ├── place.dart          # Model cho địa điểm vui chơi
│   ├── food_place.dart     # Model cho địa điểm ăn uống
│   └── trip.dart           # Model cho chuyến đi
├── services/
│   ├── data_service.dart   # Load & filter dữ liệu từ JSON
│   └── itinerary_service.dart  # Generate lịch trình tự động
├── screens/
│   ├── home_screen.dart    # Danh sách chuyến đi
│   ├── create_trip_screen.dart  # Tạo chuyến đi mới
│   ├── trip_detail_screen.dart  # Timeline lịch trình
│   ├── add_activity_screen.dart # Thêm activity
│   └── edit_activity_screen.dart # Sửa activity
└── main.dart
```

## 📦 Dependencies

- `intl`: Format tiền tệ và ngày tháng
- `uuid`: Generate unique ID

## 🚀 Cách chạy

```bash
# Di chuyển vào thư mục dự án
cd smart_travel_app

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run

# Build APK
flutter build apk
```

## 📱 Hướng dẫn sử dụng

1. **Tạo chuyến đi mới**
   - Nhấn nút "Tạo chuyến đi" ở màn hình chính
   - Nhập địa điểm (VD: Đà Nẵng)
   - Chọn số ngày (1-14 ngày)
   - Chọn ngày bắt đầu
   - Nhấn "Tạo lịch trình tự động"

2. **Xem lịch trình**
   - Chọn chuyến đi từ danh sách
   - Chọn ngày muốn xem
   - Scroll để xem các hoạt động

3. **Chỉnh sửa lịch trình**
   - **Thêm**: Nhấn nút + → Chọn tab Vui chơi/Ăn uống → Chọn địa điểm
   - **Sửa**: Tap vào card activity → Sửa thông tin → Lưu
   - **Xóa**: Swipe left trên card → Xác nhận xóa

4. **Xem chi phí**
   - Chi phí ngày: Hiển thị ở đầu timeline
   - Tổng chi phí: Hiển thị ở màn hình chính và timeline

## 📊 Dữ liệu mẫu

### Places (Vui chơi)
- Bãi biển Mỹ Khê
- Cầu Rồng
- Bà Nà Hills
- Hội An Ancient Town
- Ngũ Hành Sơn
- Bảo tàng Chăm
- Bán đảo Sơn Trà
- Asia Park

### Foods (Ăn uống)
- Bà Dưỡng - Mì Quảng
- Bún Chả Cá 1297
- Nhà hàng Bé Mặn
- Cafe Cộng
- Bánh Tráng Cuốn Thịt Heo
- Nhà hàng Madame Lân
- Bún Bò Huế Hải
- Quán Ốc Oanh
- Highlands Coffee
- Cơm Gà Bà Nga

## 🎯 Roadmap

### Phase 2 - SMART (Chưa làm)
- [ ] Gợi ý địa điểm gần nhau (dựa trên lat/lng)
- [ ] AI gợi ý lịch trình thông minh hơn
- [ ] Chia tiền nhóm

### Phase 3 - MAP (Chưa làm)
- [ ] Hiển thị bản đồ
- [ ] Tối ưu route

### Phase 4 - QUẢN LÝ VÉ (Chưa làm)
- [ ] Lưu vé
- [ ] Upload ảnh vé
- [ ] Xem lại vé

## 🔧 Kỹ thuật

- **Framework**: Flutter 3.41.6
- **Language**: Dart 3.11.4
- **State Management**: setState (simple)
- **Data Storage**: JSON local (offline)
- **UI Pattern**: Material Design 3

## 📝 Ghi chú

- Dữ liệu được tách riêng hoàn toàn: Place và FoodPlace
- Mỗi địa điểm có tags để dễ filter
- Chi phí tự động tính từ avg_cost
- Không cần backend, chạy hoàn toàn offline
- Code đơn giản, dễ hiểu, dễ mở rộng

## 🎨 UI/UX

- Timeline kiểu TikTok (scroll dọc)
- Card design hiện đại
- Icon phân biệt rõ ràng (Food/Place)
- Màu sắc: Orange cho Food, Blue cho Place
- Swipe to delete
- Tap to edit
- Material Design 3

## 👨‍💻 Phát triển tiếp

Để thêm địa điểm mới, chỉnh sửa file:
- `assets/data/places.json` - Địa điểm vui chơi
- `assets/data/foods.json` - Địa điểm ăn uống

Format:
```json
{
  "id": "unique_id",
  "name": "Tên địa điểm",
  "lat": 16.0544,
  "lng": 108.2425,
  "tags": ["tag1", "tag2"],
  "avg_cost": 50000
}
```

## 📄 License

MIT License - Free to use
