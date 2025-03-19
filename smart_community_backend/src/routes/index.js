const express = require('express');
const router = express.Router();

// Route'ları içe aktar
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
const paymentRoutes = require('./payment.routes');
const announcementRoutes = require('./announcement.routes');
const notificationRoutes = require('./notification.routes');
const messagingRoutes = require('./messaging.routes');

// API route'larını tanımla
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/payments', paymentRoutes);
router.use('/announcements', announcementRoutes);
router.use('/notifications', notificationRoutes);
router.use('/messaging', messagingRoutes);

// Ana route
router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Smart Community AI API çalışıyor',
    version: '1.0.0'
  });
});

module.exports = router; 