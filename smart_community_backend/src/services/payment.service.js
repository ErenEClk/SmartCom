const Payment = require('../models/payment.model');
const User = require('../models/user.model');
const mongoose = require('mongoose');
const axios = require('axios');
const crypto = require('crypto');

// İyzico API bilgileri
const IYZICO_API_KEY = process.env.IYZICO_API_KEY || 'sandbox-yElAsB1MwMSp4q3R1aTmVxa2dgbSza0C';
const IYZICO_SECRET_KEY = process.env.IYZICO_SECRET_KEY || 'sandbox-OfLB37nYAKeGTj2Rjc2MCCMXjYDRdilH';
const IYZICO_BASE_URL = process.env.IYZICO_BASE_URL || 'https://sandbox-api.iyzipay.com';

// İyzico için hash oluşturma
const generateAuthorizationHeader = (request) => {
  try {
    const randomString = new Date().getTime().toString();
    const requestString = JSON.stringify(request);
    
    const hashStr = IYZICO_API_KEY + randomString + IYZICO_SECRET_KEY + requestString;
    const hash = crypto.createHash('sha1').update(hashStr).digest('base64');
    
    return {
      'Authorization': `IYZWS ${IYZICO_API_KEY}:${hash}`,
      'x-iyzi-rnd': randomString,
      'Content-Type': 'application/json'
    };
  } catch (error) {
    console.error('İyzico hash oluşturma hatası:', error);
    throw new Error('İyzico hash oluşturma hatası');
  }
};

/**
 * Tüm ödemeleri getir
 * @returns {Promise<Array>} Ödemeler listesi
 */
const getAllPayments = async () => {
  try {
    return await Payment.find().sort({ createdAt: -1 });
  } catch (error) {
    console.error('Ödemeler alınırken servis hatası:', error);
    throw new Error('Ödemeler alınırken bir hata oluştu');
  }
};

/**
 * Kullanıcının ödemelerini getir
 * @param {string} userId - Kullanıcı ID
 * @returns {Promise<Array>} Kullanıcının ödemeleri
 */
const getUserPayments = async (userId) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(userId) && userId !== 'user1') {
      throw new Error('Geçersiz kullanıcı ID');
    }
    
    return await Payment.find({ userId }).sort({ createdAt: -1 });
  } catch (error) {
    console.error('Kullanıcı ödemeleri alınırken servis hatası:', error);
    throw new Error('Kullanıcı ödemeleri alınırken bir hata oluştu');
  }
};

/**
 * Ödeme detayını getir
 * @param {string} paymentId - Ödeme ID
 * @returns {Promise<Object>} Ödeme detayı
 */
const getPaymentById = async (paymentId) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(paymentId)) {
      throw new Error('Geçersiz ödeme ID');
    }
    
    const payment = await Payment.findById(paymentId);
    if (!payment) {
      throw new Error('Ödeme bulunamadı');
    }
    
    return payment;
  } catch (error) {
    console.error('Ödeme detayı alınırken servis hatası:', error);
    throw error;
  }
};

/**
 * Toplam ödeme istatistiklerini getir
 * @returns {Promise<Object>} Toplam ödeme istatistikleri
 */
const getTotalPayments = async () => {
  try {
    const totalPayments = await Payment.aggregate([
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
          total: { $sum: '$amount' },
          paid: {
            $sum: {
              $cond: [{ $ne: ['$paidAt', null] }, '$amount', 0]
            }
          },
          pending: {
            $sum: {
              $cond: [{ $eq: ['$paidAt', null] }, '$amount', 0]
            }
          }
        }
      }
    ]);
    
    return totalPayments.length > 0 ? totalPayments[0] : { count: 0, total: 0, paid: 0, pending: 0 };
  } catch (error) {
    console.error('Toplam ödemeler alınırken servis hatası:', error);
    throw new Error('Toplam ödemeler alınırken bir hata oluştu');
  }
};

/**
 * Yeni ödeme oluştur
 * @param {Object} paymentData - Ödeme verileri
 * @returns {Promise<Object>} Oluşturulan ödeme
 */
const createPayment = async (paymentData) => {
  try {
    const { title, description, amount, userId, dueDate } = paymentData;
    
    // Kullanıcının varlığını kontrol et
    if (mongoose.Types.ObjectId.isValid(userId)) {
      const user = await User.findById(userId);
      if (!user) {
        throw new Error('Kullanıcı bulunamadı');
      }
    } else if (userId !== 'user1') {
      throw new Error('Geçersiz kullanıcı ID');
    }
    
    const newPayment = new Payment({
      title,
      description,
      amount,
      userId,
      dueDate: dueDate || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // Varsayılan olarak 30 gün sonra
    });
    
    await newPayment.save();
    return newPayment;
  } catch (error) {
    console.error('Ödeme oluşturulurken servis hatası:', error);
    throw error;
  }
};

/**
 * Ödeme yap
 * @param {string} paymentId - Ödeme ID
 * @param {string} userId - Kullanıcı ID
 * @param {Object} cardData - Kart bilgileri
 * @returns {Promise<Object>} Güncellenmiş ödeme
 */
const makePayment = async (paymentId, userId, cardData) => {
  try {
    // Ödemeyi bul
    const payment = await Payment.findById(paymentId);
    if (!payment) {
      throw new Error('Ödeme bulunamadı');
    }
    
    // Kullanıcı kontrolü
    if (payment.userId.toString() !== userId && userId !== 'user1') {
      throw new Error('Bu ödemeyi yapma yetkiniz yok');
    }
    
    // Ödeme zaten yapılmışsa
    if (payment.paidAt) {
      throw new Error('Bu ödeme zaten yapılmış');
    }
    
    // Kullanıcı bilgilerini al
    let user;
    if (mongoose.Types.ObjectId.isValid(userId)) {
      user = await User.findById(userId);
      if (!user) {
        throw new Error('Kullanıcı bulunamadı');
      }
    } else {
      // Test kullanıcısı için
      user = {
        _id: 'user1',
        name: 'Test Kullanıcı',
        email: 'test@example.com',
        phone: '+905350000000',
        residence: {
          site: 'Örnek Site',
          block: 'A',
          apartment: '101'
        }
      };
    }
    
    // Test modunda ise doğrudan ödemeyi tamamla
    if (process.env.NODE_ENV === 'test' || process.env.PAYMENT_TEST_MODE === 'true') {
      payment.paidAt = new Date();
      payment.status = 'paid';
      payment.paymentMethod = 'credit_card';
      payment.transactionId = `test_${Date.now()}`;
      payment.updatedAt = new Date();
      
      await payment.save();
      return payment;
    }
    
    // Gerçek ödeme işlemi için İyzico entegrasyonu
    // Burada gerçek ödeme işlemi yapılacak
    // ...
    
    return payment;
  } catch (error) {
    console.error('Ödeme yapılırken servis hatası:', error);
    throw error;
  }
};

/**
 * Ödeme güncelle
 * @param {string} paymentId - Ödeme ID
 * @param {Object} updateData - Güncellenecek veriler
 * @returns {Promise<Object>} Güncellenmiş ödeme
 */
const updatePayment = async (paymentId, updateData) => {
  try {
    const payment = await Payment.findById(paymentId);
    if (!payment) {
      throw new Error('Ödeme bulunamadı');
    }
    
    // Güncellenebilir alanlar
    const { title, description, amount, dueDate, status } = updateData;
    
    if (title) payment.title = title;
    if (description) payment.description = description;
    if (amount) payment.amount = amount;
    if (dueDate) payment.dueDate = dueDate;
    if (status) payment.status = status;
    
    payment.updatedAt = new Date();
    
    await payment.save();
    return payment;
  } catch (error) {
    console.error('Ödeme güncellenirken servis hatası:', error);
    throw error;
  }
};

/**
 * Ödeme sil
 * @param {string} paymentId - Ödeme ID
 * @returns {Promise<boolean>} Silme işlemi başarılı mı
 */
const deletePayment = async (paymentId) => {
  try {
    const payment = await Payment.findById(paymentId);
    if (!payment) {
      throw new Error('Ödeme bulunamadı');
    }
    
    await Payment.findByIdAndDelete(paymentId);
    return true;
  } catch (error) {
    console.error('Ödeme silinirken servis hatası:', error);
    throw error;
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