const notificationService = require('../services/notification.service');
const { validationResult } = require('express-validator');

// Tüm bildirimleri getir (sadece admin)
const getAllNotifications = async (req, res) => {
  try {
    // Sadece admin tüm bildirimleri görebilir
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu işlem için yetkiniz yok'
      });
    }
    
    const notifications = await notificationService.getAllNotifications();
    
    res.status(200).json({
      success: true,
      count: notifications.length,
      data: notifications
    });
  } catch (error) {
    console.error('Bildirimler alınırken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Kullanıcının bildirimlerini getir
const getUserNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const notifications = await notificationService.getUserNotifications(userId);
    
    res.status(200).json({
      success: true,
      count: notifications.length,
      data: notifications
    });
  } catch (error) {
    console.error('Kullanıcı bildirimleri alınırken hata:', error);
    
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

// Bildirim detaylarını getir
const getNotificationById = async (req, res) => {
  try {
    const notificationId = req.params.id;
    
    const notification = await notificationService.getNotificationById(notificationId);
    
    // Kullanıcının kendi bildirimi olduğunu kontrol et
    if (notification.user.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu bildirimi görüntüleme yetkiniz yok'
      });
    }
    
    res.status(200).json({
      success: true,
      data: notification
    });
  } catch (error) {
    console.error('Bildirim detayları alınırken hata:', error);
    
    if (error.message.includes('Geçersiz bildirim ID') || error.message.includes('Bildirim bulunamadı')) {
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

// Yeni bildirim oluştur (sadece admin)
const createNotification = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    // Sadece admin bildirim oluşturabilir
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu işlem için yetkiniz yok'
      });
    }
    
    const notificationData = {
      userId: req.body.userId,
      title: req.body.title,
      message: req.body.message,
      type: req.body.type,
      relatedId: req.body.relatedId
    };
    
    const notification = await notificationService.createNotification(notificationData);
    
    res.status(201).json({
      success: true,
      message: 'Bildirim başarıyla oluşturuldu',
      data: notification
    });
  } catch (error) {
    console.error('Bildirim oluşturulurken hata:', error);
    
    if (error.message.includes('Geçersiz kullanıcı ID') || error.message.includes('Kullanıcı bulunamadı')) {
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

// Bildirimi okundu olarak işaretle
const markAsRead = async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.id;
    
    const notification = await notificationService.markAsRead(notificationId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Bildirim okundu olarak işaretlendi',
      data: notification
    });
  } catch (error) {
    console.error('Bildirim okundu olarak işaretlenirken hata:', error);
    
    if (error.message.includes('Geçersiz bildirim ID') || error.message.includes('Bildirim bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu bildirimi işaretleme yetkiniz yok')) {
      return res.status(403).json({
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

// Tüm bildirimleri okundu olarak işaretle
const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const result = await notificationService.markAllAsRead(userId);
    
    res.status(200).json({
      success: true,
      message: `${result.modifiedCount} bildirim okundu olarak işaretlendi`,
      data: result
    });
  } catch (error) {
    console.error('Tüm bildirimler okundu olarak işaretlenirken hata:', error);
    
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

// Bildirimi sil
const deleteNotification = async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.id;
    
    await notificationService.deleteNotification(notificationId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Bildirim başarıyla silindi'
    });
  } catch (error) {
    console.error('Bildirim silinirken hata:', error);
    
    if (error.message.includes('Geçersiz bildirim ID') || error.message.includes('Bildirim bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu bildirimi silme yetkiniz yok')) {
      return res.status(403).json({
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

// Ödeme bildirimi oluştur (diğer servisler tarafından çağrılır)
const createPaymentNotification = async (userId, paymentId, paymentTitle, amount) => {
  try {
    return await notificationService.createPaymentNotification(userId, paymentId, paymentTitle, amount);
  } catch (error) {
    console.error('Ödeme bildirimi oluşturulurken hata:', error);
    throw error;
  }
};

// Duyuru bildirimi oluştur (diğer servisler tarafından çağrılır)
const createAnnouncementNotification = async (userId, announcementId, announcementTitle) => {
  try {
    return await notificationService.createAnnouncementNotification(userId, announcementId, announcementTitle);
  } catch (error) {
    console.error('Duyuru bildirimi oluşturulurken hata:', error);
    throw error;
  }
};

module.exports = {
  getAllNotifications,
  getUserNotifications,
  getNotificationById,
  createNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  createPaymentNotification,
  createAnnouncementNotification
}; 