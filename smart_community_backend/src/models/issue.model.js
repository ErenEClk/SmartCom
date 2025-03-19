const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema(
  {
    text: {
      type: String,
      required: [true, 'Yorum metni gereklidir']
    },
    user: {
      type: mongoose.Schema.ObjectId,
      ref: 'User',
      required: [true, 'Yorum bir kullanıcıya ait olmalıdır']
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

const issueSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Arıza bildirimi bir başlığa sahip olmalıdır'],
      trim: true,
      maxlength: [100, 'Başlık en fazla 100 karakter olabilir']
    },
    description: {
      type: String,
      required: [true, 'Arıza bildirimi bir açıklamaya sahip olmalıdır'],
      trim: true,
      maxlength: [1000, 'Açıklama en fazla 1000 karakter olabilir']
    },
    category: {
      type: String,
      required: [true, 'Arıza bildirimi bir kategoriye sahip olmalıdır'],
      enum: {
        values: ['Elektrik', 'Su', 'Isıtma', 'Asansör', 'Güvenlik', 'Temizlik', 'Diğer'],
        message: 'Kategori: Elektrik, Su, Isıtma, Asansör, Güvenlik, Temizlik veya Diğer olmalıdır'
      }
    },
    status: {
      type: String,
      enum: {
        values: ['Beklemede', 'İşleniyor', 'Tamamlandı', 'İptal Edildi'],
        message: 'Durum: Beklemede, İşleniyor, Tamamlandı veya İptal Edildi olmalıdır'
      },
      default: 'Beklemede'
    },
    isUrgent: {
      type: Boolean,
      default: false
    },
    images: [String],
    reporter: {
      type: mongoose.Schema.ObjectId,
      ref: 'User',
      required: [true, 'Arıza bildirimi bir kullanıcıya ait olmalıdır']
    },
    assignedTo: {
      type: mongoose.Schema.ObjectId,
      ref: 'User'
    },
    comments: [commentSchema],
    createdAt: {
      type: Date,
      default: Date.now
    },
    updatedAt: {
      type: Date
    }
  },
  {
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// Arıza bildirimi güncellendiğinde updatedAt alanını güncelle
issueSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updatedAt: Date.now() });
  next();
});

const Issue = mongoose.model('Issue', issueSchema);

module.exports = Issue; 