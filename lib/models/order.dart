class OrderItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}

class Order {
  final int orderId;
  final String client;
  final String createdAt;
  final double total;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.client,
    required this.createdAt,
    required this.total,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      client: json['client'],
      createdAt: json['createdAt'],
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}
