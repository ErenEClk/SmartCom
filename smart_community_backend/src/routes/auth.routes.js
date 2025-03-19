const express = require('express');
const router = express.Router();
const { protect } = require('../middlewares/auth');
const { 
  register, 
  login, 
  logout, 
  forgotPassword, 
  resetPassword,
  getMe,
  changePassword,
  updateProfile
} = require('../controllers/auth.controller');
const { check } = require('express-validator');

// Kullanıcı kaydı
router.post(
  '/register', 
  [
    check('name', 'İsim gereklidir').not().isEmpty(),
    check('email', 'Geçerli bir e-posta adresi giriniz').isEmail(),
    check('password', 'Şifre en az 6 karakter olmalıdır').isLength({ min: 6 })
  ],
  register
);

// Kullanıcı girişi
router.post(
  '/login',
  [
    check('email', 'Geçerli bir e-posta adresi giriniz').isEmail(),
    check('password', 'Şifre gereklidir').exists()
  ],
  login
);

// Kullanıcı çıkışı
router.post('/logout', protect, logout);

// Şifremi unuttum
router.post(
  '/forgot-password',
  [
    check('email', 'Geçerli bir e-posta adresi giriniz').isEmail()
  ],
  forgotPassword
);

// Şifre sıfırlama
router.post(
  '/reset-password',
  [
    check('token', 'Token gereklidir').not().isEmpty(),
    check('password', 'Şifre en az 6 karakter olmalıdır').isLength({ min: 6 })
  ],
  resetPassword
);

// Kullanıcı bilgilerini getir
router.get('/me', protect, getMe);

// Şifre değiştir
router.post(
  '/change-password',
  protect,
  [
    check('currentPassword', 'Mevcut şifre gereklidir').not().isEmpty(),
    check('newPassword', 'Yeni şifre en az 6 karakter olmalıdır').isLength({ min: 6 })
  ],
  changePassword
);

// Kullanıcı bilgilerini güncelle
router.put(
  '/update-profile',
  protect,
  [
    check('name', 'İsim gereklidir').not().isEmpty(),
    check('email', 'Geçerli bir e-posta adresi giriniz').isEmail()
  ],
  updateProfile
);

module.exports = router; 