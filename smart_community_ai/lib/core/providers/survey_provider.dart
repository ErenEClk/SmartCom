import 'package:flutter/material.dart';
import 'package:smart_community_ai/core/models/survey_model.dart';
import 'package:smart_community_ai/core/services/api_service.dart';
import 'package:smart_community_ai/core/constants/api_constants.dart';
import 'package:uuid/uuid.dart';

class SurveyProvider with ChangeNotifier {
  final ApiService _apiService;
  final bool isTestMode;
  List<SurveyModel> _surveys = [];
  bool _isLoading = false;
  String? _error;

  SurveyProvider({
    required ApiService apiService,
    this.isTestMode = false,
  }) : _apiService = apiService;

  List<SurveyModel> get surveys => _surveys;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Anketleri getir
  Future<bool> fetchSurveys() async {
    // Eğer zaten yükleme yapılıyorsa, işlemi tekrarlama
    if (_isLoading) {
      print('Anketler zaten yükleniyor, işlem tekrarlanmayacak');
      return false;
    }
    
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      if (isTestMode) {
        // Test modunda örnek anketler
        await Future.delayed(const Duration(seconds: 1));
        _surveys = _getTestSurveys();
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return true;
      }
      
      // Normal API çağrısı
      try {
        final response = await _apiService.get(ApiConstants.surveysEndpoint);
        
        if (response['success']) {
          final List<dynamic> data = response['data'];
          _surveys = data.map((item) => SurveyModel.fromJson(item)).toList();
          _isLoading = false;
          Future.microtask(() => notifyListeners());
          return true;
        } else {
          _error = response['message'] ?? 'Anketler alınamadı';
          _isLoading = false;
          Future.microtask(() => notifyListeners());
          return false;
        }
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        
        // Hata durumunda test verilerini kullan
        if (isTestMode) {
          _surveys = _getTestSurveys();
          Future.microtask(() => notifyListeners());
          return true;
        }
        
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      
      // Hata durumunda test verilerini kullan
      if (isTestMode) {
        _surveys = _getTestSurveys();
        Future.microtask(() => notifyListeners());
        return true;
      }
      
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  // Anket oluştur
  Future<bool> createSurvey(Map<String, dynamic> surveyData) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda yeni anket oluştur
        print('Test modunda anket oluşturuluyor: $surveyData');
        await Future.delayed(const Duration(seconds: 1));
        
        final uuid = const Uuid();
        final newSurvey = SurveyModel(
          id: uuid.v4(),
          title: surveyData['title'] ?? '',
          description: surveyData['description'] ?? '',
          startDate: surveyData['startDate'] ?? DateTime.now().toIso8601String(),
          endDate: surveyData['endDate'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          createdBy: 'Test Kullanıcısı',
          isActive: surveyData['isActive'] ?? true,
          hasVoted: false,
          questions: _createQuestionsFromData(surveyData['questions'] ?? []),
        );
        
        _surveys.insert(0, newSurvey);
        _setLoading(false);
        Future.microtask(() => notifyListeners());
        return true;
      }
      
      // Normal API çağrısı
      try {
        final response = await _apiService.post(ApiConstants.surveysEndpoint, surveyData);
        
        if (response['success']) {
          await fetchSurveys();
          return true;
        } else {
          _error = response['message'] ?? 'Anket oluşturulamadı';
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return false;
        }
      } catch (e) {
        _error = 'Anket oluşturulurken hata oluştu: $e';
        _setLoading(false);
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  // Ankete cevap ver
  Future<bool> submitSurveyResponse(String surveyId, Map<String, dynamic> responseData) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda anket cevapla
        print('Test modunda ankete cevap veriliyor: $responseData');
        await Future.delayed(const Duration(seconds: 1));
        
        // Anketi bul ve güncelle
        final surveyIndex = _surveys.indexWhere((s) => s.id == surveyId);
        if (surveyIndex != -1) {
          // Anket bulundu, cevapları ekle (bu sadece test için)
          print('Anket cevapları kaydedildi (test)');
          
          // Anket listesini güncelle - gerçek uygulamada burada anket cevapları işlenecek
          final updatedSurveys = List<SurveyModel>.from(_surveys);
          final currentSurvey = updatedSurveys[surveyIndex];
          
          // Yeni bir SurveyModel oluştur ve hasVoted'ı true yap
          final updatedSurvey = SurveyModel(
            id: currentSurvey.id,
            title: currentSurvey.title,
            description: currentSurvey.description,
            startDate: currentSurvey.startDate,
            endDate: currentSurvey.endDate,
            createdBy: currentSurvey.createdBy,
            isActive: currentSurvey.isActive,
            questions: _updateQuestionsWithResponses(currentSurvey.questions, responseData),
            hasVoted: true,
          );
          
          updatedSurveys[surveyIndex] = updatedSurvey;
          _surveys = updatedSurveys;
          
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return true;
        } else {
          _error = 'Anket bulunamadı';
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return false;
        }
      }
      
      // Normal API çağrısı
      try {
        final endpoint = '${ApiConstants.surveysEndpoint}/$surveyId/responses';
        final response = await _apiService.post(endpoint, responseData);
        
        if (response['success']) {
          // Anketleri yeniden yükle veya sadece ilgili anketi güncelle
          await fetchSurveys();
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return true;
        } else {
          _error = response['message'] ?? 'Anket cevapları gönderilemedi';
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return false;
        }
      } catch (e) {
        _error = 'Anket cevapları gönderilirken hata oluştu: $e';
        _setLoading(false);
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  // Yükleme durumunu güncelle
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      Future.microtask(() => notifyListeners());
    }
  }
  
  // JSON verilerinden SurveyQuestion listesi oluştur
  List<SurveyQuestion> _createQuestionsFromData(List<dynamic> questionsData) {
    return questionsData.map((questionData) {
      final options = questionData['options'] != null 
          ? (questionData['options'] as List).map((optionText) {
              return SurveyOption(
                id: const Uuid().v4(),
                text: optionText,
                votes: 0,
                percentage: 0.0,
              );
            }).toList()
          : null;
      
      return SurveyQuestion(
        id: questionData['id'] ?? const Uuid().v4(),
        question: questionData['text'] ?? '',
        type: questionData['type'] ?? 'text',
        options: options,
      );
    }).toList();
  }
  
  // Kullanıcı cevaplarıyla soruları güncelle
  List<SurveyQuestion> _updateQuestionsWithResponses(
      List<SurveyQuestion> questions, Map<String, dynamic> responseData) {
    return questions.map((question) {
      if (responseData.containsKey(question.id)) {
        final response = responseData[question.id];
        
        if (question.type == 'text') {
          return SurveyQuestion(
            id: question.id,
            question: question.question,
            type: question.type,
            options: question.options,
            userAnswer: response as String,
          );
        } else if (question.type == 'multiple_choice') {
          return SurveyQuestion(
            id: question.id,
            question: question.question,
            type: question.type,
            options: question.options,
            userAnswers: (response as List).cast<String>(),
          );
        } else if (question.type == 'single_choice') {
          return SurveyQuestion(
            id: question.id,
            question: question.question,
            type: question.type,
            options: question.options,
            userAnswer: response as String,
          );
        }
      }
      return question;
    }).toList();
  }
  
  // Test için örnek anketler
  List<SurveyModel> _getTestSurveys() {
    return [
      SurveyModel(
        id: '1',
        title: 'Site Memnuniyet Anketi',
        description: 'Değerli site sakinlerimiz, sitenin yönetimi ve hizmetler hakkındaki düşüncelerinizi öğrenmek istiyoruz.',
        startDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        endDate: DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        createdBy: 'Site Yönetimi',
        isActive: true,
        hasVoted: false,
        questions: [
          SurveyQuestion(
            id: '1',
            question: 'Site yönetiminden ne kadar memnunsunuz?',
            type: 'single_choice',
            options: [
              SurveyOption(id: '1', text: 'Çok memnunum', votes: 10, percentage: 25.0),
              SurveyOption(id: '2', text: 'Memnunum', votes: 15, percentage: 37.5),
              SurveyOption(id: '3', text: 'Kararsızım', votes: 8, percentage: 20.0),
              SurveyOption(id: '4', text: 'Memnun değilim', votes: 5, percentage: 12.5),
              SurveyOption(id: '5', text: 'Hiç memnun değilim', votes: 2, percentage: 5.0),
            ],
          ),
          SurveyQuestion(
            id: '2',
            question: 'Hangi hizmetleri iyileştirmemizi istersiniz?',
            type: 'multiple_choice',
            options: [
              SurveyOption(id: '6', text: 'Temizlik', votes: 20, percentage: 40.0),
              SurveyOption(id: '7', text: 'Güvenlik', votes: 15, percentage: 30.0),
              SurveyOption(id: '8', text: 'Bahçe Bakımı', votes: 10, percentage: 20.0),
              SurveyOption(id: '9', text: 'Teknik Servis', votes: 5, percentage: 10.0),
            ],
          ),
          SurveyQuestion(
            id: '3',
            question: 'Eklemek istediğiniz görüş ve önerileriniz nelerdir?',
            type: 'text',
          ),
        ],
      ),
      SurveyModel(
        id: '2',
        title: 'Sosyal Etkinlik Tercihleri',
        description: 'Önümüzdeki aylarda düzenlenecek sosyal etkinlikler için tercihlerinizi öğrenmek istiyoruz.',
        startDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        endDate: DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        createdBy: 'Sosyal Komite',
        isActive: true,
        hasVoted: false,
        questions: [
          SurveyQuestion(
            id: '4',
            question: 'Hangi tür etkinlikler düzenlenmesini istersiniz?',
            type: 'multiple_choice',
            options: [
              SurveyOption(id: '10', text: 'Kahvaltı', votes: 25, percentage: 35.7),
              SurveyOption(id: '11', text: 'Akşam Yemeği', votes: 15, percentage: 21.4),
              SurveyOption(id: '12', text: 'Spor Turnuvaları', votes: 20, percentage: 28.6),
              SurveyOption(id: '13', text: 'Çocuk Etkinlikleri', votes: 10, percentage: 14.3),
            ],
          ),
          SurveyQuestion(
            id: '5',
            question: 'Etkinliklerin hangi sıklıkta düzenlenmesini istersiniz?',
            type: 'single_choice',
            options: [
              SurveyOption(id: '14', text: 'Haftalık', votes: 10, percentage: 20.0),
              SurveyOption(id: '15', text: 'Aylık', votes: 25, percentage: 50.0),
              SurveyOption(id: '16', text: 'Üç Aylık', votes: 10, percentage: 20.0),
              SurveyOption(id: '17', text: 'Özel Günlerde', votes: 5, percentage: 10.0),
            ],
          ),
          SurveyQuestion(
            id: '6',
            question: 'Etkinlikler için ne kadar bütçe ayırmak istersiniz?',
            type: 'single_choice',
            options: [
              SurveyOption(id: '18', text: '0-100 TL', votes: 15, percentage: 30.0),
              SurveyOption(id: '19', text: '100-250 TL', votes: 20, percentage: 40.0),
              SurveyOption(id: '20', text: '250-500 TL', votes: 10, percentage: 20.0),
              SurveyOption(id: '21', text: '500 TL ve üzeri', votes: 5, percentage: 10.0),
            ],
          ),
        ],
      ),
    ];
  }

  // Anket sorusu sil
  Future<bool> deleteQuestion(String surveyId, String questionId) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda soru silme
        print('Test modunda soru siliniyor: surveyId=$surveyId, questionId=$questionId');
        await Future.delayed(const Duration(seconds: 1));
        
        final surveyIndex = _surveys.indexWhere((s) => s.id == surveyId);
        if (surveyIndex == -1) {
          _error = 'Anket bulunamadı';
          _setLoading(false);
          notifyListeners();
          return false;
        }
        
        final survey = _surveys[surveyIndex];
        final questions = [...survey.questions];
        final questionIndex = questions.indexWhere((q) => q.id == questionId);
        
        if (questionIndex == -1) {
          _error = 'Soru bulunamadı';
          _setLoading(false);
          notifyListeners();
          return false;
        }
        
        questions.removeAt(questionIndex);
        
        final updatedSurvey = SurveyModel(
          id: survey.id,
          title: survey.title,
          description: survey.description,
          startDate: survey.startDate,
          endDate: survey.endDate,
          createdBy: survey.createdBy,
          isActive: survey.isActive,
          hasVoted: survey.hasVoted,
          questions: questions,
        );
        
        _surveys[surveyIndex] = updatedSurvey;
        _setLoading(false);
        notifyListeners();
        return true;
      }
      
      // Normal API çağrısı
      final response = await _apiService.delete('${ApiConstants.surveysEndpoint}/$surveyId/questions/$questionId');
      
      if (response['success']) {
        await fetchSurveys();
        return true;
      } else {
        _error = response['message'] ?? 'Soru silinemedi';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Anket sorusu ekle
  Future<bool> addQuestion(String surveyId, Map<String, dynamic> questionData) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda soru ekleme
        print('Test modunda soru ekleniyor: surveyId=$surveyId, data=$questionData');
        await Future.delayed(const Duration(seconds: 1));
        
        final surveyIndex = _surveys.indexWhere((s) => s.id == surveyId);
        if (surveyIndex == -1) {
          _error = 'Anket bulunamadı';
          _setLoading(false);
          notifyListeners();
          return false;
        }
        
        final survey = _surveys[surveyIndex];
        final questions = [...survey.questions];
        
        final uuid = const Uuid();
        final newQuestion = SurveyQuestion(
          id: questionData['id'] ?? uuid.v4(),
          question: questionData['text'] ?? '',
          type: questionData['type'] ?? 'text',
          options: questionData['options'] != null
              ? (questionData['options'] as List).map((optionText) {
                  return SurveyOption(
                    id: const Uuid().v4(),
                    text: optionText,
                    votes: 0,
                    percentage: 0.0,
                  );
                }).toList()
              : [],
        );
        
        questions.add(newQuestion);
        
        final updatedSurvey = SurveyModel(
          id: survey.id,
          title: survey.title,
          description: survey.description,
          startDate: survey.startDate,
          endDate: survey.endDate,
          createdBy: survey.createdBy,
          isActive: survey.isActive,
          hasVoted: survey.hasVoted,
          questions: questions,
        );
        
        _surveys[surveyIndex] = updatedSurvey;
        _setLoading(false);
        notifyListeners();
        return true;
      }
      
      // Normal API çağrısı
      final response = await _apiService.post('${ApiConstants.surveysEndpoint}/$surveyId/questions', questionData);
      
      if (response['success']) {
        await fetchSurveys();
        return true;
      } else {
        _error = response['message'] ?? 'Soru eklenemedi';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Anket güncelle
  Future<bool> updateSurvey(String surveyId, Map<String, dynamic> surveyData) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda anket güncelleme
        print('Test modunda anket güncelleniyor: id=$surveyId, data=$surveyData');
        await Future.delayed(const Duration(seconds: 1));
        
        final surveyIndex = _surveys.indexWhere((s) => s.id == surveyId);
        if (surveyIndex == -1) {
          _error = 'Anket bulunamadı';
          _setLoading(false);
          notifyListeners();
          return false;
        }
        
        final existingSurvey = _surveys[surveyIndex];
        
        final updatedSurvey = SurveyModel(
          id: surveyId,
          title: surveyData['title'] ?? existingSurvey.title,
          description: surveyData['description'] ?? existingSurvey.description,
          startDate: surveyData['startDate'] ?? existingSurvey.startDate,
          endDate: surveyData['endDate'] ?? existingSurvey.endDate,
          createdBy: existingSurvey.createdBy,
          isActive: surveyData['isActive'] ?? existingSurvey.isActive,
          hasVoted: existingSurvey.hasVoted,
          questions: existingSurvey.questions,
        );
        
        _surveys[surveyIndex] = updatedSurvey;
        _setLoading(false);
        notifyListeners();
        return true;
      }
      
      // Normal API çağrısı
      final response = await _apiService.put('${ApiConstants.surveysEndpoint}/$surveyId', surveyData);
      
      if (response['success']) {
        await fetchSurveys();
        return true;
      } else {
        _error = response['message'] ?? 'Anket güncellenemedi';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Anket sil
  Future<bool> deleteSurvey(String id) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda anket silme
        print('Test modunda anket siliniyor: $id');
        await Future.delayed(const Duration(seconds: 1));
        
        final index = _surveys.indexWhere((s) => s.id == id);
        if (index != -1) {
          _surveys.removeAt(index);
          _setLoading(false);
          notifyListeners();
          return true;
        } else {
          _error = 'Anket bulunamadı';
          _setLoading(false);
          notifyListeners();
          return false;
        }
      }
      
      // Normal API çağrısı
      final response = await _apiService.delete('${ApiConstants.surveysEndpoint}/$id');
      
      if (response['success']) {
        // Anket başarıyla silinmişse, anketleri yeniden yükle yerine 
        // direkt olarak listeyi güncelliyoruz
        final index = _surveys.indexWhere((survey) => survey.id == id);
        if (index != -1) {
          _surveys.removeAt(index);
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Anket silinemedi';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
} 