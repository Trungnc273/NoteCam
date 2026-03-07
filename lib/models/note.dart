import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @HiveField(3)
  String tag;

  @HiveField(4)
  bool starred;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.starred,
    required this.createdAt,
    required this.updatedAt,
  });

  String get preview {
    if (body.isEmpty) return 'Ghi chú trống';
    return body.length > 100 ? '${body.substring(0, 100)}...' : body;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    }
  }

  Note copyWith({
    String? id,
    String? title,
    String? body,
    String? tag,
    bool? starred,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tag: tag ?? this.tag,
      starred: starred ?? this.starred,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Mock data for initial setup
List<Note> getMockNotes() {
  final now = DateTime.now();
  return [
    Note(
      id: '1',
      title: 'Họp 10h sáng',
      body: '''Nhớ chuẩn bị slide báo cáo quý 2, mang theo laptop sạc đầy.

Agenda cuộc họp:
- Tổng kết Q2 2024
- Kế hoạch Q3 
- Phân công công việc
- Deadline dự án mới

Participants: Anh Minh, chị Lan, team dev 5 người

📍 Phòng họp A3, tầng 7''',
      tag: 'Công việc',
      starred: true,
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    ),
    Note(
      id: '2',
      title: 'Danh sách mua đồ',
      body: '''🛒 Siêu thị:
- Sữa tươi Vinamilk x2
- Bánh mì sandwich
- Trứng gà (1 vỉ)
- Rau xanh (cải, bắp cải)
- Thịt bò 500g
- Nước mắm Phú Quốc
- Dầu ăn

🧴 Đồ dùng:
- Giấy vệ sinh
- Nước rửa tay''',
      tag: 'Cá nhân',
      starred: false,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    Note(
      id: '3',
      title: 'Ý tưởng dự án',
      body: '''💡 App quản lý chi tiêu cá nhân

Features:
- Tích hợp AI phân tích thói quen chi tiêu
- Kết nối tài khoản ngân hàng (read-only)
- Báo cáo hàng tháng dạng biểu đồ
- Nhắc nhở thanh toán hóa đơn
- Chia sẻ chi phí nhóm

Tech stack: React Native, Node.js, PostgreSQL

Timeline: 3 tháng MVP''',
      tag: 'Dự án',
      starred: true,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    Note(
      id: '4',
      title: 'Kế hoạch tuần',
      body: '''📅 Tuần 10/3 - 14/3

Thứ 2: Họp nhóm lúc 9h, review code sau đó
Thứ 3: Deadline báo cáo tháng
Thứ 4: Training kỹ năng mới
Thứ 5: Demo sản phẩm với khách hàng
Thứ 6: Review tuần, planning tuần sau

📌 Ưu tiên:
1. Hoàn thiện feature authentication
2. Fix bug #234
3. Viết documentation''',
      tag: 'Kế hoạch',
      starred: false,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
    ),
    Note(
      id: '5',
      title: 'Nhật ký cá nhân',
      body: '''Hôm nay là một ngày khá thú vị.

Mình đã gặp lại người bạn cũ từ hồi đại học. Chúng mình đã ngồi cà phê cả buổi chiều và ôn lại nhiều kỉ niệm.

Cảm giác thời gian trôi nhanh thật. Mới ngày nào còn là sinh viên nghèo, giờ ai cũng có công việc ổn định.

Cần nhớ: trân trọng những khoảnh khắc nhỏ trong cuộc sống...''',
      tag: 'Nhật ký',
      starred: false,
      createdAt: now.subtract(const Duration(days: 8)),
      updatedAt: now.subtract(const Duration(days: 8)),
    ),
  ];
}
