const Issue = require('../models/issue.model');
const User = require('../models/user.model');
const AppError = require('../utils/appError');
const catchAsync = require('../utils/catchAsync');

// Tüm arıza bildirimlerini getir
exports.getAllIssues = catchAsync(async (req, res, next) => {
  const issues = await Issue.find()
    .populate('reporter', 'name email')
    .populate('comments.user', 'name email role')
    .sort({ createdAt: -1 });

  res.status(200).json({
    status: 'success',
    results: issues.length,
    data: {
      issues
    }
  });
});

// Belirli bir arıza bildirimini getir
exports.getIssue = catchAsync(async (req, res, next) => {
  const issue = await Issue.findById(req.params.id)
    .populate('reporter', 'name email')
    .populate('comments.user', 'name email role');

  if (!issue) {
    return next(new AppError('Bu ID ile arıza bildirimi bulunamadı', 404));
  }

  res.status(200).json({
    status: 'success',
    data: {
      issue
    }
  });
});

// Yeni arıza bildirimi oluştur
exports.createIssue = catchAsync(async (req, res, next) => {
  // Resim dosyalarının yollarını al
  const images = [];
  if (req.files && req.files.length > 0) {
    req.files.forEach(file => {
      images.push(`/uploads/${file.filename}`);
    });
  }

  // Arıza bildirimini oluştur
  const newIssue = await Issue.create({
    title: req.body.title,
    description: req.body.description,
    category: req.body.category,
    isUrgent: req.body.isUrgent === 'true',
    images,
    reporter: req.user.id,
    status: 'Beklemede'
  });

  // Oluşturulan arıza bildirimini getir
  const issue = await Issue.findById(newIssue._id)
    .populate('reporter', 'name email')
    .populate('comments.user', 'name email role');

  res.status(201).json({
    status: 'success',
    data: {
      issue
    }
  });
});

// Arıza bildirimini güncelle
exports.updateIssue = catchAsync(async (req, res, next) => {
  const issue = await Issue.findById(req.params.id);

  if (!issue) {
    return next(new AppError('Bu ID ile arıza bildirimi bulunamadı', 404));
  }

  // Sadece admin veya arıza bildirimini oluşturan kişi güncelleyebilir
  if (req.user.role !== 'admin' && issue.reporter.toString() !== req.user.id) {
    return next(new AppError('Bu arıza bildirimini güncelleme yetkiniz yok', 403));
  }

  // Güncelleme işlemi
  const updatedIssue = await Issue.findByIdAndUpdate(
    req.params.id,
    {
      title: req.body.title || issue.title,
      description: req.body.description || issue.description,
      category: req.body.category || issue.category,
      status: req.body.status || issue.status,
      isUrgent: req.body.isUrgent !== undefined ? req.body.isUrgent : issue.isUrgent
    },
    {
      new: true,
      runValidators: true
    }
  )
    .populate('reporter', 'name email')
    .populate('comments.user', 'name email role');

  res.status(200).json({
    status: 'success',
    data: {
      issue: updatedIssue
    }
  });
});

// Arıza bildirimini sil
exports.deleteIssue = catchAsync(async (req, res, next) => {
  const issue = await Issue.findById(req.params.id);

  if (!issue) {
    return next(new AppError('Bu ID ile arıza bildirimi bulunamadı', 404));
  }

  // Sadece admin veya arıza bildirimini oluşturan kişi silebilir
  if (req.user.role !== 'admin' && issue.reporter.toString() !== req.user.id) {
    return next(new AppError('Bu arıza bildirimini silme yetkiniz yok', 403));
  }

  await Issue.findByIdAndDelete(req.params.id);

  res.status(204).json({
    status: 'success',
    data: null
  });
});

// Arıza bildirimine yorum ekle
exports.addComment = catchAsync(async (req, res, next) => {
  const issue = await Issue.findById(req.params.id);

  if (!issue) {
    return next(new AppError('Bu ID ile arıza bildirimi bulunamadı', 404));
  }

  // Yorumu ekle
  issue.comments.push({
    text: req.body.text,
    user: req.user.id
  });

  await issue.save();

  // Güncellenmiş arıza bildirimini getir
  const updatedIssue = await Issue.findById(req.params.id)
    .populate('reporter', 'name email')
    .populate('comments.user', 'name email role');

  res.status(200).json({
    status: 'success',
    data: {
      issue: updatedIssue
    }
  });
}); 