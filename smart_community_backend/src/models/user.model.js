const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Residence şeması
const ResidenceSchema = new mongoose.Schema({
  site: {
    type: String,
    required: [true, 'Site adı gereklidir']
  },
  block: {
    type: String,
    required: [true, 'Blok bilgisi gereklidir']
  },
  apartment: {
    type: String,
    required: [true, 'Daire numarası gereklidir']
  },
  status: {
    type: String,
    enum: ['Sahibi', 'Kiracı', 'Yönetici', 'Diğer'],
    default: 'Sahibi'
  }
});

// User şeması
const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'İsim gereklidir']
  },
  email: {
    type: String,
    required: [true, 'E-posta gereklidir'],
    unique: true,
    match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Geçerli bir e-posta adresi giriniz']
  },
  password: {
    type: String,
    required: [true, 'Şifre gereklidir'],
    minlength: 6,
    select: false
  },
  phone: {
    type: String,
    match: [/^(\+90|0)?[0-9]{10}$/, 'Geçerli bir telefon numarası giriniz']
  },
  profileImage: {
    type: String,
    default: 'default.jpg'
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'siteManager', 'technicalSupport', 'security'],
    default: 'user'
  },
  residence: {
    site: String,
    block: String,
    apartment: String,
    status: {
      type: String,
      enum: ['Sahibi', 'Kiracı', 'Yönetici', 'Diğer'],
      default: 'Sahibi'
    }
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'suspended'],
    default: 'active'
  },
  preferences: {
    notifications: {
      email: { type: Boolean, default: true },
      push: { type: Boolean, default: true },
      sms: { type: Boolean, default: false }
    },
    theme: {
      type: String,
      enum: ['light', 'dark', 'system'],
      default: 'system'
    }
  },
  resetPasswordToken: String,
  resetPasswordExpire: Date,
  lastLoginAt: Date,
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: Date,
  isDeleted: {
    type: Boolean,
    default: false
  }
});

// Şifreyi hashle
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    next();
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  this.updatedAt = new Date();
});

// Güncelleme öncesi updatedAt alanını güncelle
UserSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updatedAt: new Date() });
  next();
});

// JWT token oluştur
UserSchema.methods.getSignedJwtToken = function () {
  return jwt.sign(
    { id: this._id, email: this.email, role: this.role },
    process.env.JWT_SECRET || 'gizli_anahtar',
    { expiresIn: process.env.JWT_EXPIRE || '30d' }
  );
};

// Şifre kontrolü
UserSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', UserSchema); 