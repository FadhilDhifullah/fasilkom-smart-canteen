class SalesReport {
  final double totalSales;
  final int totalTransactions;
  final int totalItemsSold;
  final Map<String, double> categorySales;

  SalesReport({
    required this.totalSales,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.categorySales,
  });
}
