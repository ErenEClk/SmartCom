const User = require('../models/user.model');
const bcrypt = require('bcryptjs');
const userService = require('../services/user.service');
const { validationResult } = require('express-validator');

// @desc    Kullanıcı profilini getir
// @route   GET /api/users/profile
// @access  Private
exports.getUserProfile = async (req, res) => {
  try {
    // Test kullanıcısı için özel durum
    if (req.user._id === '123456') {
      return res.status(200).json({
        success: true,
        data: {
          id: '123456',
          name: 'Test Kullanıcı',
          email: 'test@example.com',
          phone: '5551234567',
          profileImage: 'https://via.placeholder.com/150',
          residence: {
            site: 'Örnek Site',
            block: 'A',
            apartment: '101',
            status: 'Sahibi'
          },
          role: 'user'
        }
      });
    }

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        message: 'Kullanıcı bulunamadı',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        profileImage: user.profileImage,
        residence: user.residence,
        role: user.role,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Sunucu hatası',
    });
  }
};

// @desc    Kullanıcı profilini güncelle
// @route   PUT /api/users/profile
// @access  Private
exports.updateUserProfile = async (req, res) => {
  try {
    // Test kullanıcısı için özel durum
    if (req.user._id === '123456') {
      return res.status(200).json({
        success: true,
        data: {
          id: '123456',
          name: req.body.name || 'Test Kullanıcı',
          email: req.body.email || 'test@example.com',
          phone: req.body.phone || '5551234567',
          profileImage: req.body.profileImage || 'https://via.placeholder.com/150',
          residence: req.body.residence || {
            site: 'Örnek Site',
            block: 'A',
            apartment: '101',
            status: 'Sahibi'
          },
          role: 'user'
        }
      });
    }

    const { name, email, phone, profileImage, residence } = req.body;

    // E-posta kontrolü
    if (email && email !== req.user.email) {
      const userExists = await User.findOne({ email });

      if (userExists) {
        return res.status(400).json({
          message: 'Bu e-posta adresi zaten kullanılıyor',
        });
      }
    }

    // Kullanıcıyı güncelle
    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        name: name || req.user.name,
        email: email || req.user.email,
        phone: phone || req.user.phone,
        profileImage: profileImage || req.user.profileImage,
        residence: residence || req.user.residence,
      },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        message: 'Kullanıcı bulunamadı',
      });
    }

    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        profileImage: user.profileImage,
        residence: user.residence,
        role: user.role,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Sunucu hatası',
    });
  }
};

// @desc    Şifre değiştir
// @route   PUT /api/users/change-password
// @access  Private
exports.changePassword = async (req, res) => {
  try {
    // Test kullanıcısı için özel durum
    if (req.user._id === '123456') {
      return res.status(200).json({
        success: true,
        message: 'Şifre başarıyla değiştirildi',
      });
    }

    const { currentPassword, newPassword } = req.body;

    // Şifre kontrolü
    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        message: 'Lütfen mevcut şifre ve yeni şifre girin',
      });
    }

    // Kullanıcıyı bul
    const user = await User.findById(req.user._id).select('+password');

    if (!user) {
      return res.status(404).json({
        message: 'Kullanıcı bulunamadı',
      });
    }

    // Mevcut şifre kontrolü
    const isMatch = await user.matchPassword(currentPassword);

    if (!isMatch) {
      return res.status(401).json({
        message: 'Mevcut şifre yanlış',
      });
    }

    // Yeni şifreyi ayarla
    user.password = newPassword;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Şifre başarıyla değiştirildi',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Sunucu hatası',
    });
  }
};

// @desc    Bildirim ayarlarını getir
// @route   GET /api/users/notification-settings
// @access  Private
exports.getNotificationSettings = async (req, res) => {
  try {
    // Test kullanıcısı için özel durum
    if (req.user._id === '123456') {
      return res.status(200).json({
        success: true,
        notificationSettings: {
          email: true,
          push: true,
          sms: false
        }
      });
    }

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        message: 'Kullanıcı bulunamadı',
      });
    }

    res.status(200).json({
      success: true,
      notificationSettings: user.notificationSettings,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Sunucu hatası',
    });
  }
};

// @desc    Bildirim ayarlarını güncelle
// @route   PUT /api/users/notification-settings
// @access  Private
exports.updateNotificationSettings = async (req, res) => {
  try {
    // Test kullanıcısı için özel durum
    if (req.user._id === '123456') {
      return res.status(200).json({
        success: true,
        notificationSettings: req.body.notificationSettings || {
          email: true,
          push: true,
          sms: false
        }
      });
    }

    const { notificationSettings } = req.body;

    // Kullanıcıyı güncelle
    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        notificationSettings,
      },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        message: 'Kullanıcı bulunamadı',
      });
    }

    res.status(200).json({
      success: true,
      notificationSettings: user.notificationSettings,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Sunucu hatası',
    });
  }
};

// Tüm kullanıcıları getir
const getAllUsers = async (req, res) => {
  try {
    const users = await userService.getAllUsers();
    
    res.status(200).json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    console.error('Kullanıcılar alınırken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Kullanıcı detaylarını getir
const getUserById = async (req, res) => {
  try {
    const userId = req.params.id;
    
    // Kullanıcı kendi bilgilerini veya admin tüm kullanıcıları görebilir
    if (userId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu kullanıcıyı görüntüleme yetkiniz yok'
      });
    }
    
    const user = await userService.getUserById(userId);
    
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Kullanıcı detayları alınırken hata:', error);
    
    if (error.message.includes('Geçersiz kullanıcı ID') || error.message.includes('Kullanıcı bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Kullanıcı güncelle
const updateUser = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }
    
    const userId = req.params.id;
    
    // Kullanıcı kendi bilgilerini veya admin tüm kullanıcıları güncelleyebilir
    if (userId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu kullanıcıyı güncelleme yetkiniz yok'
      });
    }
    
    const updateData = {
      name: req.body.name,
      email: req.body.email,
      phone: req.body.phone,
      residence: req.body.residence
    };
    
    // Admin rolü değiştirebilir
    if (req.user.role === 'admin' && req.body.role) {
      updateData.role = req.body.role;
    }
    
    const user = await userService.updateUser(userId, updateData);
    
    res.status(200).json({
      success: true,
      message: 'Kullanıcı başarıyla güncellendi',
      data: user
    });
  } catch (error) {
    console.error('Kullanıcı güncellenirken hata:', error);
    
    if (error.message.includes('Geçersiz kullanıcı ID') || error.message.includes('Kullanıcı bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Bu e-posta adresi zaten kullanılıyor')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Kullanıcı sil
const deleteUser = async (req, res) => {
  try {
    const userId = req.params.id;
    
    await userService.deleteUser(userId);
    
    res.status(200).json({
      success: true,
      message: 'Kullanıcı başarıyla silindi'
    });
  } catch (error) {
    console.error('Kullanıcı silinirken hata:', error);
    
    if (error.message.includes('Geçersiz kullanıcı ID') || error.message.includes('Kullanıcı bulunamadı')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser
}; 