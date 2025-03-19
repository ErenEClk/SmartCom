const Announcement = require('../models/announcement.model');
const User = require('../models/user.model');
const mongoose = require('mongoose');

/**
 * Tüm duyuruları getir
 * @returns {Promise<Array>} Duyurular listesi
 */
const getAllAnnouncements = async () => {
  try {
    return await Announcement.find().sort({ createdAt: -1 });
  } catch (error) {
    console.error('Duyurular alınırken servis hatası:', error);
    throw new Error('Duyurular alınırken bir hata oluştu');
  }
};

/**
 * Kullanıcıya özel duyuruları getir
 * @param {string} userId - Kullanıcı ID
 * @returns {Promise<Array>} Kullanıcıya özel duyurular
 */
const getUserAnnouncements = async (userId) => {
  try {
    // Tüm duyuruları ve kullanıcıya özel duyuruları getir
    const announcements = await Announcement.find({
      $or: [
        { targetUserIds: { $exists: false } }, // Hedef kullanıcı belirtilmemiş (herkese açık)
        { targetUserIds: { $size: 0 } }, // Boş hedef kullanıcı dizisi (herkese açık)
        { targetUserIds: userId } // Kullanıcıya özel
      ]
    }).sort({ createdAt: -1 });
    
    return announcements;
  } catch (error) {
    console.error('Kullanıcı duyuruları alınırken servis hatası:', error);
    throw new Error('Kullanıcı duyuruları alınırken bir hata oluştu');
  }
};

/**
 * Duyuru detayını getir
 * @param {string} announcementId - Duyuru ID
 * @returns {Promise<Object>} Duyuru detayı
 */
const getAnnouncementById = async (announcementId) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(announcementId)) {
      throw new Error('Geçersiz duyuru ID');
    }
    
    const announcement = await Announcement.findById(announcementId);
    if (!announcement) {
      throw new Error('Duyuru bulunamadı');
    }
    
    return announcement;
  } catch (error) {
    console.error('Duyuru detayı alınırken servis hatası:', error);
    throw error;
  }
};

/**
 * Yeni duyuru oluştur
 * @param {Object} announcementData - Duyuru verileri
 * @returns {Promise<Object>} Oluşturulan duyuru
 */
const createAnnouncement = async (announcementData) => {
  try {
    const { title, content, isImportant, imageUrls, fileUrls, targetUserIds } = announcementData;
    
    // Hedef kullanıcıların varlığını kontrol et
    if (targetUserIds && targetUserIds.length > 0) {
      for (const userId of targetUserIds) {
        if (mongoose.Types.ObjectId.isValid(userId)) {
          const user = await User.findById(userId);
          if (!user) {
            throw new Error(`Kullanıcı bulunamadı: ${userId}`);
          }
        }
      }
    }
    
    const newAnnouncement = new Announcement({
      title,
      content,
      isImportant: isImportant || false,
      imageUrls,
      fileUrls,
      targetUserIds,
      createdAt: new Date(),
      updatedAt: new Date()
    });
    
    await newAnnouncement.save();
    return newAnnouncement;
  } catch (error) {
    console.error('Duyuru oluşturulurken servis hatası:', error);
    throw error;
  }
};

/**
 * Duyuru güncelle
 * @param {string} announcementId - Duyuru ID
 * @param {Object} updateData - Güncellenecek veriler
 * @returns {Promise<Object>} Güncellenmiş duyuru
 */
const updateAnnouncement = async (announcementId, updateData) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(announcementId)) {
      throw new Error('Geçersiz duyuru ID');
    }
    
    const announcement = await Announcement.findById(announcementId);
    if (!announcement) {
      throw new Error('Duyuru bulunamadı');
    }
    
    // Güncellenebilir alanlar
    const { title, content, isImportant, imageUrls, fileUrls, targetUserIds } = updateData;
    
    if (title) announcement.title = title;
    if (content) announcement.content = content;
    if (isImportant !== undefined) announcement.isImportant = isImportant;
    if (imageUrls) announcement.imageUrls = imageUrls;
    if (fileUrls) announcement.fileUrls = fileUrls;
    if (targetUserIds) announcement.targetUserIds = targetUserIds;
    
    announcement.updatedAt = new Date();
    
    await announcement.save();
    return announcement;
  } catch (error) {
    console.error('Duyuru güncellenirken servis hatası:', error);
    throw error;
  }
};

/**
 * Duyuru sil
 * @param {string} announcementId - Duyuru ID
 * @returns {Promise<boolean>} Silme işlemi başarılı mı
 */
const deleteAnnouncement = async (announcementId) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(announcementId)) {
      throw new Error('Geçersiz duyuru ID');
    }
    
    const announcement = await Announcement.findById(announcementId);
    if (!announcement) {
      throw new Error('Duyuru bulunamadı');
    }
    
    await Announcement.findByIdAndDelete(announcementId);
    return true;
  } catch (error) {
    console.error('Duyuru silinirken servis hatası:', error);
    throw error;
  }
};

/**
 * Önemli duyuruları getir
 * @returns {Promise<Array>} Önemli duyurular listesi
 */
const getImportantAnnouncements = async () => {
  try {
    return await Announcement.find({ isImportant: true }).sort({ createdAt: -1 });
  } catch (error) {
    console.error('Önemli duyurular alınırken servis hatası:', error);
    throw new Error('Önemli duyurular alınırken bir hata oluştu');
  }
};

module.exports = {
  getAllAnnouncements,
  getUserAnnouncements,
  getAnnouncementById,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
  getImportantAnnouncements
}; 