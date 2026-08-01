import '../core/ac_chat.dart';

// ============================================================
// mock_data.dart — All in-memory data for the Accountea prototype
// ============================================================

// ----- Current logged-in user -----
Map<String, dynamic> currentUser = {
  'id': 'user-1',
  'name': 'Arjun Sharma',
  'username': 'arjun.sharma',
  'email': 'arjun@example.com',
  'phone': '+91 98765 43210',
  'avatar': null,
};

final AcChatUser currentUserInstance = AcChatUser.instanceFromJson(jsonData: currentUser);

// ----- Users (for chat) -----
List<Map<String, dynamic>> users = [
  {'id': 'user-2', 'name': 'Priya Kapoor', 'username': 'priya.kapoor', 'email': 'priya@example.com', 'avatar': null},
  {'id': 'user-3', 'name': 'Rahul Mehta', 'username': 'rahul.mehta', 'email': 'rahul@example.com', 'avatar': null},
  {'id': 'user-4', 'name': 'Sneha Reddy', 'username': 'sneha.reddy', 'email': 'sneha@example.com', 'avatar': null},
  {'id': 'user-5', 'name': 'Amit Singh', 'username': 'amit.singh', 'email': 'amit@example.com', 'avatar': null},
];

// ----- Payment Methods -----
List<Map<String, dynamic>> paymentMethods = [
  {'id': 1, 'name': 'Cash', 'type': 'cash', 'accountNumber': null, 'balance': 5000.0},
  {'id': 2, 'name': 'HDFC Bank', 'type': 'bank', 'accountNumber': '****4523', 'balance': 45200.0},
  {'id': 3, 'name': 'GPay / UPI', 'type': 'upi', 'accountNumber': 'arjun@hdfcbank', 'balance': 0.0},
  {'id': 4, 'name': 'HDFC Credit Card', 'type': 'credit_card', 'accountNumber': '****9201', 'balance': -8500.0},
];

// ----- Categories -----
List<Map<String, dynamic>> categories = [
  // Expense
  {'id': 1, 'name': 'Food & Dining', 'type': 'expense', 'icon': 'restaurant'},
  {'id': 2, 'name': 'Transport', 'type': 'expense', 'icon': 'directions_car'},
  {'id': 3, 'name': 'Shopping', 'type': 'expense', 'icon': 'shopping_bag'},
  {'id': 4, 'name': 'Bills & Utilities', 'type': 'expense', 'icon': 'receipt'},
  {'id': 5, 'name': 'Health', 'type': 'expense', 'icon': 'local_hospital'},
  {'id': 6, 'name': 'Entertainment', 'type': 'expense', 'icon': 'movie'},
  {'id': 7, 'name': 'Education', 'type': 'expense', 'icon': 'school'},
  {'id': 8, 'name': 'Others', 'type': 'expense', 'icon': 'more_horiz'},
  // Income
  {'id': 9, 'name': 'Salary', 'type': 'income', 'icon': 'work'},
  {'id': 10, 'name': 'Freelance', 'type': 'income', 'icon': 'laptop'},
  {'id': 11, 'name': 'Business', 'type': 'income', 'icon': 'business'},
  {'id': 12, 'name': 'Investment', 'type': 'income', 'icon': 'trending_up'},
  {'id': 13, 'name': 'Gift', 'type': 'income', 'icon': 'card_giftcard'},
  {'id': 14, 'name': 'Other Income', 'type': 'income', 'icon': 'add_circle'},
];

// ----- Transactions -----
int _nextTransactionId = 10;

List<Map<String, dynamic>> transactions = [
  {
    'id': 1,
    'type': 'expense',
    'amount': 850.0,
    'categoryId': 1,
    'paymentMethodId': 3,
    'notes': 'Dinner at Barbeque Nation',
    'date': DateTime.now().subtract(const Duration(hours: 2)),
  },
  {
    'id': 2,
    'type': 'income',
    'amount': 75000.0,
    'categoryId': 9,
    'paymentMethodId': 2,
    'notes': 'June salary',
    'date': DateTime.now().subtract(const Duration(days: 1)),
  },
  {
    'id': 3,
    'type': 'expense',
    'amount': 320.0,
    'categoryId': 2,
    'paymentMethodId': 3,
    'notes': 'Uber to office',
    'date': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  },
  {
    'id': 4,
    'type': 'expense',
    'amount': 1200.0,
    'categoryId': 4,
    'paymentMethodId': 2,
    'notes': 'Electricity bill',
    'date': DateTime.now().subtract(const Duration(days: 2)),
  },
  {
    'id': 5,
    'type': 'transfer',
    'amount': 5000.0,
    'categoryId': null,
    'paymentMethodId': 2,
    'toPaymentMethodId': 1,
    'notes': 'Transfer to cash wallet',
    'date': DateTime.now().subtract(const Duration(days: 3)),
  },
  {
    'id': 6,
    'type': 'expense',
    'amount': 2500.0,
    'categoryId': 3,
    'paymentMethodId': 4,
    'notes': 'T-shirts from Myntra',
    'date': DateTime.now().subtract(const Duration(days: 4)),
  },
  {
    'id': 7,
    'type': 'income',
    'amount': 15000.0,
    'categoryId': 10,
    'paymentMethodId': 2,
    'notes': 'UI design project',
    'date': DateTime.now().subtract(const Duration(days: 5)),
  },
  {
    'id': 8,
    'type': 'expense',
    'amount': 499.0,
    'categoryId': 6,
    'paymentMethodId': 4,
    'notes': 'Netflix subscription',
    'date': DateTime.now().subtract(const Duration(days: 6)),
  },
  {
    'id': 9,
    'type': 'expense',
    'amount': 600.0,
    'categoryId': 5,
    'paymentMethodId': 2,
    'notes': 'Pharmacy — vitamins',
    'date': DateTime.now().subtract(const Duration(days: 7)),
  },
];

// ----- Budgets -----
int _nextBudgetId = 4;

List<Map<String, dynamic>> budgets = [
  {'id': 1, 'name': 'Food Budget', 'categoryId': 1, 'amount': 5000.0, 'spent': 2400.0, 'period': 'monthly', 'startDate': DateTime(2026, 6, 1)},
  {'id': 2, 'name': 'Shopping Limit', 'categoryId': 3, 'amount': 3000.0, 'spent': 2500.0, 'period': 'monthly', 'startDate': DateTime(2026, 6, 1)},
  {'id': 3, 'name': 'Entertainment', 'categoryId': 6, 'amount': 1000.0, 'spent': 499.0, 'period': 'monthly', 'startDate': DateTime(2026, 6, 1)},
];

// ----- Chats -----
int _nextChatId = 101;

List<Map<String, dynamic>> chats = _generateMockChats();

List<Map<String, dynamic>> _generateMockChats() {
  final List<Map<String, dynamic>> list = [];
  
  // 1. Specific mock chats for standard UX demo
  list.add({
    'id': 'chat-1',
    'userId': 'user-2', // Priya Kapoor (DM)
    'isGroup': false,
    'groupName': null,
    'memberIds': ['user-1', 'user-2'],
    'lastMessage': 'Sure! I\'ll transfer it today.',
    'lastMessageType': 'text',
    'lastTime': DateTime.now().subtract(const Duration(minutes: 15)),
    'unread': 2,
    'isPinned': true,
    'isMuted': false,
  });

  list.add({
    'id': 'chat-2',
    'userId': null, // group
    'isGroup': true,
    'groupName': 'Office Expense Split 🏢',
    'memberIds': ['user-1', 'user-2', 'user-3', 'user-4'],
    'lastMessage': 'Rahul: I\'ll pay the cab fare.',
    'lastMessageType': 'text',
    'lastTime': DateTime.now().subtract(const Duration(hours: 1)),
    'unread': 5,
    'isPinned': false,
    'isMuted': false,
  });

  // Generate 64 more direct conversations (to make 65 direct conversations total)
  for (int i = 3; i <= 65; i++) {
    final userId = (i % 4) + 2; 
    list.add({
      'id': 'chat-$i',
      'userId': 'user-$userId',
      'isGroup': false,
      'groupName': null,
      'memberIds': ['user-1', 'user-$userId'],
      'lastMessage': 'Hello, let\'s catch up later.',
      'lastMessageType': 'text',
      'lastTime': DateTime.now().subtract(Duration(hours: i * 2)),
      'unread': (i % 7 == 0) ? 1 : 0,
      'isPinned': false,
      'isMuted': false,
    });
  }

  // Generate 34 more group conversations (to make 35 group conversations total)
  for (int i = 66; i <= 100; i++) {
    final groupNum = i - 65;
    list.add({
      'id': 'chat-$i',
      'userId': null,
      'isGroup': true,
      'groupName': 'Group Project Expenses $groupNum 💰',
      'memberIds': ['user-1', 'user-2', 'user-3', 'user-4'],
      'lastMessage': 'Shared bill split update.',
      'lastMessageType': 'text',
      'lastTime': DateTime.now().subtract(Duration(hours: i * 3)),
      'unread': (i % 9 == 0) ? 3 : 0,
      'isPinned': false,
      'isMuted': false,
    });
  }

  return list;
}

// ----- Messages -----
int _nextMessageId = 1106;

List<Map<String, dynamic>> messages = _generateMockMessages();

List<Map<String, dynamic>> _generateMockMessages() {
  final List<Map<String, dynamic>> list = [];
  
  final List<String> imageUrls = [
    'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
    'https://images.unsplash.com/photo-1534972195531-d756b9bda9f2?w=800',
    'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800',
    'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=800',
  ];

  final List<String> videoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  ];

  final List<Map<String, String>> docs = [
    {'name': 'monthly_invoice.pdf', 'size': '145 KB', 'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'},
    {'name': 'financial_model_v2.xlsx', 'size': '2.4 MB', 'url': 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4Olv1'},
    {'name': 'vendor_contract.docx', 'size': '1.1 MB', 'url': 'https://calibre-ebook.com/downloads/demos/demo.docx'},
    {'name': 'receipt_bundle.zip', 'size': '15.8 MB', 'url': 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-zip-file.zip'},
    {'name': 'notes.txt', 'size': '8 KB', 'url': 'https://www.w3.org/TR/PNG/iso_8859-1.txt'},
  ];

  // 1. Generate 1000 messages for Priya Kapoor (chatId: 1)
  for (int i = 1; i <= 1000; i++) {
    final senderId = (i % 2 == 1) ? 1 : 2;
    String type = 'text';
    String text = 'Message #$i in conversation with Priya';
    String? mediaCaption;
    String? fileName;
    String? fileSize;
    String? duration;

    if (i % 60 == 0) {
      type = 'video';
      text = videoUrls[(i ~/ 60) % videoUrls.length];
      mediaCaption = 'Office Video Clip ${(i ~/ 60)}';
      duration = '0:15';
    } else if (i % 30 == 0) {
      type = 'document';
      final doc = docs[(i ~/ 30) % docs.length];
      text = doc['url']!;
      fileName = doc['name'];
      fileSize = doc['size'];
    } else if (i % 15 == 0) {
      type = 'image';
      text = imageUrls[(i ~/ 15) % imageUrls.length];
      mediaCaption = 'Receipt and billing image ${(i ~/ 15)}';
    }

    list.add({
      'id': 'msg-$i',
      'chatId': 'chat-1',
      'senderId': 'user-$senderId',
      'type': type,
      'text': text,
      'mediaCaption': mediaCaption,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'time': DateTime.now().subtract(Duration(minutes: 1000 - i)),
      'status': 'read',
    });
  }

  // 2. Generate standard messages for Chat 2 (Group)
  final groupBase = [
    {
      'id': 'msg-1001', 'chatId': 'chat-2', 'senderId': 'user-3',
      'type': 'text',
      'text': 'Hey team, let\'s settle the office lunch.',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'status': 'read',
    },
    {
      'id': 'msg-1002', 'chatId': 'chat-2', 'senderId': 'user-4',
      'type': 'text',
      'text': 'How much was the total?',
      'time': DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
      'status': 'read',
    },
    {
      'id': 'msg-1003', 'chatId': 'chat-2', 'senderId': 'user-1',
      'type': 'document',
      'text': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      'fileName': 'lunch_bill.pdf',
      'fileSize': '124 KB',
      'time': DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      'status': 'read',
    },
    {
      'id': 'msg-1003-xlsx', 'chatId': 'chat-2', 'senderId': 'user-3',
      'type': 'document',
      'text': 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4Olv1',
      'fileName': 'office_expenses_q2.xlsx',
      'fileSize': '2.1 MB',
      'time': DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
      'status': 'read',
    },
    {
      'id': 'msg-1004', 'chatId': 'chat-2', 'senderId': 'user-3',
      'type': 'text',
      'text': '₹1,200 total. Split 4 ways = ₹300 each.',
      'time': DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
      'status': 'read',
    },
    {
      'id': 'msg-1005', 'chatId': 'chat-2', 'senderId': 'user-1',
      'type': 'payment_request',
      'text': '₹ Payment Request',
      'amount': 300.0,
      'paymentNote': 'Office lunch split',
      'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      'status': 'delivered',
    },
    {
      'id': 'msg-1006', 'chatId': 'chat-2', 'senderId': 'user-4',
      'type': 'audio',
      'text': '🎤 Voice message',
      'duration': '0:12',
      'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      'status': 'read',
    },
    {
      'id': 'msg-1006-video', 'chatId': 'chat-2', 'senderId': 'user-2',
      'type': 'video',
      'text': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'mediaCaption': 'Short office review video',
      'duration': '0:15',
      'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      'status': 'read',
    },
    {
      'id': 'msg-1006-image', 'chatId': 'chat-2', 'senderId': 'user-2',
      'type': 'image',
      'text': 'https://images.unsplash.com/photo-1534972195531-d756b9bda9f2?w=800',
      'mediaCaption': 'Workspace snap',
      'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
      'status': 'read',
    },
    {
      'id': 'msg-1007', 'chatId': 'chat-2', 'senderId': 'user-3',
      'type': 'text',
      'text': 'I\'ll pay the cab fare.',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'status': 'delivered',
    },
  ];
  list.addAll(groupBase);

  // 3. Generate messages for the other chats (3 to 100)
  for (int i = 1008; i <= 1105; i++) {
    final chatId = (i - 1008) + 3;
    final senderId = (i % 2 == 0) ? 1 : 2;
    list.add({
      'id': 'msg-$i',
      'chatId': 'chat-$chatId',
      'senderId': 'user-$senderId',
      'type': 'text',
      'text': 'Automated message for conversation $chatId',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'read',
    });
  }

  return list;
}

// ----- Notifications -----
// ignore: unused_element — reserved for future insertNotification helper
int _nextNotificationId = 4;

List<Map<String, dynamic>> notifications = [
  {'id': 1, 'title': 'Budget Alert', 'body': 'Shopping budget is 83% used this month.', 'isRead': false, 'time': DateTime.now().subtract(const Duration(hours: 1))},
  {'id': 2, 'title': 'New Message', 'body': 'Priya Kapoor sent you a message.', 'isRead': false, 'time': DateTime.now().subtract(const Duration(minutes: 15))},
  {'id': 3, 'title': 'Transaction Recorded', 'body': 'Expense of ₹850 added successfully.', 'isRead': true, 'time': DateTime.now().subtract(const Duration(days: 1))},
];

// ============================================================
// CRUD helpers
// ============================================================

// --- Transactions ---
Map<String, dynamic> insertTransaction(Map<String, dynamic> data) {
  final row = {...data, 'id': _nextTransactionId++, 'date': data['date'] ?? DateTime.now()};
  transactions.insert(0, row);
  return row;
}

void updateTransaction(int id, Map<String, dynamic> data) {
  final idx = transactions.indexWhere((t) => t['id'] == id);
  if (idx != -1) transactions[idx] = {...transactions[idx], ...data};
}

void deleteTransaction(int id) {
  transactions.removeWhere((t) => t['id'] == id);
}

// --- Budgets ---
Map<String, dynamic> insertBudget(Map<String, dynamic> data) {
  final row = {...data, 'id': _nextBudgetId++};
  budgets.add(row);
  return row;
}

void updateBudget(int id, Map<String, dynamic> data) {
  final idx = budgets.indexWhere((b) => b['id'] == id);
  if (idx != -1) budgets[idx] = {...budgets[idx], ...data};
}

void deleteBudget(int id) {
  budgets.removeWhere((b) => b['id'] == id);
}

// --- Payment Methods ---
int _nextPmId = 5;

Map<String, dynamic> insertPaymentMethod(Map<String, dynamic> data) {
  final row = {...data, 'id': _nextPmId++, 'balance': data['balance'] ?? 0.0};
  paymentMethods.add(row);
  return row;
}

void updatePaymentMethod(int id, Map<String, dynamic> data) {
  final idx = paymentMethods.indexWhere((p) => p['id'] == id);
  if (idx != -1) paymentMethods[idx] = {...paymentMethods[idx], ...data};
}

void deletePaymentMethod(int id) {
  paymentMethods.removeWhere((p) => p['id'] == id);
}

// --- Categories ---
int _nextCatId = 15;

Map<String, dynamic> insertCategory(Map<String, dynamic> data) {
  final row = {...data, 'id': _nextCatId++};
  categories.add(row);
  return row;
}

void updateCategory(int id, Map<String, dynamic> data) {
  final idx = categories.indexWhere((c) => c['id'] == id);
  if (idx != -1) categories[idx] = {...categories[idx], ...data};
}

void deleteCategory(int id) {
  categories.removeWhere((c) => c['id'] == id);
}

// --- Chats ---
// --- Chats -----
int _chatUuidCounter = 101;

AcChatConversation insertConversation(AcChatConversation data, [String? targetUserId]) {
  final dataMap = data.toJson();
  if (targetUserId != null) {
    dataMap['userId'] = targetUserId;
  }
  final row = {...dataMap, 'id': 'chat-${_chatUuidCounter++}', 'lastTime': DateTime.now(), 'unread': 0};
  chats.add(row);
  return AcChatConversation.instanceFromJson(jsonData: row);
}

List<AcChatConversationUser> getConversationUsers(String conversationId) {
  final convMap = chats.firstWhere((c) => c['id'].toString() == conversationId, orElse: () => {});
  if (convMap.isEmpty) return [];
  List<AcChatConversationUser> list = [];
  if (convMap['isGroup'] == true) {
    for (var mId in (convMap['memberIds'] as List? ?? [])) {
      list.add(AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = mId.toString());
    }
  } else {
    list.add(AcChatConversationUser()
      ..conversationId = conversationId
      ..userId = '1');
    if (convMap['userId'] != null) {
      list.add(AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = convMap['userId'].toString());
    }
  }
  return list;
}

// --- Messages ---
int _messageUuidCounter = 1106;

AcChatMessage insertMessage(AcChatMessage data) {
  final dataMap = data.toJson();
  final row = {
    ...dataMap,
    'id': 'msg-${_messageUuidCounter++}',
    'time': DateTime.now(),
    'type': dataMap['type'] ?? 'text',
    'status': 'sent',
  };
  messages.add(row);
  // Update chat last message
  final chatId = row['chatId'];
  final chatIdx = chats.indexWhere((c) => c['id'].toString() == chatId.toString());
  if (chatIdx != -1) {
    chats[chatIdx] = {
      ...chats[chatIdx],
      'lastMessage': row['text'],
      'lastMessageType': row['type'] ?? 'text',
      'lastTime': DateTime.now(),
    };
  }
  return AcChatMessage.instanceFromJson(jsonData: row);
}

void updateMessage(String id, Map<String, dynamic> data) {
  final idx = messages.indexWhere((m) => m['id'].toString() == id.toString());
  if (idx != -1) {
    messages[idx] = {...messages[idx], ...data};
  }
}

// --- Notifications ---
void markNotificationRead(int id) {
  final idx = notifications.indexWhere((n) => n['id'] == id);
  if (idx != -1) notifications[idx] = {...notifications[idx], 'isRead': true};
}

void deleteNotification(int id) {
  notifications.removeWhere((n) => n['id'] == id);
}

void markAllNotificationsRead() {
  for (int i = 0; i < notifications.length; i++) {
    notifications[i] = {...notifications[i], 'isRead': true};
  }
}

// ============================================================
// Lookup helpers
// ============================================================

Map<String, dynamic>? getCategoryById(int? id) {
  if (id == null) return null;
  try {
    return categories.firstWhere((c) => c['id'] == id);
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? getPaymentMethodById(int? id) {
  if (id == null) return null;
  try {
    return paymentMethods.firstWhere((p) => p['id'] == id);
  } catch (_) {
    return null;
  }
}

AcChatUser? getUserById(String? id) {
  if (id == null) return null;
  if (id == currentUser['id'].toString()) return AcChatUser.instanceFromJson(jsonData: currentUser);
  try {
    final userMap = users.firstWhere((u) => u['id'].toString() == id);
    return AcChatUser.instanceFromJson(jsonData: userMap);
  } catch (_) {
    return null;
  }
}

// ============================================================
// Computed helpers
// ============================================================

double getTotalIncome() {
  return transactions
      .where((t) => t['type'] == 'income')
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));
}

double getTotalExpense() {
  return transactions
      .where((t) => t['type'] == 'expense')
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));
}

double getCurrentBalance() {
  return getTotalIncome() - getTotalExpense();
}

double getTodayIncome() {
  final today = DateTime.now();
  return transactions
      .where((t) =>
          t['type'] == 'income' &&
          (t['date'] as DateTime).day == today.day &&
          (t['date'] as DateTime).month == today.month &&
          (t['date'] as DateTime).year == today.year)
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));
}

double getTodayExpense() {
  final today = DateTime.now();
  return transactions
      .where((t) =>
          t['type'] == 'expense' &&
          (t['date'] as DateTime).day == today.day &&
          (t['date'] as DateTime).month == today.month &&
          (t['date'] as DateTime).year == today.year)
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));
}

double getMonthlyIncome() {
  final now = DateTime.now();
  return transactions
      .where((t) =>
          t['type'] == 'income' &&
          (t['date'] as DateTime).month == now.month &&
          (t['date'] as DateTime).year == now.year)
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));
}

double getMonthlyExpense() {
  final now = DateTime.now();
  return transactions
      .where((t) =>
          t['type'] == 'expense' &&
          (t['date'] as DateTime).month == now.month &&
          (t['date'] as DateTime).year == now.year)
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));
}
