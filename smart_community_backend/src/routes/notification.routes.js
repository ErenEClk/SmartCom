const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middlewares/auth');
const { 
  getAllNotifications, 
  getUserNotifications, 
  getNotificationById, 
  createNotification, 
  markAsRead, 
  markAllAsRead, 
  deleteNotification 
} = require('../controllers/notification.controller');
const { check } = require('express-validator');

// Tüm bildirimleri getir (sadece admin)
router.get('/', protect, authorize('admin'), getAllNotifications);

// Kullanıcının bildirimlerini getir
router.get('/user', protect, getUserNotifications);

// Bildirim detaylarını getir
router.get('/:id', protect, getNotificationById);

// Yeni bildirim oluştur (sadece admin)
router.post(
  '/', 
  protect, 
  authorize('admin'),
  [
    check('userId', 'Kullanıcı ID gereklidir').not().isEmpty(),
    check('title', 'Başlık gereklidir').not().isEmpty(),
    check('message', 'Mesaj gereklidir').not().isEmpty(),
    check('type', 'Tip gereklidir').not().isEmpty()
  ],
  createNotification
);

// Bildirimi okundu olarak işaretle
router.put('/:id/read', protect, markAsRead);

// Tüm bildirimleri okundu olarak işaretle
router.put('/read-all', protect, markAllAsRead);

// Bildirimi sil
router.delete('/:id', protect, deleteNotification);

module.exports = router; 