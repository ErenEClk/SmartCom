const express = require('express');
const router = express.Router();
const { protect } = require('../middlewares/auth');
const { 
  getUserConversations, 
  getConversationById, 
  getConversationMessages, 
  sendMessage, 
  markMessageAsRead, 
  markAllMessagesAsRead, 
  deleteMessage 
} = require('../controllers/messaging.controller');
const { check } = require('express-validator');

// Kullanıcının tüm konuşmalarını getir
router.get('/conversations', protect, getUserConversations);

// Konuşma detaylarını getir
router.get('/conversations/:id', protect, getConversationById);

// Konuşmadaki mesajları getir
router.get('/conversations/:id/messages', protect, getConversationMessages);

// Yeni mesaj gönder
router.post(
  '/messages', 
  protect,
  [
    check('receiverId', 'Alıcı ID gereklidir').not().isEmpty(),
    check('content', 'Mesaj içeriği gereklidir').not().isEmpty()
  ],
  sendMessage
);

// Mesajı okundu olarak işaretle
router.put('/messages/:id/read', protect, markMessageAsRead);

// Tüm mesajları okundu olarak işaretle
router.put('/conversations/:id/read-all', protect, markAllMessagesAsRead);

// Mesajı sil
router.delete('/messages/:id', protect, deleteMessage);

module.exports = router; 