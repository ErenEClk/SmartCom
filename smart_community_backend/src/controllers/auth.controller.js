const userService = require('../services/user.service');
const { validationResult } = require('express-validator');

// Kullanıcı kaydı
const register = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const userData = {
      name: req.body.name,
      email: req.body.email,
      password: req.body.password,
      phone: req.body.phone,
      role: req.body.role,
      residence: req.body.residence
    };

    const user = await userService.registerUser(userData);

    // Başarılı yanıt
    res.status(201).json({
      success: true,
      message: 'Kullanıcı başarıyla oluşturuldu',
      data: user
    });
  } catch (error) {
    console.error('Kayıt hatası:', error);
    
    // E-posta zaten kullanılıyor hatası
    if (error.message === 'Bu e-posta adresi zaten kullanılıyor') {
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

// Kullanıcı girişi
const login = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { email, password } = req.body;
    
    const result = await userService.loginUser(email, password);

    // Başarılı yanıt
    res.status(200).json({
      success: true,
      message: 'Giriş başarılı',
      token: result.token,
      user: result.user
    });
  } catch (error) {
    console.error('Giriş hatası:', error);
    
    // Geçersiz kimlik bilgileri hatası
    if (error.message === 'Geçersiz e-posta veya şifre') {
      return res.status(401).json({
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

// Çıkış yap
const logout = async (req, res) => {
  try {
    // Çıkış işlemi için özel bir işlem yok, client tarafında token temizlenir
    res.status(200).json({
      success: true,
      message: 'Çıkış başarılı',
    });
  } catch (error) {
    console.error('Çıkış hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası',
    });
  }
};

// Şifremi unuttum
const forgotPassword = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { email } = req.body;

    try {
      // Kullanıcı kontrolü
      const user = await userService.getUserByEmail(email);
      
      // Gerçek uygulamada şifre sıfırlama e-postası gönderilir
      // Şimdilik sadece başarılı yanıt dönüyoruz
      res.status(200).json({
        success: true,
        message: 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'
      });
    } catch (error) {
      // Kullanıcı bulunamadı hatası
      return res.status(404).json({
        success: false,
        message: 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı'
      });
    }
  } catch (error) {
    console.error('Şifremi unuttum hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Şifre sıfırlama
const resetPassword = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { token, password } = req.body;

    try {
      // Token doğrulama ve şifre sıfırlama
      await userService.resetPassword(token, password);
      
      res.status(200).json({
        success: true,
        message: 'Şifreniz başarıyla sıfırlandı'
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
  } catch (error) {
    console.error('Şifre sıfırlama hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Kullanıcı bilgilerini getir
const getMe = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const user = await userService.getUserById(userId);
    
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Kullanıcı bilgileri alınırken hata:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Şifre değiştir
const changePassword = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { currentPassword, newPassword } = req.body;
    const userId = req.user.id;
    
    try {
      await userService.changePassword(userId, currentPassword, newPassword);
      
      res.status(200).json({
        success: true,
        message: 'Şifreniz başarıyla değiştirildi'
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
  } catch (error) {
    console.error('Şifre değiştirme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Kullanıcı bilgilerini güncelle
const updateProfile = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const userId = req.user.id;
    const updateData = {
      name: req.body.name,
      email: req.body.email,
      phone: req.body.phone,
      residence: req.body.residence
    };
    
    try {
      const updatedUser = await userService.updateUser(userId, updateData);
      
      res.status(200).json({
        success: true,
        message: 'Profiliniz başarıyla güncellendi',
        data: updatedUser
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
  } catch (error) {
    console.error('Profil güncelleme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  register,
  login,
  logout,
  forgotPassword,
  resetPassword,
  getMe,
  changePassword,
  updateProfile
}; 