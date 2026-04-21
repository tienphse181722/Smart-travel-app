import '../models/member.dart';
import '../models/expense.dart';
import '../models/debt.dart';

class SplitBillService {
  // Tính toán ai nợ ai bao nhiêu
  static List<Debt> calculateDebts(
    List<Member> members,
    List<Expense> expenses,
  ) {
    if (members.isEmpty || expenses.isEmpty) {
      return [];
    }

    // Tính tổng số tiền mỗi người đã trả
    final Map<String, double> paid = {};
    // Tính tổng số tiền mỗi người nên trả
    final Map<String, double> shouldPay = {};

    // Khởi tạo
    for (var member in members) {
      paid[member.id] = 0;
      shouldPay[member.id] = 0;
    }

    // Tính toán
    for (var expense in expenses) {
      // Người trả tiền
      paid[expense.paidBy] = (paid[expense.paidBy] ?? 0) + expense.amount;

      // Chia tiền theo loại
      if (expense.splitType == SplitType.custom && expense.customAmounts != null) {
        // Chia custom
        expense.customAmounts!.forEach((memberId, amount) {
          shouldPay[memberId] = (shouldPay[memberId] ?? 0) + amount;
        });
      } else {
        // Chia đều
        final shareAmount = expense.amount / expense.sharedWith.length;
        for (var memberId in expense.sharedWith) {
          shouldPay[memberId] = (shouldPay[memberId] ?? 0) + shareAmount;
        }
      }
    }

    // Tính balance: số tiền thực tế mỗi người nợ/được nợ
    final Map<String, double> balance = {};
    for (var member in members) {
      balance[member.id] = paid[member.id]! - shouldPay[member.id]!;
    }

    // Tạo danh sách debts
    return _simplifyDebts(balance);
  }

  // Đơn giản hóa các khoản nợ (thuật toán greedy)
  static List<Debt> _simplifyDebts(Map<String, double> balance) {
    final List<Debt> debts = [];
    
    // Tạo 2 danh sách: người nợ và người được nợ
    final List<MapEntry<String, double>> creditors = []; // Người được nợ
    final List<MapEntry<String, double>> debtors = []; // Người nợ

    balance.forEach((memberId, amount) {
      if (amount > 0.01) {
        // Người được nợ (đã trả nhiều hơn)
        creditors.add(MapEntry(memberId, amount));
      } else if (amount < -0.01) {
        // Người nợ (đã trả ít hơn)
        debtors.add(MapEntry(memberId, -amount));
      }
    });

    // Sắp xếp giảm dần
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    int i = 0, j = 0;
    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];

      final amount = creditor.value < debtor.value 
          ? creditor.value 
          : debtor.value;

      debts.add(Debt(
        fromMemberId: debtor.key,
        toMemberId: creditor.key,
        amount: amount,
      ));

      creditors[i] = MapEntry(creditor.key, creditor.value - amount);
      debtors[j] = MapEntry(debtor.key, debtor.value - amount);

      if (creditors[i].value < 0.01) i++;
      if (debtors[j].value < 0.01) j++;
    }

    return debts;
  }

  // Tính tổng chi phí
  static double getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Tính số tiền mỗi người đã trả
  static Map<String, double> getMemberPaidAmounts(
    List<Member> members,
    List<Expense> expenses,
  ) {
    final Map<String, double> paid = {};
    
    for (var member in members) {
      paid[member.id] = 0;
    }

    for (var expense in expenses) {
      paid[expense.paidBy] = (paid[expense.paidBy] ?? 0) + expense.amount;
    }

    return paid;
  }

  // Tính số tiền mỗi người nên trả
  static Map<String, double> getMemberShouldPayAmounts(
    List<Member> members,
    List<Expense> expenses,
  ) {
    final Map<String, double> shouldPay = {};
    
    for (var member in members) {
      shouldPay[member.id] = 0;
    }

    for (var expense in expenses) {
      if (expense.splitType == SplitType.custom && expense.customAmounts != null) {
        // Chia custom
        expense.customAmounts!.forEach((memberId, amount) {
          shouldPay[memberId] = (shouldPay[memberId] ?? 0) + amount;
        });
      } else {
        // Chia đều
        final shareAmount = expense.amount / expense.sharedWith.length;
        for (var memberId in expense.sharedWith) {
          shouldPay[memberId] = (shouldPay[memberId] ?? 0) + shareAmount;
        }
      }
    }

    return shouldPay;
  }
}
