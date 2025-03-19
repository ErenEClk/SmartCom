const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  receiver: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  conversation: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Conversation',
    required: true
  },
  content: {
    type: String,
    required: true
  },
  attachments: [{
    url: String,
    name: String,
    size: Number,
    mimeType: String
  }],
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: Date,
  isDelivered: {
    type: Boolean,
    default: false
  },
  deliveredAt: Date,
  isDeleted: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: Date
});

// Güncelleme öncesi updatedAt alanını güncelle
messageSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updatedAt: new Date() });
  next();
});

// Mesajları tarih sırasına göre getiren statik metod
messageSchema.statics.getConversation = async function(user1Id, user2Id) {
  return this.find({
    $or: [
      { sender: user1Id, receiver: user2Id, isDeleted: false },
      { sender: user2Id, receiver: user1Id, isDeleted: false },
    ],
  })
    .sort({ createdAt: 1 })
    .populate('sender', 'name email profileImage')
    .populate('receiver', 'name email profileImage');
};

// Okunmamış mesaj sayısını getiren statik metod
messageSchema.statics.getUnreadCount = async function(userId) {
  return this.countDocuments({
    receiver: userId,
    isRead: false,
    isDeleted: false,
  });
};

// Mesajı okundu olarak işaretleyen metod
messageSchema.methods.markAsRead = async function() {
  if (!this.isRead) {
    this.isRead = true;
    this.readAt = new Date();
    await this.save();
  }
  return this;
};

module.exports = mongoose.model('Message', messageSchema); 