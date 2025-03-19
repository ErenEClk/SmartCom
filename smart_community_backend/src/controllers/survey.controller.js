const Survey = require('../models/survey.model');
const mongoose = require('mongoose');

// Tüm anketleri getir
const getSurveys = async (req, res) => {
  try {
    const surveys = await Survey.find()
      .sort({ createdAt: -1 })
      .populate('createdBy', 'name email');

    res.status(200).json({
      success: true,
      count: surveys.length,
      data: surveys
    });
  } catch (error) {
    console.error('Anketleri getirme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Tek bir anketi getir
const getSurvey = async (req, res) => {
  try {
    const survey = await Survey.findById(req.params.id)
      .populate('createdBy', 'name email')
      .populate('responses.userId', 'name email');

    if (!survey) {
      return res.status(404).json({
        success: false,
        message: 'Anket bulunamadı'
      });
    }

    res.status(200).json({
      success: true,
      data: survey
    });
  } catch (error) {
    console.error('Anket getirme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Anket oluştur
const createSurvey = async (req, res) => {
  try {
    // Kullanıcı ID'sini ekle
    req.body.createdBy = req.user.id;

    const survey = await Survey.create(req.body);

    res.status(201).json({
      success: true,
      data: survey
    });
  } catch (error) {
    console.error('Anket oluşturma hatası:', error);
    
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Anket güncelle
const updateSurvey = async (req, res) => {
  try {
    let survey = await Survey.findById(req.params.id);

    if (!survey) {
      return res.status(404).json({
        success: false,
        message: 'Anket bulunamadı'
      });
    }

    // Yalnızca oluşturan kullanıcı veya admin güncelleyebilir
    if (survey.createdBy.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu anketi güncelleme yetkiniz yok'
      });
    }

    survey = await Survey.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      success: true,
      data: survey
    });
  } catch (error) {
    console.error('Anket güncelleme hatası:', error);
    
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Anket sil
const deleteSurvey = async (req, res) => {
  try {
    const survey = await Survey.findById(req.params.id);

    if (!survey) {
      return res.status(404).json({
        success: false,
        message: 'Anket bulunamadı'
      });
    }

    // Yalnızca oluşturan kullanıcı veya admin silebilir
    if (survey.createdBy.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu anketi silme yetkiniz yok'
      });
    }

    await survey.remove();

    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (error) {
    console.error('Anket silme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Ankete oy ver
const respondToSurvey = async (req, res) => {
  try {
    const { optionId } = req.body;
    
    if (!optionId) {
      return res.status(400).json({
        success: false,
        message: 'Seçenek ID gereklidir'
      });
    }

    const survey = await Survey.findById(req.params.id);

    if (!survey) {
      return res.status(404).json({
        success: false,
        message: 'Anket bulunamadı'
      });
    }

    // Anketin aktif olup olmadığını kontrol et
    const now = new Date();
    if (!survey.isActive || now < survey.startDate || now > survey.endDate) {
      return res.status(400).json({
        success: false,
        message: 'Bu anket şu anda aktif değil'
      });
    }

    // Kullanıcının daha önce oy verip vermediğini kontrol et
    const existingResponse = survey.responses.find(
      response => response.userId.toString() === req.user.id
    );

    if (existingResponse) {
      return res.status(400).json({
        success: false,
        message: 'Bu ankete zaten oy verdiniz'
      });
    }

    // Seçeneğin geçerli olup olmadığını kontrol et
    const option = survey.options.id(optionId);
    if (!option) {
      return res.status(404).json({
        success: false,
        message: 'Geçersiz seçenek'
      });
    }

    // Oy sayısını artır
    option.votes += 1;

    // Yanıtı ekle
    survey.responses.push({
      userId: req.user.id,
      optionId: optionId
    });

    await survey.save();

    res.status(200).json({
      success: true,
      data: survey
    });
  } catch (error) {
    console.error('Ankete oy verme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  getSurveys,
  getSurvey,
  createSurvey,
  updateSurvey,
  deleteSurvey,
  respondToSurvey
}; 