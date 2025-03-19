const jwt = require('jsonwebtoken');
const userService = require('../services/user.service');

// Kullanıcı kimlik doğrulama middleware'i
const protect = async (req, res, next) => {
  try {
    let token;

    // Token'ı header'dan al
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    // Token yoksa hata döndür
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Bu işlem için giriş yapmanız gerekiyor'
      });
    }

    try {
      // Token'ı doğrula ve kullanıcı bilgilerini al
      const user = await userService.verifyToken(token);
      
      // Kullanıcı bilgilerini request'e ekle
      req.user = user;
      next();
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: 'Geçersiz token, lütfen tekrar giriş yapın'
      });
    }
  } catch (error) {
    console.error('Auth middleware hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Rol bazlı yetkilendirme
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Bu işlem için giriş yapmanız gerekiyor'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Bu işlem için yetkiniz yok'
      });
    }

    next();
  };
};

module.exports = {
  protect,
  authorize
}; 