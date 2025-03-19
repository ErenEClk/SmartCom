const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middlewares/auth');
const { 
  getAllPayments, 
  getUserPayments, 
  getPaymentById, 
  getTotalPayments, 
  createPayment, 
  makePayment, 
  updatePayment, 
  deletePayment 
} = require('../controllers/payment.controller');
const { check } = require('express-validator');

// Tüm ödemeleri getir (sadece admin)
router.get('/', protect, authorize('admin'), getAllPayments);

// Kullanıcının ödemelerini getir
router.get('/user', protect, getUserPayments);

// Belirli bir kullanıcının ödemelerini getir (sadece admin)
router.get('/user/:userId', protect, authorize('admin'), getUserPayments);

// Ödeme detaylarını getir
router.get('/:id', protect, getPaymentById);

// Toplam ödeme istatistiklerini getir (sadece admin)
router.get('/stats/total', protect, authorize('admin'), getTotalPayments);

// Yeni ödeme oluştur (sadece admin)
router.post(
  '/', 
  protect, 
  authorize('admin'),
  [
    check('userId', 'Kullanıcı ID gereklidir').not().isEmpty(),
    check('title', 'Başlık gereklidir').not().isEmpty(),
    check('amount', 'Tutar gereklidir ve sayı olmalıdır').isNumeric(),
    check('dueDate', 'Son ödeme tarihi geçerli bir tarih olmalıdır').optional().isISO8601()
  ],
  createPayment
);

// Ödeme yap
router.post(
  '/:id/pay', 
  protect,
  [
    check('cardNumber', 'Kart numarası gereklidir').not().isEmpty(),
    check('cardHolderName', 'Kart sahibi adı gereklidir').not().isEmpty(),
    check('expiryMonth', 'Son kullanma ayı gereklidir').not().isEmpty(),
    check('expiryYear', 'Son kullanma yılı gereklidir').not().isEmpty(),
    check('cvc', 'CVC kodu gereklidir').not().isEmpty()
  ],
  makePayment
);

// Ödeme güncelle (sadece admin)
router.put(
  '/:id', 
  protect, 
  authorize('admin'),
  [
    check('title', 'Başlık gereklidir').optional().not().isEmpty(),
    check('amount', 'Tutar sayı olmalıdır').optional().isNumeric(),
    check('dueDate', 'Son ödeme tarihi geçerli bir tarih olmalıdır').optional().isISO8601(),
    check('status', 'Durum geçerli olmalıdır').optional().isIn(['pending', 'paid', 'overdue', 'cancelled'])
  ],
  updatePayment
);

// Ödeme sil (sadece admin)
router.delete('/:id', protect, authorize('admin'), deletePayment);

module.exports = router; 