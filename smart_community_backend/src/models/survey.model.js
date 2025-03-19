const mongoose = require('mongoose');

// Anket seçeneği şeması
const OptionSchema = new mongoose.Schema({
  text: {
    type: String,
    required: [true, 'Seçenek metni gereklidir'],
    trim: true
  },
  votes: {
    type: Number,
    default: 0
  }
});

// Anket yanıtı şeması
const ResponseSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Kullanıcı ID gereklidir']
  },
  optionId: {
    type: mongoose.Schema.Types.ObjectId,
    required: [true, 'Seçenek ID gereklidir']
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Anket şeması
const SurveySchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Anket başlığı gereklidir'],
    trim: true,
    maxlength: [100, 'Başlık 100 karakterden uzun olamaz']
  },
  description: {
    type: String,
    required: [true, 'Anket açıklaması gereklidir'],
    trim: true,
    maxlength: [500, 'Açıklama 500 karakterden uzun olamaz']
  },
  options: [OptionSchema],
  responses: [ResponseSchema],
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Oluşturan kullanıcı ID gereklidir']
  },
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: {
    type: Date,
    required: [true, 'Bitiş tarihi gereklidir']
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Anket aktif mi kontrolü için virtual property
SurveySchema.virtual('isOpen').get(function() {
  const now = new Date();
  return this.isActive && now >= this.startDate && now <= this.endDate;
});

// Toplam oy sayısını hesaplayan virtual property
SurveySchema.virtual('totalVotes').get(function() {
  return this.options.reduce((total, option) => total + option.votes, 0);
});

// Güncelleme tarihini otomatik olarak ayarlayan middleware
SurveySchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

module.exports = mongoose.model('Survey', SurveySchema); 