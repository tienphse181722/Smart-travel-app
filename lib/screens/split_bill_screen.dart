import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../services/split_bill_service.dart';

class SplitBillScreen extends StatefulWidget {
  final Trip trip;

  const SplitBillScreen({super.key, required this.trip});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen>
    with SingleTickerProviderStateMixin {
  late Trip _trip;
  late TabController _tabController;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMembersTab(),
                  _buildExpensesTab(),
                  _buildSettlementTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context, _trip),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chia tiền nhóm',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${_trip.members.length} thành viên',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Thành viên'),
          Tab(text: 'Chi tiêu'),
          Tab(text: 'Thanh toán'),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    if (_trip.members.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'Chưa có thành viên',
        subtitle: 'Thêm thành viên để bắt đầu chia tiền',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trip.members.length,
      itemBuilder: (context, index) {
        return _buildMemberCard(_trip.members[index]);
      },
    );
  }

  Widget _buildMemberCard(Member member) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final paidAmounts = SplitBillService.getMemberPaidAmounts(
      _trip.members,
      _trip.expenses,
    );
    final shouldPayAmounts = SplitBillService.getMemberShouldPayAmounts(
      _trip.members,
      _trip.expenses,
    );

    final paid = paidAmounts[member.id] ?? 0;
    final shouldPay = shouldPayAmounts[member.id] ?? 0;
    final balance = paid - shouldPay;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF2F80ED).withValues(alpha: 0.1),
              child: Text(
                member.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F80ED),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đã trả: ${formatter.format(paid)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance >= 0 ? 'Được nhận' : 'Cần trả',
                  style: TextStyle(
                    fontSize: 12,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  formatter.format(balance.abs()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () => _deleteMember(member),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_trip.expenses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Chưa có chi tiêu',
        subtitle: 'Thêm chi tiêu để theo dõi',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trip.expenses.length,
      itemBuilder: (context, index) {
        return _buildExpenseCard(_trip.expenses[index]);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final payer = _trip.members.firstWhere((m) => m.id == expense.paidBy);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payer.name} đã trả',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  formatter.format(expense.amount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F80ED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chia cho ${expense.sharedWith.length} người',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormatter.format(expense.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementTab() {
    if (_trip.members.length < 2 || _trip.expenses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Chưa có dữ liệu',
        subtitle: 'Thêm thành viên và chi tiêu để xem thanh toán',
      );
    }

    final debts = SplitBillService.calculateDebts(_trip.members, _trip.expenses);
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    if (debts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'Đã thanh toán hết',
        subtitle: 'Không còn khoản nợ nào',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final from = _trip.members.firstWhere((m) => m.id == debt.fromMemberId);
        final to = _trip.members.firstWhere((m) => m.id == debt.toMemberId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  child: Text(
                    from.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        from.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            to.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatter.format(debt.amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: _addMember,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Thêm thành viên'),
        backgroundColor: const Color(0xFF2F80ED),
      );
    } else if (_tabController.index == 1) {
      return FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm chi tiêu'),
        backgroundColor: const Color(0xFF2F80ED),
      );
    }
    return null;
  }

  void _addMember() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thêm thành viên'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên thành viên',
            hintText: 'VD: Nguyễn Văn A',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      setState(() {
        final newMember = Member(
          id: _uuid.v4(),
          name: nameController.text,
        );
        _trip = _trip.copyWith(
          members: [..._trip.members, newMember],
        );
      });
    }
  }

  void _deleteMember(Member member) async {
    // Kiểm tra xem member có trong expenses không
    final hasExpenses = _trip.expenses.any(
      (e) => e.paidBy == member.id || e.sharedWith.contains(member.id),
    );

    if (hasExpenses) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể xóa thành viên đã có chi tiêu'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${member.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _trip = _trip.copyWith(
          members: _trip.members.where((m) => m.id != member.id).toList(),
        );
      });
    }
  }

  void _addExpense() async {
    if (_trip.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng thêm thành viên trước'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final descController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedPayer = _trip.members.first.id;
    final Set<String> selectedSharedWith = _trip.members.map((m) => m.id).toSet();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Thêm chi tiêu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'VD: Ăn trưa',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền',
                    suffixText: '₫',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedPayer,
                  decoration: const InputDecoration(labelText: 'Người trả'),
                  items: _trip.members.map((member) {
                    return DropdownMenuItem(
                      value: member.id,
                      child: Text(member.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPayer = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Chia cho:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._trip.members.map((member) {
                  return CheckboxListTile(
                    title: Text(member.name),
                    value: selectedSharedWith.contains(member.id),
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          selectedSharedWith.add(member.id);
                        } else {
                          selectedSharedWith.remove(member.id);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    selectedSharedWith.isNotEmpty) {
                  Navigator.pop(context, {
                    'description': descController.text,
                    'amount': double.parse(amountController.text),
                    'paidBy': selectedPayer,
                    'sharedWith': selectedSharedWith.toList(),
                  });
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final newExpense = Expense(
          id: _uuid.v4(),
          description: result['description'],
          amount: result['amount'],
          paidBy: result['paidBy'],
          sharedWith: result['sharedWith'],
          createdAt: DateTime.now(),
        );
        _trip = _trip.copyWith(
          expenses: [..._trip.expenses, newExpense],
        );
      });
    }
  }
}
