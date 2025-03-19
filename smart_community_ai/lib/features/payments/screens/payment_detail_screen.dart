import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/payment_model.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';

class PaymentDetailScreen extends StatefulWidget {
  static const String routeName = '/payment-detail';

  final String paymentId;

  const PaymentDetailScreen({
    Key? key,
    required this.paymentId,
  }) : super(key: key);

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  bool _isLoading = false;
  PaymentModel? _payment;

  @override
  void initState() {
    super.initState();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final payment = paymentProvider.payments.firstWhere(
      (p) => p.id == widget.paymentId,
      orElse: () => PaymentModel(
        id: '',
        title: '',
        description: '',
        amount: 0,
        userId: '',
        dueDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );

    setState(() {
      _payment = payment;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_payment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ödeme Detayı'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme Detayı'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentStatusCard(),
            SizedBox(height: 24.h),
            _buildPaymentDetailsCard(),
            SizedBox(height: 24.h),
            if (!_payment!.isPaid) _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: _payment!.isPaid ? Colors.green[50] : Colors.orange[50],
        ),
        child: Column(
          children: [
            Icon(
              _payment!.isPaid ? Icons.check_circle : Icons.pending,
              size: 48.sp,
              color: _payment!.isPaid ? Colors.green : Colors.orange,
            ),
            SizedBox(height: 8.h),
            Text(
              _payment!.isPaid ? 'Ödendi' : 'Ödenmedi',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _payment!.isPaid ? Colors.green[800] : Colors.orange[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _payment!.isPaid
                  ? 'Ödeme tarihi: ${_formatDate(_payment!.paidAt!)}'
                  : 'Son ödeme tarihi: ${_formatDate(_payment!.dueDate)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Başlık', _payment!.title),
            _buildDivider(),
            _buildDetailItem('Açıklama', _payment!.description),
            _buildDivider(),
            _buildDetailItem(
              'Tutar',
              '${_payment!.amount.toStringAsFixed(2)} TL',
              valueStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            _buildDivider(),
            _buildDetailItem(
              'Oluşturulma Tarihi',
              _formatDate(_payment!.createdAt),
            ),
            if (_payment!.isPaid && _payment!.paidAt != null) ...[
              _buildDivider(),
              _buildDetailItem(
                'Ödeme Tarihi',
                _formatDate(_payment!.paidAt!),
                valueStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      height: 24.h,
    );
  }

  Widget _buildPaymentButton() {
    return CustomButton(
      text: 'Ödeme Yap',
      isLoading: _isLoading,
      onPressed: _makePayment,
    );
  }

  Future<void> _makePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ödeme ekranına yönlendir
      final result = await Navigator.pushNamed(
        context,
        '/payment',
        arguments: {'paymentId': _payment!.id},
      );
      
      // Ödeme başarılı ise
      if (result == true) {
        // Ödeme bilgisini yeniden yükle
        await _loadPayment();
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeme başarıyla tamamlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ödeme işlemi sırasında hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
} 