import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';
import 'package:smart_community_ai/core/widgets/custom_text_field.dart';
import 'package:smart_community_ai/core/services/api_service.dart';

class AdminPaymentsScreen extends StatefulWidget {
  static const String routeName = '/admin-payments';

  const AdminPaymentsScreen({Key? key}) : super(key: key);

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      _loadPayments();
      _loadTotalPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      await paymentProvider.fetchPayments();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ödemeler yüklenirken hata: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödemeler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _loadTotalPayments() async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.fetchTotalPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ödeme Yönetimi',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm Ödemeler'),
            Tab(text: 'Bekleyen'),
            Tab(text: 'Ödenenler'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPaymentSummary(),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Ödeme ara...',
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (value) {
                      // Arama işlemi
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                CustomButton(
                  text: 'Yeni Ödeme',
                  onPressed: () {
                    _showAddPaymentDialog();
                  },
                  type: ButtonType.primary,
                  isFullWidth: false,
                  width: 120.w,
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                if (paymentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentsList(paymentProvider.payments),
                    _buildPaymentsList(paymentProvider.pendingPayments),
                    _buildPaymentsList(paymentProvider.paidPayments),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentSummary() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        final totalPayments = paymentProvider.totalPayments;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          margin: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ödeme Özeti',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    'Toplam Ödeme',
                    '${totalPayments?['count'] ?? 0} adet',
                    Icons.payment,
                  ),
                  _buildSummaryItem(
                    'Toplam Tutar',
                    '${totalPayments?['total'] ?? 0} TL',
                    Icons.account_balance_wallet,
                  ),
                  _buildSummaryItem(
                    'Bekleyen Ödemeler',
                    '${paymentProvider.pendingPayments.length} adet',
                    Icons.pending_actions,
                  ),
                  _buildSummaryItem(
                    'Bekleyen Tutar',
                    '${paymentProvider.totalPendingAmount.toStringAsFixed(2)} TL',
                    Icons.money_off,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24.sp,
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsList(List<dynamic> payments) {
    // Yükleme durumunda göster
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    final filteredPayments = _searchController.text.isEmpty
        ? payments
        : payments.where((payment) =>
            payment.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            payment.description.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    if (filteredPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              payments.isEmpty ? 'Henüz hiç ödeme eklenmemiş' : 'Aramanızla eşleşen ödeme bulunamadı',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16.h),
            if (payments.isEmpty)
              ElevatedButton.icon(
                onPressed: () => _showAddPaymentDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Ödeme Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: filteredPayments.length,
        itemBuilder: (context, index) {
          final payment = filteredPayments[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: payment.isPaid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          payment.isPaid ? 'Ödendi' : 'Bekliyor',
                          style: TextStyle(
                            color: payment.isPaid ? Colors.green : Colors.red,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          payment.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Kullanıcı: ${payment.userId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Son Ödeme: ${_formatDate(payment.dueDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () {
                              _showEditPaymentDialog(payment);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteConfirmationDialog(payment);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddPaymentDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final userIdController = TextEditingController();
    final dueDateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ödeme Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: titleController,
                labelText: 'Başlık',
                hintText: 'Ödeme başlığı',
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: descriptionController,
                labelText: 'Açıklama',
                hintText: 'Ödeme açıklaması',
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: amountController,
                labelText: 'Tutar',
                hintText: 'Ödeme tutarı',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: userIdController,
                labelText: 'Kullanıcı ID',
                hintText: 'Ödeme yapacak kullanıcının ID\'si',
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: dueDateController,
                labelText: 'Son Ödeme Tarihi',
                hintText: 'YYYY-MM-DD',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      dueDateController.text = date.toIso8601String().split('T')[0];
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          Consumer<PaymentProvider>(
            builder: (context, paymentProvider, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      amountController.text.isEmpty ||
                      userIdController.text.isEmpty ||
                      dueDateController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tüm alanları doldurun')),
                    );
                    return;
                  }
                  
                  try {
                    double amount = double.parse(amountController.text);
                    
                    final success = await paymentProvider.createPayment(
                      title: titleController.text,
                      description: descriptionController.text,
                      amount: amount,
                      userId: userIdController.text,
                      dueDate: dueDateController.text,
                    );
                    
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ödeme başarıyla oluşturuldu'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadPayments();
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: ${paymentProvider.error ?? 'Bilinmeyen hata'}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: paymentProvider.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Ekle'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditPaymentDialog(dynamic payment) {
    final titleController = TextEditingController(text: payment.title);
    final descriptionController = TextEditingController(text: payment.description);
    final amountController = TextEditingController(text: payment.amount.toString());
    final dueDateController = TextEditingController(text: payment.dueDate);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: titleController,
                labelText: 'Başlık',
                hintText: 'Ödeme başlığı',
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: descriptionController,
                labelText: 'Açıklama',
                hintText: 'Ödeme açıklaması',
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: amountController,
                labelText: 'Tutar (TL)',
                hintText: '0.00',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: dueDateController,
                labelText: 'Son Ödeme Tarihi',
                hintText: 'YYYY-MM-DD',
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(payment.dueDate),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    dueDateController.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  amountController.text.isEmpty ||
                  dueDateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
              paymentProvider.updatePaymentWithData(
                payment.id,
                {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'amount': double.parse(amountController.text),
                  'dueDate': dueDateController.text,
                }
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ödeme başarıyla güncellendi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(dynamic payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödemeyi Sil'),
        content: Text('${payment.title} ödemesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              
              Navigator.pop(context); // Dialog'u kapat
              
              final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
              final success = await paymentProvider.deletePayment(payment.id);

              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Ödeme başarıyla silindi' : 'Ödeme silinemedi: ${paymentProvider.error}'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
} 