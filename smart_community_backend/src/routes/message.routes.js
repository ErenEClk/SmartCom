const express = require('express');
const router = express.Router();
const { protect, admin } = require('../middleware/auth.middleware');

// Geçici controller fonksiyonları (gerçek controller oluşturulana kadar)
const tempController = {
  getConversations: (req, res) => {
    res.status(200).json({
      success: true,
      message: 'Konuşmalar API çalışıyor',
      data: []
    });
  },
  getConversationById: (req, res) => {
    res.status(200).json({
      success: true,
      message: `Konuşma detayları ID: ${req.params.id}`,
      data: {
        id: req.params.id,
        messages: []
      }
    });
  },
  createConversation: (req, res) => {
    res.status(201).json({
      success: true,
      message: 'Konuşma oluşturuldu',
      data: { ...req.body, id: Date.now().toString() }
    });
  },
  sendMessage: (req, res) => {
    res.status(201).json({
      success: true,
      message: 'Mesaj gönderildi',
      data: { 
        id: Date.now().toString(),
        conversationId: req.params.id,
        sender: req.user.id,
        content: req.body.content,
        timestamp: new Date().toISOString()
      }
    });
  },
  markAsRead: (req, res) => {
    res.status(200).json({
      success: true,
      message: `Mesajlar okundu olarak işaretlendi ID: ${req.params.id}`
    });
  },
  deleteConversation: (req, res) => {
    res.status(200).json({
      success: true,
      message: `Konuşma silindi ID: ${req.params.id}`
    });
  }
};

// Mesajlaşma rotaları
router.get('/', protect, tempController.getConversations);
router.get('/:id', protect, tempController.getConversationById);
router.post('/', protect, tempController.createConversation);
router.post('/:id/messages', protect, tempController.sendMessage);
router.put('/:id/read', protect, tempController.markAsRead);
router.delete('/:id', protect, tempController.deleteConversation);

module.exports = router; 