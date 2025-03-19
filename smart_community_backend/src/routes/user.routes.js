const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middlewares/auth');
const { 
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser
} = require('../controllers/user.controller');
const { check } = require('express-validator');

// Tüm kullanıcıları getir (sadece admin)
router.get('/', protect, authorize('admin'), getAllUsers);

// Kullanıcı detaylarını getir
router.get('/:id', protect, getUserById);

// Kullanıcı güncelle (sadece admin veya kendisi)
router.put(
  '/:id', 
  protect,
  [
    check('name', 'İsim gereklidir').optional().not().isEmpty(),
    check('email', 'Geçerli bir e-posta adresi giriniz').optional().isEmail(),
    check('phone', 'Geçerli bir telefon numarası giriniz').optional().isMobilePhone('tr-TR')
  ],
  updateUser
);

// Kullanıcı sil (sadece admin)
router.delete('/:id', protect, authorize('admin'), deleteUser);

module.exports = router;