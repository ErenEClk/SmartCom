const User = require('../models/user.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');

/**
 * Kullanıcı kaydı
 * @param {Object} userData - Kullanıcı verileri
 * @returns {Promise<Object>} Oluşturulan kullanıcı
 */
const registerUser = async (userData) => {
  try {
    const { name, email, password, phone, role, residence } = userData;

    // E-posta kontrolü
    const userExists = await User.findOne({ email });
    if (userExists) {
      throw new Error('Bu e-posta adresi zaten kullanılıyor');
    }

    // Şifre hashleme
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Kullanıcı oluşturma
    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      phone,
      role: role || 'user',
      residence: residence || {
        site: 'Örnek Site',
        block: 'A',
        apartment: '101',
        status: 'Sahibi'
      }
    });

    return {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role
    };
  } catch (error) {
    console.error('Kullanıcı kaydı servis hatası:', error);
    throw error;
  }
};

/**
 * Kullanıcı girişi
 * @param {string} email - E-posta
 * @param {string} password - Şifre
 * @returns {Promise<Object>} Token ve kullanıcı bilgileri
 */
const loginUser = async (email, password) => {
  try {
    // Test kullanıcıları
    if (email === 'test@example.com' && password === 'password') {
      const token = jwt.sign(
        { id: '123456', email },
        process.env.JWT_SECRET || 'gizli_anahtar',
        { expiresIn: '30d' }
      );

      return {
        token,
        user: {
          id: '123456',
          name: 'Test Kullanıcı',
          email: 'test@example.com',
          role: 'user',
          residence: {
            site: 'Örnek Site',
            block: 'A',
            apartment: '101',
            status: 'Sahibi'
          }
        }
      };
    }
    
    if (email === 'kullanici@example.com' && password === '123456') {
      const token = jwt.sign(
        { id: 'user1', email },
        process.env.JWT_SECRET || 'gizli_anahtar',
        { expiresIn: '30d' }
      );

      return {
        token,
        user: {
          id: 'user1',
          name: 'Normal Kullanıcı',
          email: 'kullanici@example.com',
          role: 'user',
          residence: {
            site: 'Örnek Site',
            block: 'B',
            apartment: '202',
            status: 'Sahibi'
          }
        }
      };
    }
    
    if (email === 'admin@example.com' && password === '123456') {
      const token = jwt.sign(
        { id: 'admin1', email },
        process.env.JWT_SECRET || 'gizli_anahtar',
        { expiresIn: '30d' }
      );

      return {
        token,
        user: {
          id: 'admin1',
          name: 'Admin Kullanıcı',
          email: 'admin@example.com',
          role: 'admin',
          residence: {
            site: 'Örnek Site',
            block: 'A',
            apartment: '101',
            status: 'Yönetici'
          }
        }
      };
    }

    // Gerçek kullanıcı kontrolü
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      throw new Error('Geçersiz e-posta veya şifre');
    }

    // Şifre kontrolü
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new Error('Geçersiz e-posta veya şifre');
    }

    // Token oluşturma
    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET || 'gizli_anahtar',
      { expiresIn: process.env.JWT_EXPIRE || '30d' }
    );

    return {
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        residence: user.residence
      }
    };
  } catch (error) {
    console.error('Kullanıcı girişi servis hatası:', error);
    throw error;
  }
};

/**
 * Kullanıcı bilgilerini getir
 * @param {string} userId - Kullanıcı ID
 * @returns {Promise<Object>} Kullanıcı bilgileri
 */
const getUserById = async (userId) => {
  try {
    // Test kullanıcıları için
    if (userId === '123456' || userId === 'user1' || userId === 'admin1') {
      let user = {
        id: userId,
        name: 'Test Kullanıcı',
        email: 'test@example.com',
        role: 'user',
        residence: {
          site: 'Örnek Site',
          block: 'A',
          apartment: '101',
          status: 'Sahibi'
        }
      };
      
      if (userId === 'user1') {
        user.name = 'Normal Kullanıcı';
        user.email = 'kullanici@example.com';
      } else if (userId === 'admin1') {
        user.name = 'Admin Kullanıcı';
        user.email = 'admin@example.com';
        user.role = 'admin';
        user.residence.status = 'Yönetici';
      }
      
      return user;
    }
    
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      throw new Error('Geçersiz kullanıcı ID');
    }
    
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('Kullanıcı bulunamadı');
    }
    
    return {
      id: user._id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      residence: user.residence,
      profileImage: user.profileImage,
      createdAt: user.createdAt
    };
  } catch (error) {
    console.error('Kullanıcı bilgileri alınırken servis hatası:', error);
    throw error;
  }
};

/**
 * Tüm kullanıcıları getir
 * @returns {Promise<Array>} Kullanıcılar listesi
 */
const getAllUsers = async () => {
  try {
    const users = await User.find().select('-password');
    
    // Test kullanıcılarını ekle
    const testUsers = [
      {
        id: 'user1',
        name: 'Normal Kullanıcı',
        email: 'kullanici@example.com',
        role: 'user',
        residence: {
          site: 'Örnek Site',
          block: 'B',
          apartment: '202',
          status: 'Sahibi'
        },
        createdAt: new Date()
      },
      {
        id: 'admin1',
        name: 'Admin Kullanıcı',
        email: 'admin@example.com',
        role: 'admin',
        residence: {
          site: 'Örnek Site',
          block: 'A',
          apartment: '101',
          status: 'Yönetici'
        },
        createdAt: new Date()
      }
    ];
    
    return [...users, ...testUsers];
  } catch (error) {
    console.error('Kullanıcılar alınırken servis hatası:', error);
    throw new Error('Kullanıcılar alınırken bir hata oluştu');
  }
};

/**
 * Kullanıcı güncelle
 * @param {string} userId - Kullanıcı ID
 * @param {Object} updateData - Güncellenecek veriler
 * @returns {Promise<Object>} Güncellenmiş kullanıcı
 */
const updateUser = async (userId, updateData) => {
  try {
    // Test kullanıcıları için
    if (userId === '123456' || userId === 'user1' || userId === 'admin1') {
      return {
        id: userId,
        name: updateData.name || 'Test Kullanıcı',
        email: updateData.email || 'test@example.com',
        role: updateData.role || 'user',
        residence: updateData.residence || {
          site: 'Örnek Site',
          block: 'A',
          apartment: '101',
          status: 'Sahibi'
        }
      };
    }
    
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      throw new Error('Geçersiz kullanıcı ID');
    }
    
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('Kullanıcı bulunamadı');
    }
    
    // Güncellenebilir alanlar
    const { name, email, phone, role, residence } = updateData;
    
    if (name) user.name = name;
    if (email) {
      // E-posta değişiyorsa, benzersiz olduğunu kontrol et
      if (email !== user.email) {
        const emailExists = await User.findOne({ email });
        if (emailExists) {
          throw new Error('Bu e-posta adresi zaten kullanılıyor');
        }
        user.email = email;
      }
    }
    if (phone) user.phone = phone;
    if (role) user.role = role;
    if (residence) user.residence = residence;
    
    await user.save();
    
    return {
      id: user._id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      residence: user.residence
    };
  } catch (error) {
    console.error('Kullanıcı güncellenirken servis hatası:', error);
    throw error;
  }
};

/**
 * Kullanıcı sil
 * @param {string} userId - Kullanıcı ID
 * @returns {Promise<boolean>} Silme işlemi başarılı mı
 */
const deleteUser = async (userId) => {
  try {
    // Test kullanıcıları için
    if (userId === '123456' || userId === 'user1' || userId === 'admin1') {
      return true;
    }
    
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      throw new Error('Geçersiz kullanıcı ID');
    }
    
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('Kullanıcı bulunamadı');
    }
    
    await User.findByIdAndDelete(userId);
    return true;
  } catch (error) {
    console.error('Kullanıcı silinirken servis hatası:', error);
    throw error;
  }
};

/**
 * Şifre değiştir
 * @param {string} userId - Kullanıcı ID
 * @param {string} currentPassword - Mevcut şifre
 * @param {string} newPassword - Yeni şifre
 * @returns {Promise<boolean>} Şifre değiştirme işlemi başarılı mı
 */
const changePassword = async (userId, currentPassword, newPassword) => {
  try {
    // Test kullanıcıları için
    if (userId === '123456' || userId === 'user1' || userId === 'admin1') {
      return true;
    }
    
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      throw new Error('Geçersiz kullanıcı ID');
    }
    
    const user = await User.findById(userId).select('+password');
    if (!user) {
      throw new Error('Kullanıcı bulunamadı');
    }
    
    // Mevcut şifre kontrolü
    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      throw new Error('Mevcut şifre yanlış');
    }
    
    // Yeni şifre hashleme
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    
    await user.save();
    return true;
  } catch (error) {
    console.error('Şifre değiştirme servis hatası:', error);
    throw error;
  }
};

/**
 * Token doğrulama
 * @param {string} token - JWT token
 * @returns {Promise<Object>} Kullanıcı bilgileri
 */
const verifyToken = async (token) => {
  try {
    if (!token) {
      throw new Error('Token bulunamadı');
    }
    
    // Token'ı doğrula
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'gizli_anahtar');
    
    // Test kullanıcıları için
    if (decoded.id === '123456' || decoded.id === 'user1' || decoded.id === 'admin1') {
      let user = {
        id: decoded.id,
        name: 'Test Kullanıcı',
        email: 'test@example.com',
        role: 'user'
      };
      
      if (decoded.id === 'user1') {
        user.name = 'Normal Kullanıcı';
        user.email = 'kullanici@example.com';
      } else if (decoded.id === 'admin1') {
        user.name = 'Admin Kullanıcı';
        user.email = 'admin@example.com';
        user.role = 'admin';
      }
      
      return user;
    }
    
    // Kullanıcıyı bul
    const user = await User.findById(decoded.id);
    if (!user) {
      throw new Error('Geçersiz token - kullanıcı bulunamadı');
    }
    
    return {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role
    };
  } catch (error) {
    console.error('Token doğrulama servis hatası:', error);
    throw error;
  }
};

// E-posta ile kullanıcı getir
const getUserByEmail = async (email) => {
  try {
    // Test kullanıcıları için kontrol
    if (email === 'test@example.com') {
      return {
        id: '123456',
        name: 'Test Kullanıcı',
        email: 'test@example.com',
        role: 'user',
        residence: {
          site: 'Örnek Site',
          block: 'A',
          apartment: '101',
          status: 'Sahibi'
        }
      };
    }
    
    if (email === 'kullanici@example.com') {
      return {
        id: 'user1',
        name: 'Normal Kullanıcı',
        email: 'kullanici@example.com',
        role: 'user',
        residence: {
          site: 'Örnek Site',
          block: 'B',
          apartment: '202',
          status: 'Sahibi'
        }
      };
    }
    
    if (email === 'admin@example.com') {
      return {
        id: 'admin1',
        name: 'Admin Kullanıcı',
        email: 'admin@example.com',
        role: 'admin',
        residence: {
          site: 'Örnek Site',
          block: 'A',
          apartment: '101',
          status: 'Yönetici'
        }
      };
    }
    
    // Veritabanından kullanıcıyı bul
    const user = await User.findOne({ email });
    
    if (!user) {
      throw new Error('Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı');
    }
    
    return {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone,
      residence: user.residence
    };
  } catch (error) {
    console.error('Kullanıcı e-posta ile aranırken hata:', error);
    throw error;
  }
};

// Şifre sıfırlama
const resetPassword = async (token, newPassword) => {
  try {
    // Token doğrulama
    if (!token) {
      throw new Error('Geçersiz veya süresi dolmuş token');
    }
    
    // Test kullanıcıları için
    if (token === 'test_token') {
      return true;
    }
    
    // Veritabanında token'a sahip kullanıcıyı bul
    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpire: { $gt: Date.now() }
    });
    
    if (!user) {
      throw new Error('Geçersiz veya süresi dolmuş token');
    }
    
    // Şifreyi hashle ve güncelle
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    
    await user.save();
    
    return true;
  } catch (error) {
    console.error('Şifre sıfırlanırken hata:', error);
    throw error;
  }
};

module.exports = {
  registerUser,
  loginUser,
  getUserById,
  getAllUsers,
  updateUser,
  deleteUser,
  changePassword,
  verifyToken,
  getUserByEmail,
  resetPassword
}; 