const announcementService = require('../services/announcement.service');
const { validationResult } = require('express-validator');

// @desc    Tüm duyuruları getir
// @route   GET /api/announcements
// @access  Public
const getAllAnnouncements = async (req, res) => {
  try {
    const announcements = await announcementService.getAllAnnouncements();
    
    res.status(200).json({
      success: true,
      count: announcements.length,
      data: announcements
    });
  } catch (error) {
    console.error('Duyurular alınırken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// @desc    Tek bir duyuru getir
// @route   GET /api/announcements/:id
// @access  Public
const getAnnouncementById = async (req, res) => {
  try {
    const announcementId = req.params.id;
    
    const announcement = await announcementService.getAnnouncementById(announcementId);
    
    res.status(200).json({
      success: true,
      data: announcement
    });
  } catch (error) {
    console.error('Duyuru detayları alınırken hata:', error);
    
    if (error.message.includes('Geçersiz duyuru ID') || error.message.includes('Duyuru bulunamadı')) {
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

// @desc    Yeni duyuru oluştur
// @route   POST /api/announcements
// @access  Private (Admin)
const createAnnouncement = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const announcementData = {
      title: req.body.title,
      content: req.body.content,
      isImportant: req.body.isImportant,
      targetUsers: req.body.targetUsers,
      imageUrls: req.body.imageUrls,
      fileUrls: req.body.fileUrls,
      createdBy: req.user.id
    };
    
    const announcement = await announcementService.createAnnouncement(announcementData);
    
    res.status(201).json({
      success: true,
      message: 'Duyuru başarıyla oluşturuldu',
      data: announcement
    });
  } catch (error) {
    console.error('Duyuru oluşturulurken hata:', error);
    
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

// @desc    Duyuru güncelle
// @route   PUT /api/announcements/:id
// @access  Private (Admin)
const updateAnnouncement = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const announcementId = req.params.id;
    const updateData = {
      title: req.body.title,
      content: req.body.content,
      isImportant: req.body.isImportant,
      targetUsers: req.body.targetUsers,
      imageUrls: req.body.imageUrls,
      fileUrls: req.body.fileUrls
    };
    
    const announcement = await announcementService.updateAnnouncement(announcementId, updateData);
    
    res.status(200).json({
      success: true,
      message: 'Duyuru başarıyla güncellendi',
      data: announcement
    });
  } catch (error) {
    console.error('Duyuru güncellenirken hata:', error);
    
    if (error.message.includes('Geçersiz duyuru ID') || error.message.includes('Duyuru bulunamadı')) {
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

// @desc    Duyuru sil
// @route   DELETE /api/announcements/:id
// @access  Private (Admin)
const deleteAnnouncement = async (req, res) => {
  try {
    const announcementId = req.params.id;
    
    await announcementService.deleteAnnouncement(announcementId);
    
    res.status(200).json({
      success: true,
      message: 'Duyuru başarıyla silindi'
    });
  } catch (error) {
    console.error('Duyuru silinirken hata:', error);
    
    if (error.message.includes('Geçersiz duyuru ID') || error.message.includes('Duyuru bulunamadı')) {
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

// @desc    Duyuruyu aktif/pasif yap
// @route   PUT /api/announcements/:id/toggle-status
// @access  Private (Admin)
const toggleAnnouncementStatus = async (req, res) => {
  // Implementation needed
};

// Kullanıcının duyurularını getir
const getUserAnnouncements = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const announcements = await announcementService.getUserAnnouncements(userId);
    
    res.status(200).json({
      success: true,
      count: announcements.length,
      data: announcements
    });
  } catch (error) {
    console.error('Kullanıcı duyuruları alınırken hata:', error);
    
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

// Önemli duyuruları getir
const getImportantAnnouncements = async (req, res) => {
  try {
    const announcements = await announcementService.getImportantAnnouncements();
    
    res.status(200).json({
      success: true,
      count: announcements.length,
      data: announcements
    });
  } catch (error) {
    console.error('Önemli duyurular alınırken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  getAllAnnouncements,
  getUserAnnouncements,
  getAnnouncementById,
  getImportantAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  toggleAnnouncementStatus
}; 