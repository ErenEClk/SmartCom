const express = require('express');
const router = express.Router();
const { protect, admin } = require('../middleware/auth.middleware');
const issueController = require('../controllers/issue.controller');
const upload = require('../middleware/upload.middleware');

// Tüm arıza bildirimlerini getir
router.get('/', protect, issueController.getAllIssues);

// Arıza bildirimini ID'ye göre getir
router.get('/:id', protect, issueController.getIssue);

// Yeni arıza bildirimi oluştur (en fazla 3 resim)
router.post('/', protect, upload.array('images', 3), issueController.createIssue);

// Arıza bildirimini güncelle
router.put('/:id', protect, issueController.updateIssue);

// Arıza bildirimini sil
router.delete('/:id', protect, admin, issueController.deleteIssue);

// Arıza bildirimine yorum ekle
router.post('/:id/comments', protect, issueController.addComment);

module.exports = router; 