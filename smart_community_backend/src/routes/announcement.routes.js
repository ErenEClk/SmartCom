const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middlewares/auth');
const { 
  getAllAnnouncements, 
  getUserAnnouncements, 
  getAnnouncementById, 
  getImportantAnnouncements, 
  createAnnouncement, 
  updateAnnouncement, 
  deleteAnnouncement 
} = require('../controllers/announcement.controller');
const { check } = require('express-validator');

// Tüm duyuruları getir (sadece admin)
router.get('/', protect, authorize('admin'), getAllAnnouncements);

// Kullanıcının duyurularını getir
router.get('/user', protect, getUserAnnouncements);

// Önemli duyuruları getir
router.get('/important', protect, getImportantAnnouncements);

// Duyuru detaylarını getir
router.get('/:id', protect, getAnnouncementById);

// Yeni duyuru oluştur (sadece admin)
router.post(
  '/', 
  protect, 
  authorize('admin'),
  [
    check('title', 'Başlık gereklidir').not().isEmpty(),
    check('content', 'İçerik gereklidir').not().isEmpty(),
    check('isImportant', 'Önemli durumu boolean olmalıdır').optional().isBoolean(),
    check('targetUsers', 'Hedef kullanıcılar bir dizi olmalıdır').optional().isArray()
  ],
  createAnnouncement
);

// Duyuru güncelle (sadece admin)
router.put(
  '/:id', 
  protect, 
  authorize('admin'),
  [
    check('title', 'Başlık gereklidir').optional().not().isEmpty(),
    check('content', 'İçerik gereklidir').optional().not().isEmpty(),
    check('isImportant', 'Önemli durumu boolean olmalıdır').optional().isBoolean(),
    check('targetUsers', 'Hedef kullanıcılar bir dizi olmalıdır').optional().isArray()
  ],
  updateAnnouncement
);

// Duyuru sil (sadece admin)
router.delete('/:id', protect, authorize('admin'), deleteAnnouncement);

module.exports = router; 