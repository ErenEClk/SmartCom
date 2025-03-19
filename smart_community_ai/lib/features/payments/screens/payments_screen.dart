import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödemelerim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bekleyen Ödemeler'),
            Tab(text: 'Ödeme Geçmişi'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadPayments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ödemeler yenileniyor...')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: Consumer<PaymentProvider>(
          builder: (context, paymentProvider, child) {
            if (paymentProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildPendingPayments(paymentProvider),
                _buildPaymentHistory(paymentProvider),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Ödeme yap
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ödeme özelliği yakında eklenecektir.'),
            ),
          );
        },
        icon: const Icon(Icons.payment),
        label: const Text('Ödeme Yap'),
      ),
    );
  }

  Widget _buildPendingPayments(PaymentProvider paymentProvider) {
    final pendingPayments = paymentProvider.pendingPayments;
    
    if (pendingPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64.sp,
              color: Colors.green,
            ),
            SizedBox(height: 16.h),
            Text(
              'Bekleyen ödemeniz bulunmamaktadır',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                  ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: pendingPayments.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        final payment = pendingPayments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: InkWell(
            onTap: () => _navigateToPaymentDetail(payment.id),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Bekliyor',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    payment.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${payment.amount.toStringAsFixed(2)} TL',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToPaymentDetail(payment.id),
                        child: const Text('Ödeme Yap'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistory(PaymentProvider paymentProvider) {
    final paidPayments = paymentProvider.paidPayments;
    
    if (paidPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'Ödeme geçmişi bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: paidPayments.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        final payment = paidPayments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: InkWell(
            onTap: () => _navigateToPaymentDetail(payment.id),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Ödendi',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    payment.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${payment.amount.toStringAsFixed(2)} TL',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Ödeme Tarihi: ${payment.paidAt?.split('T')[0] ?? ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Ödeme detay sayfasına yönlendirme
  void _navigateToPaymentDetail(String paymentId) {
    Navigator.pushNamed(
      context,
      '/payment-detail',
      arguments: {'paymentId': paymentId},
    ).then((value) {
      // Sayfa geri döndüğünde ödemeleri yenile
      if (value == true) {
        _loadPayments();
      }
    });
  }
} 