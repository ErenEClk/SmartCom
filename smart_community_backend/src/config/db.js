const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // MongoDB bağlantı URL'si
    const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/smart_community';
    
    // Bağlantı seçenekleri
    const options = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000, // Sunucu seçim zaman aşımı
      socketTimeoutMS: 45000, // Soket zaman aşımı
      family: 4, // IPv4 kullan
      maxPoolSize: 10, // Maksimum bağlantı havuzu boyutu
      retryWrites: true, // Yazma işlemlerini yeniden dene
    };

    // MongoDB'ye bağlan
    const conn = await mongoose.connect(mongoURI, options);
    
    console.log(`MongoDB bağlantısı başarılı: ${conn.connection.host}`);
    
    // Bağlantı olaylarını dinle
    mongoose.connection.on('error', (err) => {
      console.error(`MongoDB bağlantı hatası: ${err.message}`);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('MongoDB bağlantısı kesildi, yeniden bağlanmaya çalışılacak...');
      setTimeout(connectDB, 5000); // 5 saniye sonra yeniden bağlanmayı dene
    });
    
    return conn;
  } catch (error) {
    console.error(`MongoDB bağlantı hatası: ${error.message}`);
    
    // Test modu kontrolü
    if (process.env.NODE_ENV === 'test' || process.env.NODE_ENV === 'development') {
      console.log('Test/Geliştirme modunda çalışılıyor, veritabanı olmadan devam edilecek...');
      return null;
    }
    
    // Üretim ortamında ise 5 saniye sonra yeniden bağlanmayı dene
    console.log('5 saniye sonra yeniden bağlanmaya çalışılacak...');
    setTimeout(connectDB, 5000);
  }
};

module.exports = connectDB; 