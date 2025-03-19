const messagingService = require('../services/messaging.service');
const { validationResult } = require('express-validator');

// Kullanıcının tüm konuşmalarını getir
const getUserConversations = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const conversations = await messagingService.getUserConversations(userId);
    
    res.status(200).json({
      success: true,
      count: conversations.length,
      data: conversations
    });
  } catch (error) {
    console.error('Kullanıcı konuşmaları alınırken hata:', error);
    
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

// Konuşma detaylarını getir
const getConversationById = async (req, res) => {
  try {
    const conversationId = req.params.id;
    const userId = req.user.id;
    
    const conversation = await messagingService.getConversationById(conversationId, userId);
    
    res.status(200).json({
      success: true,
      data: conversation
    });
  } catch (error) {
    console.error('Konuşma detayları alınırken hata:', error);
    
    if (error.message.includes('Geçersiz konuşma ID') || error.message.includes('Konuşma bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu konuşmaya erişim yetkiniz yok')) {
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

// Konuşmadaki mesajları getir
const getConversationMessages = async (req, res) => {
  try {
    const conversationId = req.params.id;
    const userId = req.user.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    
    const result = await messagingService.getConversationMessages(conversationId, userId, page, limit);
    
    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Konuşma mesajları alınırken hata:', error);
    
    if (error.message.includes('Geçersiz konuşma ID') || error.message.includes('Konuşma bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu konuşmaya erişim yetkiniz yok')) {
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

// Yeni mesaj gönder
const sendMessage = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const senderId = req.user.id;
    const { receiverId, content, attachments } = req.body;
    
    const message = await messagingService.sendMessage({
      senderId,
      receiverId,
      content,
      attachments
    });
    
    res.status(201).json({
      success: true,
      message: 'Mesaj başarıyla gönderildi',
      data: message
    });
  } catch (error) {
    console.error('Mesaj gönderilirken hata:', error);
    
    if (error.message.includes('Geçersiz kullanıcı ID') || error.message.includes('Gönderici veya alıcı kullanıcı bulunamadı')) {
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

// Mesajı okundu olarak işaretle
const markMessageAsRead = async (req, res) => {
  try {
    const messageId = req.params.id;
    const userId = req.user.id;
    
    const message = await messagingService.markMessageAsRead(messageId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Mesaj okundu olarak işaretlendi',
      data: message
    });
  } catch (error) {
    console.error('Mesaj okundu olarak işaretlenirken hata:', error);
    
    if (error.message.includes('Geçersiz mesaj ID') || error.message.includes('Mesaj bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu mesajı okuma yetkiniz yok')) {
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

// Tüm mesajları okundu olarak işaretle
const markAllMessagesAsRead = async (req, res) => {
  try {
    const conversationId = req.params.id;
    const userId = req.user.id;
    
    const result = await messagingService.markAllMessagesAsRead(conversationId, userId);
    
    res.status(200).json({
      success: true,
      message: `${result.modifiedCount} mesaj okundu olarak işaretlendi`,
      data: result
    });
  } catch (error) {
    console.error('Tüm mesajlar okundu olarak işaretlenirken hata:', error);
    
    if (error.message.includes('Geçersiz konuşma ID') || error.message.includes('Konuşma bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu konuşmaya erişim yetkiniz yok')) {
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

// Mesajı sil
const deleteMessage = async (req, res) => {
  try {
    const messageId = req.params.id;
    const userId = req.user.id;
    
    await messagingService.deleteMessage(messageId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Mesaj başarıyla silindi'
    });
  } catch (error) {
    console.error('Mesaj silinirken hata:', error);
    
    if (error.message.includes('Geçersiz mesaj ID') || error.message.includes('Mesaj bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu mesajı silme yetkiniz yok')) {
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

module.exports = {
  getUserConversations,
  getConversationById,
  getConversationMessages,
  sendMessage,
  markMessageAsRead,
  markAllMessagesAsRead,
  deleteMessage
}; 