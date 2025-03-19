import 'dart:async';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/models/payment_model.dart';
import 'package:smart_community_ai/core/models/announcement_model.dart';
import 'package:smart_community_ai/core/models/notification_model.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/models/survey_model.dart';
import 'package:smart_community_ai/core/models/message_model.dart';

class MockApiService {
  // Singleton pattern
  static final MockApiService _instance = MockApiService._internal();

  factory MockApiService() {
    return _instance;
  }

  MockApiService._internal();

  // Token
  String? _token;

  // Token ayarla
  void setToken(String token) {
    _token = token;
  }

  // Token temizle
  void clearToken() {
    _token = null;
  }

  // Giriş yap
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test@example.com' && password == 'password') {
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      setToken(token);
      return {
        'token': token,
        'user': {
          'id': '1',
          'name': 'Ahmet Yılmaz',
          'email': email,
        }
      };
    } else {
      throw Exception('Geçersiz e-posta veya şifre');
    }
  }

  // Çıkış yap
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    clearToken();
  }

  // Kullanıcı bilgilerini getir
  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(seconds: 1));

    return UserModel(
      id: '1',
      name: 'Ahmet Yılmaz',
      email: 'ahmet.yilmaz@example.com',
      phone: '+90 555 123 4567',
      profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
      residence: ResidenceModel(
        site: 'Yeşil Vadi Sitesi',
        block: 'A Blok',
        apartment: 'No: 5',
        status: 'Ev Sahibi',
      ),
    );
  }

  // Ödemeleri getir
  Future<List<PaymentModel>> getPayments() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      PaymentModel(
        id: '1',
        title: 'Şubat 2025 Aidat',
        amount: 750.0,
        dueDate: '15 Şubat 2025',
        paymentDate: '10 Şubat 2025',
        status: 'Ödendi',
        type: 'Aidat',
        description: 'Şubat 2025 ayı site aidat ödemesi',
      ),
      PaymentModel(
        id: '2',
        title: 'Mart 2025 Aidat',
        amount: 750.0,
        dueDate: '15 Mart 2025',
        paymentDate: '',
        status: 'Bekliyor',
        type: 'Aidat',
        description: 'Mart 2025 ayı site aidat ödemesi',
      ),
      PaymentModel(
        id: '3',
        title: 'Ocak 2025 Aidat',
        amount: 750.0,
        dueDate: '15 Ocak 2025',
        paymentDate: '12 Ocak 2025',
        status: 'Ödendi',
        type: 'Aidat',
        description: 'Ocak 2025 ayı site aidat ödemesi',
      ),
      PaymentModel(
        id: '4',
        title: 'Aralık 2024 Aidat',
        amount: 700.0,
        dueDate: '15 Aralık 2024',
        paymentDate: '14 Aralık 2024',
        status: 'Ödendi',
        type: 'Aidat',
        description: 'Aralık 2024 ayı site aidat ödemesi',
      ),
      PaymentModel(
        id: '5',
        title: 'Kasım 2024 Aidat',
        amount: 700.0,
        dueDate: '15 Kasım 2024',
        paymentDate: '10 Kasım 2024',
        status: 'Ödendi',
        type: 'Aidat',
        description: 'Kasım 2024 ayı site aidat ödemesi',
      ),
    ];
  }

  // Duyuruları getir
  Future<List<AnnouncementModel>> getAnnouncements() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      AnnouncementModel(
        id: '1',
        title: 'Asansör Bakımı',
        content: '18 Şubat Pazartesi günü saat 10:00-14:00 arasında asansörlerimizin yıllık bakımı yapılacaktır. Bu süre zarfında asansörler kullanılamayacaktır. Anlayışınız için teşekkür ederiz.',
        date: '15 Şubat 2025',
        author: 'Site Yönetimi',
        category: 'Bakım',
        isImportant: true,
        attachments: [],
      ),
      AnnouncementModel(
        id: '2',
        title: 'Su Kesintisi',
        content: '12 Şubat Çarşamba günü saat 09:00-13:00 arasında bölgemizde su kesintisi yaşanacaktır. Lütfen gerekli tedbirlerinizi alınız.',
        date: '10 Şubat 2025',
        author: 'Site Yönetimi',
        category: 'Kesinti',
        isImportant: true,
        attachments: [],
      ),
      AnnouncementModel(
        id: '3',
        title: 'Yeni Güvenlik Personeli',
        content: '1 Şubat 2025 tarihinden itibaren sitemizde yeni güvenlik personeli görev yapmaya başlamıştır. Kendilerine hoş geldiniz demenizi rica ederiz.',
        date: '1 Şubat 2025',
        author: 'Site Yönetimi',
        category: 'Genel',
        isImportant: false,
        attachments: [],
      ),
      AnnouncementModel(
        id: '4',
        title: 'Otopark Düzenlemesi',
        content: 'Sitemizin otoparkında yeni düzenleme yapılmıştır. Lütfen araçlarınızı size ayrılan alanlara park ediniz. Misafir araçları için ayrılan bölüme park etmeyiniz.',
        date: '25 Ocak 2025',
        author: 'Site Yönetimi',
        category: 'Genel',
        isImportant: false,
        attachments: [],
      ),
      AnnouncementModel(
        id: '5',
        title: 'Yeni Yıl Kutlaması',
        content: '31 Aralık 2024 akşamı saat 20:00\'de site sosyal tesisimizde yeni yıl kutlaması düzenlenecektir. Tüm site sakinlerimiz davetlidir.',
        date: '20 Aralık 2024',
        author: 'Site Yönetimi',
        category: 'Etkinlik',
        isImportant: false,
        attachments: [],
      ),
    ];
  }

  // Bildirimleri getir
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      NotificationModel(
        id: '1',
        title: 'Aidat Ödemesi',
        message: 'Şubat 2025 aidat ödemesi başarıyla gerçekleştirildi.',
        date: '15 Şubat 2025',
        time: '14:30',
        isRead: true,
        type: 'payment',
        relatedItemId: '1',
      ),
      NotificationModel(
        id: '2',
        title: 'Asansör Bakımı',
        message: '18 Şubat Pazartesi günü saat 10:00-14:00 arasında asansörlerimizin yıllık bakımı yapılacaktır.',
        date: '15 Şubat 2025',
        time: '10:15',
        isRead: false,
        type: 'announcement',
        relatedItemId: '1',
      ),
      NotificationModel(
        id: '3',
        title: 'Arıza Bildirimi Onaylandı',
        message: 'A Blok giriş kapısı arıza bildiriminiz onaylandı. Teknik ekibimiz en kısa sürede sorunu çözecektir.',
        date: '14 Şubat 2025',
        time: '16:45',
        isRead: true,
        type: 'issue',
        relatedItemId: '1',
      ),
      NotificationModel(
        id: '4',
        title: 'Yeni Anket',
        message: 'Site güvenliği hakkında yeni bir anket oluşturuldu. Görüşlerinizi paylaşmak için ankete katılabilirsiniz.',
        date: '13 Şubat 2025',
        time: '09:20',
        isRead: false,
        type: 'survey',
        relatedItemId: '1',
      ),
      NotificationModel(
        id: '5',
        title: 'Su Kesintisi',
        message: '12 Şubat Çarşamba günü saat 09:00-13:00 arasında bölgemizde su kesintisi yaşanacaktır.',
        date: '10 Şubat 2025',
        time: '11:30',
        isRead: true,
        type: 'announcement',
        relatedItemId: '2',
      ),
    ];
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markNotificationAsRead(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    // Gerçek bir API olmadığı için burada bir şey yapmıyoruz
  }

  // Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllNotificationsAsRead() async {
    await Future.delayed(const Duration(seconds: 1));
    // Gerçek bir API olmadığı için burada bir şey yapmıyoruz
  }

  // Arıza bildirimlerini getir
  Future<List<IssueModel>> getIssues() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      IssueModel(
        id: '1',
        title: 'A Blok Giriş Kapısı Arızası',
        description: 'A Blok giriş kapısı kapanmıyor. Lütfen en kısa sürede tamir edilmesini rica ederim.',
        category: 'Kapı/Pencere',
        status: 'İşleniyor',
        reportDate: '14 Şubat 2025',
        images: [],
        reportedBy: '1',
        assignedTo: '2',
        comments: [
          IssueComment(
            id: '1',
            comment: 'Bildiriminiz alınmıştır. Teknik ekibimiz en kısa sürede sorunu çözecektir.',
            date: '14 Şubat 2025',
            author: 'Site Yönetimi',
            authorRole: 'Yönetici',
          ),
          IssueComment(
            id: '2',
            comment: 'Teknik ekibimiz sorunu tespit etmiştir. Kapı motoru değiştirilecektir.',
            date: '15 Şubat 2025',
            author: 'Teknik Servis',
            authorRole: 'Teknisyen',
          ),
        ],
      ),
      IssueModel(
        id: '2',
        title: 'Bahçe Sulama Sistemi Arızası',
        description: 'Bahçe sulama sistemi çalışmıyor. Bazı sprinkler\'lar su püskürtmüyor.',
        category: 'Bahçe/Peyzaj',
        status: 'Bekliyor',
        reportDate: '10 Şubat 2025',
        images: [],
        reportedBy: '1',
        comments: [
          IssueComment(
            id: '3',
            comment: 'Bildiriminiz alınmıştır. İncelenecektir.',
            date: '10 Şubat 2025',
            author: 'Site Yönetimi',
            authorRole: 'Yönetici',
          ),
        ],
      ),
      IssueModel(
        id: '3',
        title: 'Otopark Aydınlatma Sorunu',
        description: 'Otopark B bölümündeki 3 adet lamba yanmıyor. Akşamları çok karanlık oluyor.',
        category: 'Elektrik',
        status: 'Tamamlandı',
        reportDate: '5 Şubat 2025',
        resolveDate: '7 Şubat 2025',
        images: [],
        reportedBy: '1',
        assignedTo: '3',
        comments: [
          IssueComment(
            id: '4',
            comment: 'Bildiriminiz alınmıştır. Elektrik ekibimiz kontrol edecektir.',
            date: '5 Şubat 2025',
            author: 'Site Yönetimi',
            authorRole: 'Yönetici',
          ),
          IssueComment(
            id: '5',
            comment: 'Lambalar değiştirilmiştir. Sorun çözülmüştür.',
            date: '7 Şubat 2025',
            author: 'Teknik Servis',
            authorRole: 'Teknisyen',
          ),
        ],
      ),
    ];
  }

  // Arıza bildirimi oluştur
  Future<IssueModel> createIssue(IssueModel issue) async {
    await Future.delayed(const Duration(seconds: 1));

    return IssueModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: issue.title,
      description: issue.description,
      category: issue.category,
      status: 'Bekliyor',
      reportDate: DateTime.now().toString().substring(0, 10),
      images: issue.images,
      reportedBy: '1',
      comments: [
        IssueComment(
          id: '1',
          comment: 'Bildiriminiz alınmıştır. İncelenecektir.',
          date: DateTime.now().toString().substring(0, 10),
          author: 'Site Yönetimi',
          authorRole: 'Yönetici',
        ),
      ],
    );
  }

  // Anketleri getir
  Future<List<SurveyModel>> getSurveys() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      SurveyModel(
        id: '1',
        title: 'Site Güvenliği Anketi',
        description: 'Site güvenliği hakkında görüşlerinizi paylaşmanızı rica ederiz.',
        startDate: '13 Şubat 2025',
        endDate: '20 Şubat 2025',
        createdBy: 'Site Yönetimi',
        isActive: true,
        hasVoted: false,
        questions: [
          SurveyQuestion(
            id: '1',
            question: 'Site güvenliğinden memnun musunuz?',
            type: 'single_choice',
            options: [
              SurveyOption(
                id: '1',
                text: 'Çok memnunum',
                votes: 15,
                percentage: 30.0,
              ),
              SurveyOption(
                id: '2',
                text: 'Memnunum',
                votes: 20,
                percentage: 40.0,
              ),
              SurveyOption(
                id: '3',
                text: 'Kararsızım',
                votes: 10,
                percentage: 20.0,
              ),
              SurveyOption(
                id: '4',
                text: 'Memnun değilim',
                votes: 5,
                percentage: 10.0,
              ),
            ],
          ),
          SurveyQuestion(
            id: '2',
            question: 'Hangi güvenlik önlemleri artırılmalıdır?',
            type: 'multiple_choice',
            options: [
              SurveyOption(
                id: '5',
                text: 'Kamera sistemi',
                votes: 30,
                percentage: 60.0,
              ),
              SurveyOption(
                id: '6',
                text: 'Güvenlik personeli sayısı',
                votes: 25,
                percentage: 50.0,
              ),
              SurveyOption(
                id: '7',
                text: 'Giriş kontrol sistemi',
                votes: 35,
                percentage: 70.0,
              ),
              SurveyOption(
                id: '8',
                text: 'Aydınlatma',
                votes: 20,
                percentage: 40.0,
              ),
            ],
          ),
          SurveyQuestion(
            id: '3',
            question: 'Güvenlik konusunda önerileriniz nelerdir?',
            type: 'text',
          ),
        ],
      ),
      SurveyModel(
        id: '2',
        title: 'Sosyal Tesis Kullanımı Anketi',
        description: 'Sosyal tesislerimizin kullanımı hakkında görüşlerinizi paylaşmanızı rica ederiz.',
        startDate: '1 Şubat 2025',
        endDate: '8 Şubat 2025',
        createdBy: 'Site Yönetimi',
        isActive: false,
        hasVoted: true,
        questions: [
          SurveyQuestion(
            id: '4',
            question: 'Sosyal tesisleri ne sıklıkla kullanıyorsunuz?',
            type: 'single_choice',
            options: [
              SurveyOption(
                id: '9',
                text: 'Her gün',
                votes: 10,
                percentage: 20.0,
              ),
              SurveyOption(
                id: '10',
                text: 'Haftada birkaç kez',
                votes: 15,
                percentage: 30.0,
              ),
              SurveyOption(
                id: '11',
                text: 'Ayda birkaç kez',
                votes: 20,
                percentage: 40.0,
              ),
              SurveyOption(
                id: '12',
                text: 'Hiç kullanmıyorum',
                votes: 5,
                percentage: 10.0,
              ),
            ],
            userAnswer: '10',
          ),
          SurveyQuestion(
            id: '5',
            question: 'Hangi sosyal tesisleri daha çok kullanıyorsunuz?',
            type: 'multiple_choice',
            options: [
              SurveyOption(
                id: '13',
                text: 'Yüzme havuzu',
                votes: 30,
                percentage: 60.0,
              ),
              SurveyOption(
                id: '14',
                text: 'Fitness salonu',
                votes: 25,
                percentage: 50.0,
              ),
              SurveyOption(
                id: '15',
                text: 'Sauna',
                votes: 15,
                percentage: 30.0,
              ),
              SurveyOption(
                id: '16',
                text: 'Toplantı salonu',
                votes: 10,
                percentage: 20.0,
              ),
            ],
            userAnswers: ['13', '14'],
          ),
        ],
      ),
    ];
  }

  // Ankete oy ver
  Future<void> voteSurvey(String surveyId, Map<String, dynamic> answers) async {
    await Future.delayed(const Duration(seconds: 1));
    // Gerçek bir API olmadığı için burada bir şey yapmıyoruz
  }

  // Konuşmaları getir
  Future<List<ConversationModel>> getConversations() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      ConversationModel(
        id: '1',
        userId: '2',
        userName: 'Site Yönetimi',
        lastMessage: 'Bildiriminiz için teşekkür ederiz. En kısa sürede dönüş yapacağız.',
        lastMessageDate: '15 Şubat 2025',
        lastMessageTime: '14:30',
        hasUnreadMessages: false,
        unreadCount: 0,
        userAvatar: 'https://randomuser.me/api/portraits/men/10.jpg',
      ),
      ConversationModel(
        id: '2',
        userId: '3',
        userName: 'Teknik Servis',
        lastMessage: 'Arıza bildiriminiz için teşekkürler. Yarın saat 10:00\'da geleceğiz.',
        lastMessageDate: '14 Şubat 2025',
        lastMessageTime: '16:45',
        hasUnreadMessages: true,
        unreadCount: 1,
        userAvatar: 'https://randomuser.me/api/portraits/men/15.jpg',
      ),
    ];
  }

  // Mesajları getir
  Future<List<MessageModel>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (conversationId == '1') {
      return [
        MessageModel(
          id: '1',
          senderId: '1',
          receiverId: '2',
          senderName: 'Ahmet Yılmaz',
          receiverName: 'Site Yönetimi',
          content: 'Merhaba, A Blok giriş kapısı arızalı. Kapı kapanmıyor.',
          date: '14 Şubat 2025',
          time: '15:30',
          isRead: true,
        ),
        MessageModel(
          id: '2',
          senderId: '2',
          receiverId: '1',
          senderName: 'Site Yönetimi',
          receiverName: 'Ahmet Yılmaz',
          content: 'Merhaba Ahmet Bey, bildiriminiz için teşekkür ederiz. Teknik ekibimiz en kısa sürede sorunu çözecektir.',
          date: '14 Şubat 2025',
          time: '15:45',
          isRead: true,
        ),
        MessageModel(
          id: '3',
          senderId: '1',
          receiverId: '2',
          senderName: 'Ahmet Yılmaz',
          receiverName: 'Site Yönetimi',
          content: 'Teşekkür ederim.',
          date: '14 Şubat 2025',
          time: '16:00',
          isRead: true,
        ),
        MessageModel(
          id: '4',
          senderId: '2',
          receiverId: '1',
          senderName: 'Site Yönetimi',
          receiverName: 'Ahmet Yılmaz',
          content: 'Bildiriminiz için teşekkür ederiz. En kısa sürede dönüş yapacağız.',
          date: '15 Şubat 2025',
          time: '14:30',
          isRead: true,
        ),
      ];
    } else if (conversationId == '2') {
      return [
        MessageModel(
          id: '5',
          senderId: '1',
          receiverId: '3',
          senderName: 'Ahmet Yılmaz',
          receiverName: 'Teknik Servis',
          content: 'Merhaba, dairemde lavabo tıkanıklığı var. Ne zaman gelip bakabilirsiniz?',
          date: '14 Şubat 2025',
          time: '16:30',
          isRead: true,
        ),
        MessageModel(
          id: '6',
          senderId: '3',
          receiverId: '1',
          senderName: 'Teknik Servis',
          receiverName: 'Ahmet Yılmaz',
          content: 'Merhaba Ahmet Bey, yarın saat 10:00\'da gelebiliriz. Uygun mu?',
          date: '14 Şubat 2025',
          time: '16:45',
          isRead: false,
        ),
      ];
    } else {
      return [];
    }
  }

  // Mesaj gönder
  Future<MessageModel> sendMessage(MessageModel message) async {
    await Future.delayed(const Duration(seconds: 1));

    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: message.senderId,
      receiverId: message.receiverId,
      senderName: message.senderName,
      receiverName: message.receiverName,
      content: message.content,
      date: DateTime.now().toString().substring(0, 10),
      time: '${DateTime.now().hour}:${DateTime.now().minute}',
      isRead: false,
      attachments: message.attachments,
    );
  }

  // Şifre değiştir
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));

    if (currentPassword != 'password') {
      throw Exception('Mevcut şifre yanlış');
    }
  }

  // Bildirim ayarlarını getir
  Future<Map<String, dynamic>> getNotificationSettings() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'pushNotificationsEnabled': true,
      'emailNotificationsEnabled': true,
      'smsNotificationsEnabled': false,
      'notificationCategories': {
        'payments': true,
        'announcements': true,
        'issues': true,
        'surveys': true,
        'messages': true,
        'maintenance': true,
      },
    };
  }

  // Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    await Future.delayed(const Duration(seconds: 1));
    // Gerçek bir API olmadığı için burada bir şey yapmıyoruz
  }
} 