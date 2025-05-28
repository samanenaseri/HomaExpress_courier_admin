class DashboardModel {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int activeCouriers;
  final List<DailyStats> dailyStats;

  DashboardModel({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.activeCouriers,
    required this.dailyStats,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      activeCouriers: json['activeCouriers'] ?? 0,
      dailyStats: (json['dailyStats'] as List?)
              ?.map((e) => DailyStats.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DailyStats {
  final String date;
  final int orders;

  DailyStats({
    required this.date,
    required this.orders,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] ?? '',
      orders: json['orders'] ?? 0,
    );
  }
} 