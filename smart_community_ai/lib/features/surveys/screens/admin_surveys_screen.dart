import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/survey_model.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/providers/survey_provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/core/widgets/loading_indicator.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class AdminSurveysScreen extends StatefulWidget {
  static const String routeName = '/admin-surveys';

  const AdminSurveysScreen({Key? key}) : super(key: key);

  @override
  State<AdminSurveysScreen> createState() => _AdminSurveysScreenState();
}

class _AdminSurveysScreenState extends State<AdminSurveysScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModel> _users = [];
  bool _isLoadingUsers = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadSurveys();
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSurveys() async {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    await surveyProvider.fetchSurveys();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _users = authProvider.isTestMode ? _getTestUsers() : await authProvider.getUsers();
    } catch (e) {
      print('Kullanıcılar yüklenirken hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcılar yüklenirken hata oluştu: $e')),
      );
      _users = _getTestUsers(); // Hata durumunda test verilerini kullan
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  // Test için örnek kullanıcılar
  List<UserModel> _getTestUsers() {
    return [
      UserModel(
        id: 'user1',
        name: 'Test Kullanıcı 1',
        email: 'user1@example.com',
        role: 'user',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      UserModel(
        id: 'user2',
        name: 'Test Kullanıcı 2',
        email: 'user2@example.com',
        role: 'user',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurveyProvider>(
      builder: (context, surveyProvider, child) {
        final surveys = surveyProvider.surveys;
        final filteredSurveys = surveys
            .where((survey) =>
                survey.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                survey.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // Arama ve filtre
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Anket ara...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadSurveys,
                        tooltip: 'Yenile',
                      ),
                    ],
                  ),
                ),

                // Anket listesi
                Expanded(
                  child: surveyProvider.isLoading
                      ? const Center(child: LoadingIndicator())
                      : filteredSurveys.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.poll_outlined,
                                    size: 64.sp,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Henüz anket bulunmuyor',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  ElevatedButton.icon(
                                    onPressed: _showAddSurveyDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Yeni Anket'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: filteredSurveys.length,
                              itemBuilder: (context, index) {
                                final survey = filteredSurveys[index];
                                return _buildSurveyItem(survey);
                              },
                            ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _showAddSurveyDialog,
              child: const Icon(Icons.add),
              tooltip: 'Anket Ekle',
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurveyItem(SurveyModel survey) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    survey.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (survey.isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Pasif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              survey.description,
              style: TextStyle(fontSize: 14.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  'Başlangıç: ${_formatDate(survey.startDate)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.event, size: 16.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  'Bitiş: ${_formatDate(survey.endDate)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soru Sayısı: ${survey.questions.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8.w),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditSurveyDialog(survey),
                      tooltip: 'Düzenle',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmationDialog(survey),
                      tooltip: 'Sil',
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.green),
                      onPressed: () => _showSurveyDetailsDialog(survey),
                      tooltip: 'Detaylar',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddSurveyDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final startDateController = TextEditingController(
      text: DateTime.now().toIso8601String().substring(0, 10),
    );
    final endDateController = TextEditingController(
      text: DateTime.now().add(const Duration(days: 7)).toIso8601String().substring(0, 10),
    );
    bool isActive = true;
    List<Map<String, dynamic>> questions = [];
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Yeni Anket Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: startDateController,
                          decoration: const InputDecoration(
                            labelText: 'Başlangıç Tarihi',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                startDateController.text = date.toIso8601String().substring(0, 10);
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: TextFormField(
                          controller: endDateController,
                          decoration: const InputDecoration(
                            labelText: 'Bitiş Tarihi',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                endDateController.text = date.toIso8601String().substring(0, 10);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value!;
                          });
                        },
                      ),
                      const Text('Aktif'),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Sorular Bölümü
                  Text(
                    'Sorular (${questions.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  
                  // Soru Listesi
                  if (questions.isNotEmpty)
                    Container(
                      height: 200.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return ListTile(
                            title: Text(question['text'] ?? ''),
                            subtitle: Text('Tip: ${question['type']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  questions.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => _showAddQuestionDialog(
                      context,
                      (question) {
                        setState(() {
                          questions.add(question);
                        });
                      },
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Soru Ekle'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              Consumer<SurveyProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Ekle',
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      if (titleController.text.isEmpty || 
                          descriptionController.text.isEmpty || 
                          questions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen tüm alanları doldurun ve en az bir soru ekleyin'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final surveyData = {
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'startDate': startDateController.text,
                        'endDate': endDateController.text,
                        'isActive': isActive,
                        'questions': questions,
                      };

                      final success = await provider.createSurvey(surveyData);

                      if (!mounted) return;

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Anket başarıyla eklendi'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error ?? 'Anket eklenemedi'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddQuestionDialog(
      BuildContext context, Function(Map<String, dynamic>) onAdd) async {
    final questionController = TextEditingController();
    String questionType = 'text'; // text, single_choice, multiple_choice
    List<String> options = [];
    
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Soru Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      labelText: 'Soru Metni',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.h),
                  const Text('Soru Tipi:'),
                  DropdownButton<String>(
                    value: questionType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'text',
                        child: Text('Metin Kutusu'),
                      ),
                      DropdownMenuItem(
                        value: 'single_choice',
                        child: Text('Tekli Seçim'),
                      ),
                      DropdownMenuItem(
                        value: 'multiple_choice',
                        child: Text('Çoklu Seçim'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        questionType = value!;
                      });
                    },
                  ),
                  
                  // Seçenekler (çoklu veya tekli seçim için)
                  if (questionType == 'single_choice' || questionType == 'multiple_choice') ...[
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Seçenekler (${options.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _showAddOptionDialog(context, (option) {
                              setState(() {
                                options.add(option);
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    if (options.isNotEmpty)
                      Container(
                        height: 150.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ListView.builder(
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(options[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    options.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (questionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen soru metnini girin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if ((questionType == 'single_choice' || questionType == 'multiple_choice') && 
                      options.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen en az bir seçenek ekleyin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  final uuid = const Uuid();
                  final question = {
                    'id': uuid.v4(),
                    'text': questionController.text.trim(),
                    'type': questionType,
                    'options': options,
                  };
                  
                  onAdd(question);
                  Navigator.pop(context);
                },
                child: const Text('Ekle'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddOptionDialog(
      BuildContext context, Function(String) onAdd) async {
    final optionController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seçenek Ekle'),
        content: TextField(
          controller: optionController,
          decoration: const InputDecoration(
            labelText: 'Seçenek Metni',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (optionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen seçenek metnini girin'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              onAdd(optionController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSurveyDialog(SurveyModel survey) async {
    // Düzenleme mantığını geliştirebilirsiniz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anket düzenleme özelliği henüz geliştirilmemiştir'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(SurveyModel survey) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anketi Sil'),
        content: Text('${survey.title} anketini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteSurvey(survey);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSurveyDetailsDialog(SurveyModel survey) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(survey.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                survey.description,
                style: const TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16.h),
              Text(
                'Başlangıç: ${_formatDate(survey.startDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Bitiş: ${_formatDate(survey.endDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Text(
                'Durum: ${survey.isActive ? 'Aktif' : 'Pasif'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: survey.isActive ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 24.h),
              const Text(
                'Sorular:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8.h),
              ...List.generate(
                survey.questions.length,
                (index) => _buildQuestionDetails(index + 1, survey.questions[index]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionDetails(int index, SurveyQuestion question) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ${question.question}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Tip: ${_getQuestionTypeLabel(question.type)}'),
          if (question.options != null && question.options!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            const Text('Seçenekler:', style: TextStyle(fontStyle: FontStyle.italic)),
            ...List.generate(
              question.options!.length,
              (i) => Padding(
                padding: EdgeInsets.only(left: 16.w, top: 4.h),
                child: Row(
                  children: [
                    Text('${i + 1}. ${question.options![i].text}'),
                    if (question.options![i].votes > 0) ...[
                      const Spacer(),
                      Text(
                        '${question.options![i].votes} oy (${question.options![i].percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Metin Kutusu';
      case 'single_choice':
        return 'Tekli Seçim';
      case 'multiple_choice':
        return 'Çoklu Seçim';
      default:
        return type;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _deleteSurvey(SurveyModel survey) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final success = await surveyProvider.deleteSurvey(survey.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Anket başarıyla silindi' 
                : 'Anket silinemedi: ${surveyProvider.error}',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anket silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 