const paymentService = require('../services/payment.service');
const { validationResult } = require('express-validator');

// Tüm ödemeleri getir
const getAllPayments = async (req, res) => {
  try {
    const payments = await paymentService.getAllPayments();
    
    res.status(200).json({
      success: true,
      count: payments.length,
      data: payments
    });
  } catch (error) {
    console.error('Ödemeler alınırken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Kullanıcının ödemelerini getir
const getUserPayments = async (req, res) => {
  try {
    const userId = req.params.userId || req.user.id;
    
    const payments = await paymentService.getUserPayments(userId);
    
    res.status(200).json({
      success: true,
      count: payments.length,
      data: payments
    });
  } catch (error) {
    console.error('Kullanıcı ödemeleri alınırken hata:', error);
    
    if (error.message.includes('Geçersiz kullanıcı ID')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Ödeme detaylarını getir
const getPaymentById = async (req, res) => {
  try {
    const paymentId = req.params.id;
    
    const payment = await paymentService.getPaymentById(paymentId);
    
    res.status(200).json({
      success: true,
      data: payment
    });
  } catch (error) {
    console.error('Ödeme detayları alınırken hata:', error);
    
    if (error.message.includes('Geçersiz ödeme ID') || error.message.includes('Ödeme bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Toplam ödeme istatistiklerini getir
const getTotalPayments = async (req, res) => {
  try {
    const stats = await paymentService.getTotalPayments();
    
    res.status(200).json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Ödeme istatistikleri alınırken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Yeni ödeme oluştur
const createPayment = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const paymentData = {
      userId: req.body.userId,
      title: req.body.title,
      description: req.body.description,
      amount: req.body.amount,
      dueDate: req.body.dueDate,
      category: req.body.category
    };
    
    const payment = await paymentService.createPayment(paymentData);
    
    res.status(201).json({
      success: true,
      message: 'Ödeme başarıyla oluşturuldu',
      data: payment
    });
  } catch (error) {
    console.error('Ödeme oluşturulurken hata:', error);
    
    if (error.message.includes('Geçersiz kullanıcı ID')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Ödeme yap
const makePayment = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const paymentId = req.params.id;
    const paymentData = {
      cardNumber: req.body.cardNumber,
      cardHolderName: req.body.cardHolderName,
      expiryMonth: req.body.expiryMonth,
      expiryYear: req.body.expiryYear,
      cvc: req.body.cvc
    };
    
    const result = await paymentService.makePayment(paymentId, paymentData, req.user.id);
    
    res.status(200).json({
      success: true,
      message: 'Ödeme başarıyla tamamlandı',
      data: result
    });
  } catch (error) {
    console.error('Ödeme yapılırken hata:', error);
    
    if (error.message.includes('Geçersiz ödeme ID') || 
        error.message.includes('Ödeme bulunamadı') ||
        error.message.includes('Bu ödemeyi yapma yetkiniz yok')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Ödeme işlemi başarısız')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Ödeme güncelle
const updatePayment = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const paymentId = req.params.id;
    const updateData = {
      title: req.body.title,
      description: req.body.description,
      amount: req.body.amount,
      dueDate: req.body.dueDate,
      category: req.body.category,
      status: req.body.status
    };
    
    const payment = await paymentService.updatePayment(paymentId, updateData);
    
    res.status(200).json({
      success: true,
      message: 'Ödeme başarıyla güncellendi',
      data: payment
    });
  } catch (error) {
    console.error('Ödeme güncellenirken hata:', error);
    
    if (error.message.includes('Geçersiz ödeme ID') || error.message.includes('Ödeme bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Ödeme sil
const deletePayment = async (req, res) => {
  try {
    const paymentId = req.params.id;
    
    await paymentService.deletePayment(paymentId);
    
    res.status(200).json({
      success: true,
      message: 'Ödeme başarıyla silindi'
    });
  } catch (error) {
    console.error('Ödeme silinirken hata:', error);
    
    if (error.message.includes('Geçersiz ödeme ID') || error.message.includes('Ödeme bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  getAllPayments,
  getUserPayments,
  getPaymentById,
  getTotalPayments,
  createPayment,
  makePayment,
  updatePayment,
  deletePayment
}; 