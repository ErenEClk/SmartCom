const mongoose = require('mongoose');
const Message = require('../models/message.model');
const User = require('../models/user.model');
const Notification = require('../models/notification.model');
const asyncHandler = require('../middlewares/async');
const ErrorResponse = require('../utils/errorResponse');

// @desc    Kullanıcının tüm mesajlarını getir
// @route   GET /api/messages
// @access  Private
exports.getMessages = asyncHandler(async (req, res, next) => {
  const userId = req.user.id;
  
  // Kullanıcının gönderdiği veya aldığı tüm mesajları getir
  const messages = await Message.find({
    $or: [
      { sender: userId, isDeleted: false },
      { receiver: userId, isDeleted: false },
    ],
  })
    .sort({ createdAt: -1 })
    .populate('sender', 'name email profileImage')
    .populate('receiver', 'name email profileImage');
  
  res.status(200).json({
    success: true,
    count: messages.length,
    data: messages,
  });
});

// @desc    Kullanıcının konuşmalarını getir
// @route   GET /api/messages/conversations
// @access  Private
exports.getConversations = asyncHandler(async (req, res, next) => {
  const userId = req.user.id;
  
  // Kullanıcının mesajlaştığı kişileri bul
  const conversations = await Message.aggregate([
    {
      $match: {
        $or: [
          { sender: mongoose.Types.ObjectId(userId), isDeleted: false },
          { receiver: mongoose.Types.ObjectId(userId), isDeleted: false },
        ],
      },
    },
    {
      $sort: { createdAt: -1 },
    },
    {
      $group: {
        _id: {
          $cond: [
            { $eq: ['$sender', mongoose.Types.ObjectId(userId)] },
            '$receiver',
            '$sender',
          ],
        },
        lastMessage: { $first: '$$ROOT' },
        unreadCount: {
          $sum: {
            $cond: [
              {
                $and: [
                  { $eq: ['$receiver', mongoose.Types.ObjectId(userId)] },
                  { $eq: ['$isRead', false] },
                ],
              },
              1,
              0,
            ],
          },
        },
      },
    },
    {
      $lookup: {
        from: 'users',
        localField: '_id',
        foreignField: '_id',
        as: 'user',
      },
    },
    {
      $unwind: '$user',
    },
    {
      $project: {
        _id: 1,
        user: {
          _id: 1,
          name: 1,
          email: 1,
          profileImage: 1,
        },
        lastMessage: 1,
        unreadCount: 1,
      },
    },
  ]);
  
  res.status(200).json({
    success: true,
    count: conversations.length,
    data: conversations,
  });
});

// @desc    İki kullanıcı arasındaki konuşmayı getir
// @route   GET /api/messages/conversation/:userId
// @access  Private
exports.getConversation = asyncHandler(async (req, res, next) => {
  const currentUserId = req.user.id;
  const otherUserId = req.params.userId;
  
  // Kullanıcının varlığını kontrol et
  const user = await User.findById(otherUserId);
  if (!user) {
    return next(new ErrorResponse(`${otherUserId} ID'li kullanıcı bulunamadı`, 404));
  }
  
  // İki kullanıcı arasındaki mesajları getir
  const messages = await Message.getConversation(currentUserId, otherUserId);
  
  // Okunmamış mesajları okundu olarak işaretle
  const unreadMessages = messages.filter(
    message => message.receiver.toString() === currentUserId && !message.isRead
  );
  
  const markAsReadPromises = unreadMessages.map(message => message.markAsRead());
  await Promise.all(markAsReadPromises);
  
  res.status(200).json({
    success: true,
    count: messages.length,
    data: messages,
  });
});

// @desc    Yeni mesaj gönder
// @route   POST /api/messages
// @access  Private
exports.sendMessage = asyncHandler(async (req, res, next) => {
  const { receiver, content, attachments } = req.body;
  
  // Alıcının varlığını kontrol et
  const receiverUser = await User.findById(receiver);
  if (!receiverUser) {
    return next(new ErrorResponse(`${receiver} ID'li alıcı bulunamadı`, 404));
  }
  
  // Mesajı oluştur
  const message = await Message.create({
    sender: req.user.id,
    receiver,
    content,
    attachments: attachments || [],
  });
  
  // Mesajı populate et
  const populatedMessage = await Message.findById(message._id)
    .populate('sender', 'name email profileImage')
    .populate('receiver', 'name email profileImage');
  
  // Alıcıya bildirim gönder
  await Notification.create({
    user: receiver,
    title: 'Yeni Mesaj',
    message: `${req.user.name} size yeni bir mesaj gönderdi`,
    type: 'message',
    relatedId: message._id,
  });
  
  res.status(201).json({
    success: true,
    data: populatedMessage,
  });
});

// @desc    Mesajı sil
// @route   DELETE /api/messages/:id
// @access  Private
exports.deleteMessage = asyncHandler(async (req, res, next) => {
  const message = await Message.findById(req.params.id);
  
  if (!message) {
    return next(new ErrorResponse(`${req.params.id} ID'li mesaj bulunamadı`, 404));
  }
  
  // Mesajın sahibi olup olmadığını kontrol et
  if (message.sender.toString() !== req.user.id && message.receiver.toString() !== req.user.id) {
    return next(new ErrorResponse('Bu mesajı silme yetkiniz yok', 403));
  }
  
  // Mesajı sil
  message.isDeleted = true;
  message.deletedBy = req.user.id;
  message.deletedAt = new Date();
  await message.save();
  
  res.status(200).json({
    success: true,
    data: {},
  });
});

// @desc    Okunmamış mesaj sayısını getir
// @route   GET /api/messages/unread-count
// @access  Private
exports.getUnreadCount = asyncHandler(async (req, res, next) => {
  const count = await Message.getUnreadCount(req.user.id);
  
  res.status(200).json({
    success: true,
    data: { count },
  });
}); 