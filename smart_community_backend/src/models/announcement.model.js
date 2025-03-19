const mongoose = require('mongoose');

const announcementSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  content: {
    type: String,
    required: true
  },
  isImportant: {
    type: Boolean,
    default: false
  },
  category: {
    type: String,
    enum: ['general', 'maintenance', 'event', 'security', 'other'],
    default: 'general'
  },
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: {
    type: Date,
    default: function() {
      return new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 gün sonra
    }
  },
  targetUsers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  isPublic: {
    type: Boolean,
    default: true
  },
  imageUrls: [String],
  fileUrls: [String],
  viewCount: {
    type: Number,
    default: 0
  },
  viewedBy: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    viewedAt: {
      type: Date,
      default: Date.now
    }
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  isDeleted: {
    type: Boolean,
    default: false
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: Date
});

// Güncelleme öncesi updatedAt alanını güncelle
announcementSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updatedAt: new Date() });
  next();
});

// Duyuru oluşturulduğunda updatedAt alanını ayarla
announcementSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Duyurunun aktif olup olmadığını kontrol eden virtual
announcementSchema.virtual('isCurrentlyActive').get(function() {
  const now = new Date();
  return this.isActive && now >= this.startDate && now <= this.endDate;
});

// Duyuruları tarihe göre sıralayan statik metod
announcementSchema.statics.getActiveAnnouncements = async function() {
  const now = new Date();
  return this.find({
    isActive: true,
    startDate: { $lte: now },
    endDate: { $gte: now },
  }).sort({ createdAt: -1 });
};

module.exports = mongoose.model('Announcement', announcementSchema); 