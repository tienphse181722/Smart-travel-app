import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/models/member.dart';
import '../../data/models/expense.dart';
import '../../data/models/activity.dart';

class AddExpenseScreen extends StatefulWidget {
  final List<Member> members;
  final List<Activity>? activities;

  const AddExpenseScreen({
    super.key,
    required this.members,
    this.activities,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final Map<String, TextEditingController> _customAmountControllers = {};

  String? _selectedPayer;
  SplitType _splitType = SplitType.equal;
  final Set<String> _selectedSharedWith = {};
  final Map<String, double> _customAmounts = {};
  String? _selectedActivityId;

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      _selectedPayer = widget.members.first.id;
      // Mặc định chọn tất cả members
      _selectedSharedWith.addAll(widget.members.map((m) => m.id));
      
      // Khởi tạo controllers cho custom amounts
      for (var member in widget.members) {
        _customAmountControllers[member.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _customAmountControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  double get _totalAmount {
    final text = _amountController.text;
    return text.isEmpty ? 0 : double.tryParse(text) ?? 0;
  }

  double get _totalCustomAmount {
    return _customAmounts.values.fold(0, (sum, amount) => sum + amount);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm chi tiêu'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả *',
                hintText: 'VD: Ăn trưa',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mô tả';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền *',
                hintText: '0',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: '₫',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Số tiền phải lớn hơn 0';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Payer
            DropdownButtonFormField<String>(
              initialValue: _selectedPayer,
              decoration: const InputDecoration(
                labelText: 'Người trả *',
                prefixIcon: Icon(Icons.person),
              ),
              items: widget.members.map((member) {
                return DropdownMenuItem(
                  value: member.id,
                  child: Text(member.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPayer = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn người trả';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Link to activity (optional)
            if (widget.activities != null && widget.activities!.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedActivityId,
                decoration: const InputDecoration(
                  labelText: 'Liên kết với hoạt động (tùy chọn)',
                  prefixIcon: Icon(Icons.link),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    child: Text('Không liên kết'),
                  ),
                  ...widget.activities!.map((activity) {
                    return DropdownMenuItem<String>(
                      value: activity.id,
                      child: Text(activity.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedActivityId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Split type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kiểu chia tiền',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Chia đều'),
                            selected: _splitType == SplitType.equal,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _splitType = SplitType.equal;
                                  _customAmounts.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Chia custom'),
                            selected: _splitType == SplitType.custom,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _splitType = SplitType.custom;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Split details
            if (_splitType == SplitType.equal) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chia cho',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.members.map((member) {
                        final isSelected = _selectedSharedWith.contains(member.id);
                        final shareAmount = _selectedSharedWith.isEmpty
                            ? 0.0
                            : _totalAmount / _selectedSharedWith.length;

                        return CheckboxListTile(
                          title: Text(member.name),
                          subtitle: isSelected
                              ? Text(
                                  'Phải trả: ${formatter.format(shareAmount)}',
                                  style: const TextStyle(color: Color(0xFF2F80ED)),
                                )
                              : null,
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedSharedWith.add(member.id);
                              } else {
                                _selectedSharedWith.remove(member.id);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nhập số tiền từng người',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_totalAmount > 0)
                            Text(
                              '${formatter.format(_totalCustomAmount)} / ${formatter.format(_totalAmount)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _totalCustomAmount == _totalAmount
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.members.map((member) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  member.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _customAmountControllers[member.id],
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    suffixText: '₫',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      final amount = double.tryParse(value) ?? 0;
                                      if (amount > 0) {
                                        _customAmounts[member.id] = amount;
                                      } else {
                                        _customAmounts.remove(member.id);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_totalAmount > 0 && _totalCustomAmount != _totalAmount)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tổng số tiền chia phải bằng ${formatter.format(_totalAmount)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveExpense,
                child: const Text('Thêm chi tiêu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate split
    if (_splitType == SplitType.equal) {
      if (_selectedSharedWith.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất 1 người để chia')),
        );
        return;
      }
    } else {
      if (_customAmounts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số tiền cho ít nhất 1 người')),
        );
        return;
      }
      if (_totalCustomAmount != _totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tổng số tiền chia phải bằng tổng chi tiêu')),
        );
        return;
      }
    }

    final expense = Expense(
      id: '', // Will be set by caller
      description: _descController.text.trim(),
      amount: _totalAmount,
      paidBy: _selectedPayer!,
      sharedWith: _splitType == SplitType.equal ? _selectedSharedWith.toList() : [],
      customAmounts: _splitType == SplitType.custom ? Map.from(_customAmounts) : null,
      splitType: _splitType,
      activityId: _selectedActivityId,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, expense);
  }
}
