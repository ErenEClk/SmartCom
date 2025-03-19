import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';
import 'package:smart_community_ai/core/services/payment_service.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  static const String routeName = '/payment';
  
  final String paymentId;
  
  const PaymentScreen({
    Key? key,
    required this.paymentId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();
  bool _isLoading = false;
  bool _isProcessing = false;
  
  late PaymentService _paymentService;
  late PaymentProvider _paymentProvider;
  late AuthProvider _authProvider;
  
  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(isTestMode: true);
    _paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _loadPaymentDetails();
  }
  
  Future<void> _loadPaymentDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _paymentProvider.getPaymentById(widget.paymentId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ödeme detayları yüklenirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }
  
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Ödeme bilgisini güvenli bir şekilde al
      final payment = _paymentProvider.payments.firstWhere(
        (p) => p.id == widget.paymentId,
        orElse: () {
          throw Exception('Ödeme bulunamadı');
        },
      );
      
      // Kullanıcı bilgisini güvenli bir şekilde al
      final user = _authProvider.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }
      
      // Kart bilgilerini hazırla
      final cardInfo = {
        'cardHolderName': _cardHolderController.text,
        'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
        'expireMonth': _expiryMonthController.text,
        'expireYear': _expiryYearController.text,
        'cvc': _cvcController.text,
      };
      
      debugPrint('Ödeme işlemi başlatılıyor...');
      debugPrint('Kullanıcı: ${user.name} (${user.email})');
      debugPrint('Ödeme: ${payment.title} - ${payment.amount} TL');
      
      // Test simülasyonunu kullan
      final result = await _paymentService.simulatePayment(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        amount: payment.amount,
        description: payment.title,
        cardInfo: cardInfo,
      );
      
      debugPrint('Ödeme sonucu: $result');
      
      if (result['status'] == 'success') {
        // 3D Secure sayfasını göster
        if (result['threeDSHtmlContent'] != null) {
          if (mounted) {
            await _show3DSecureDialog(result['threeDSHtmlContent']);
          }
          
          // Ödeme işlemini tamamla
          final paymentResult = await _paymentProvider.makePayment(widget.paymentId);
          
          if (mounted) {
            if (paymentResult) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ödeme başarıyla tamamlandı')),
              );
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ödeme işlemi başarısız: ${_paymentProvider.error ?? "Bilinmeyen hata"}')),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ödeme işlemi başarısız: ${result['errorMessage'] ?? 'Bilinmeyen hata'}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Ödeme işlemi hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ödeme işlemi sırasında hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // 3D Secure sayfasını göstermek için dialog
  Future<void> _show3DSecureDialog(String htmlContent) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('3D Secure Doğrulama'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Text('3D Secure doğrulama sayfası simülasyonu'),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text('3D Secure Doğrulama Sayfası'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Doğrula'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Ödeme işlemi devam ederken geri tuşunu engelle
        if (_isProcessing) {
          return false;
        }
        
        // Normal durumda geri tuşuna izin ver
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Ödeme Yap',
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<PaymentProvider>(
                builder: (context, paymentProvider, child) {
                  final payment = paymentProvider.payments.firstWhere(
                    (p) => p.id == widget.paymentId,
                    orElse: () => throw Exception('Ödeme bulunamadı'),
                  );
                  
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPaymentDetails(payment),
                          SizedBox(height: 24.h),
                          _buildCardForm(),
                          SizedBox(height: 32.h),
                          _buildPaymentButton(),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
  
  Widget _buildPaymentDetails(dynamic payment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödeme Detayları',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow('Başlık', payment.title),
            _buildDetailRow('Açıklama', payment.description),
            _buildDetailRow('Tutar', '${payment.amount} TL'),
            _buildDetailRow('Son Ödeme Tarihi', payment.dueDate.split('T')[0]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCardForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kart Bilgileri',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _fillTestCardInfo,
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Test Kartı Kullan'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Kart Numarası',
                hintText: '1234 5678 9012 3456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kart numarası gerekli';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: 'Kart Sahibi',
                hintText: 'AD SOYAD',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kart sahibi gerekli';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryMonthController,
                    decoration: InputDecoration(
                      labelText: 'Ay',
                      hintText: '12',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ay gerekli';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _expiryYearController,
                    decoration: InputDecoration(
                      labelText: 'Yıl',
                      hintText: '25',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Yıl gerekli';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _cvcController,
                    decoration: InputDecoration(
                      labelText: 'CVC',
                      hintText: '123',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'CVC gerekli';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _fillTestCardInfo() {
    final testCardInfo = _paymentService.getTestCardInfo();
    setState(() {
      _cardNumberController.text = testCardInfo['cardNumber'] ?? '';
      _cardHolderController.text = testCardInfo['cardHolderName'] ?? '';
      _expiryMonthController.text = testCardInfo['expireMonth'] ?? '';
      _expiryYearController.text = testCardInfo['expireYear'] ?? '';
      _cvcController.text = testCardInfo['cvc'] ?? '';
    });
  }
  
  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: _isProcessing
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Ödeme Yap',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
} 