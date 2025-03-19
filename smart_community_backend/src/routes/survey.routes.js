const express = require('express');
const router = express.Router();
const surveyController = require('../controllers/survey.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Tüm anketleri getir
router.get('/', protect, surveyController.getSurveys);

// Tek bir anketi getir
router.get('/:id', protect, surveyController.getSurvey);

// Anket oluştur (sadece admin)
router.post('/', protect, authorize('admin'), surveyController.createSurvey);

// Anket güncelle (sadece admin)
router.put('/:id', protect, authorize('admin'), surveyController.updateSurvey);

// Anket sil (sadece admin)
router.delete('/:id', protect, authorize('admin'), surveyController.deleteSurvey);

// Ankete oy ver
router.post('/:id/respond', protect, surveyController.respondToSurvey);

module.exports = router; 