# PHASE 5 - QUẢN LÝ CHIA TIỀN NHÓM (NÂNG CAO) - HOÀN THÀNH ✅

## Tổng quan
Phase 5 đã được hoàn thành với đầy đủ các tính năng quản lý chi tiêu nhóm nâng cao, bao gồm chia tiền đều và chia tiền custom.

## Các tính năng đã triển khai

### 1. ✅ Quản lý thành viên
- **Thêm thành viên**: Dialog nhập tên thành viên
- **Hiển thị danh sách**: Card hiển thị thông tin từng thành viên
  - Avatar với chữ cái đầu
  - Số tiền đã trả
  - Số tiền được nhận/cần trả (balance)
- **Xóa thành viên**: 
  - Kiểm tra xem thành viên có trong chi tiêu không
  - Không cho xóa nếu đã có chi tiêu liên quan
  - Xác nhận trước khi xóa

### 2. ✅ Quản lý chi tiêu (2 loại chia tiền)

#### A. Chia đều (Equal Split)
- Nhập mô tả chi tiêu
- Nhập số tiền
- Chọn người trả tiền
- Chọn những người tham gia chia
- Tự động tính số tiền mỗi người phải trả (chia đều)
- Hiển thị preview số tiền mỗi người

#### B. Chia custom (Custom Split)
- Nhập mô tả chi tiêu
- Nhập số tiền tổng
- Chọn người trả tiền
- **Nhập số tiền từng người** (manual input)
- **Validation**: Tổng số tiền custom phải bằng tổng chi tiêu
- Hiển thị tổng số tiền đã nhập vs tổng chi tiêu
- Cảnh báo nếu chưa khớp

### 3. ✅ Liên kết với hoạt động (Optional)
- Dropdown chọn activity từ lịch trình
- Có thể không liên kết (tùy chọn)
- Lưu `activityId` trong expense

### 4. ✅ Hiển thị chi tiêu
- Card hiển thị đầy đủ thông tin:
  - Icon và gradient đẹp
  - Tên chi tiêu
  - Người đã trả
  - Số tiền
  - **Badge hiển thị loại chia**: "Chia đều" (xanh) hoặc "Chia custom" (cam)
  - **Chi tiết chia custom**: Hiển thị danh sách từng người và số tiền
  - Ngày giờ tạo
  - Nút xóa chi tiêu

### 5. ✅ Tính toán thanh toán (Settlement)
- Thuật toán tối ưu hóa số lượng giao dịch (greedy algorithm)
- Hiển thị ai nợ ai bao nhiêu
- Card thanh toán với:
  - Avatar người nợ (màu đỏ)
  - Mũi tên chỉ hướng
  - Tên người được nợ
  - Số tiền cần thanh toán (gradient xanh)

### 6. ✅ Đánh dấu đã thanh toán
- Nút "Đánh dấu đã thanh toán" ở tab Thanh toán
- Xác nhận trước khi thực hiện
- **Xóa tất cả chi tiêu** khi đánh dấu đã thanh toán
- Thông báo thành công

### 7. ✅ Reset và xóa dữ liệu
Menu 3 chấm ở góc phải với 2 tùy chọn:

#### A. Xóa tất cả chi tiêu
- Xóa tất cả expenses
- Giữ lại members
- Xác nhận trước khi xóa
- Kiểm tra nếu không có chi tiêu

#### B. Xóa tất cả dữ liệu
- Xóa tất cả members và expenses
- Cảnh báo không thể hoàn tác
- Xác nhận trước khi xóa
- Kiểm tra nếu không có dữ liệu

## Cấu trúc dữ liệu

### Expense Model
```dart
enum SplitType {
  equal,   // Chia đều
  custom,  // Chia custom
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy;                    // Member ID
  final List<String> sharedWith;          // For equal split
  final Map<String, double>? customAmounts; // For custom split
  final SplitType splitType;
  final String? activityId;               // Link to activity
  final DateTime createdAt;
}
```

### SplitBillService
- `calculateDebts()`: Tính toán ai nợ ai
- `getMemberPaidAmounts()`: Tổng tiền mỗi người đã trả
- `getMemberShouldPayAmounts()`: Tổng tiền mỗi người nên trả
- `_simplifyDebts()`: Tối ưu hóa số lượng giao dịch

## UI/UX Features

### Material Design 3
- Gradient xanh dương (primary)
- Card với border radius 12-16px
- Shadow nhẹ
- Icon rounded
- Spacing nhất quán

### Responsive
- SafeArea cho notch
- Floating action button theo tab
- Bottom sheet cho "Đánh dấu đã thanh toán"
- Dialog xác nhận với border radius

### Validation & Error Handling
- Kiểm tra thành viên trước khi thêm chi tiêu
- Validation form đầy đủ
- Validation custom split (tổng phải khớp)
- Không cho xóa member có chi tiêu
- Thông báo lỗi rõ ràng với SnackBar

### Empty States
- Icon lớn với background tròn
- Tiêu đề và mô tả rõ ràng
- Hướng dẫn người dùng

## Files đã cập nhật

### 1. Models
- ✅ `lib/models/expense.dart` - Thêm SplitType, customAmounts, activityId

### 2. Services
- ✅ `lib/services/split_bill_service.dart` - Hỗ trợ cả equal và custom split

### 3. Screens
- ✅ `lib/screens/add_expense_screen.dart` - Screen mới với UI đầy đủ cho custom split
- ✅ `lib/screens/split_bill_screen.dart` - Tích hợp AddExpenseScreen, thêm các tính năng:
  - Menu xóa dữ liệu
  - Hiển thị split type và custom amounts
  - Nút đánh dấu đã thanh toán
  - Xóa từng chi tiêu
  - Flatten activities từ dailyActivities

## Testing Checklist

### Thành viên
- [x] Thêm thành viên mới
- [x] Hiển thị danh sách thành viên
- [x] Xóa thành viên (không có chi tiêu)
- [x] Không cho xóa thành viên có chi tiêu
- [x] Hiển thị balance đúng

### Chi tiêu - Chia đều
- [x] Thêm chi tiêu chia đều
- [x] Chọn người trả
- [x] Chọn người tham gia
- [x] Tính toán đúng số tiền mỗi người
- [x] Hiển thị badge "Chia đều"

### Chi tiêu - Chia custom
- [x] Thêm chi tiêu chia custom
- [x] Nhập số tiền từng người
- [x] Validation tổng số tiền
- [x] Cảnh báo khi chưa khớp
- [x] Hiển thị badge "Chia custom"
- [x] Hiển thị chi tiết custom amounts

### Thanh toán
- [x] Tính toán debts đúng
- [x] Hiển thị settlement
- [x] Đánh dấu đã thanh toán
- [x] Xóa expenses sau khi thanh toán

### Reset & Clear
- [x] Xóa tất cả chi tiêu
- [x] Xóa tất cả dữ liệu
- [x] Xác nhận trước khi xóa
- [x] Kiểm tra empty state

### Liên kết activity
- [x] Chọn activity từ dropdown
- [x] Có thể không chọn
- [x] Lưu activityId

## Kết quả
✅ **Phase 5 đã hoàn thành 100%**

Tất cả các tính năng theo yêu cầu đã được triển khai:
- ✅ Quản lý thành viên (thêm, xem, xóa)
- ✅ Ghi chi tiêu với người trả và người tham gia
- ✅ Hỗ trợ chia đều VÀ chia custom (nhập số tiền từng người)
- ✅ Tính toán nợ và thanh toán
- ✅ Đánh dấu đã thanh toán
- ✅ Reset/xóa tất cả chi tiêu
- ✅ Liên kết chi tiêu với hoạt động (tùy chọn)

App đã được kiểm tra và compile thành công với `flutter analyze` (chỉ còn warnings về code style, không có errors).
