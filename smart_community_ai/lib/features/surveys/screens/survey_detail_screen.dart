import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/survey_provider.dart';
import 'package:smart_community_ai/core/models/survey_model.dart';

class SurveyDetailScreen extends StatefulWidget {
  final String surveyId;

  const SurveyDetailScreen({
    super.key,
    required this.surveyId,
  });

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> {
  SurveyModel? _survey;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  void _loadSurvey() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Provider'dan anketleri al
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final surveys = surveyProvider.surveys;
      
      // ID'ye göre anketi bul
      final survey = surveys.firstWhere(
        (s) => s.id == widget.surveyId,
        orElse: () => throw Exception('Anket bulunamadı'),
      );
      
      setState(() {
        _survey = survey;
        _isLoading = false;
      });
      
      // Eğer kullanıcı daha önce ankete katıldıysa, cevapları doldur
      if (survey.hasVoted) {
        _loadUserAnswers(survey);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Anket yüklenirken bir hata oluştu: $e';
      });
    }
  }
  
  void _loadUserAnswers(SurveyModel survey) {
    // Kullanıcının önceki cevaplarını yükle
    for (final question in survey.questions) {
      if (question.type == 'text' && question.userAnswer != null) {
        _answers[question.id] = question.userAnswer;
      } else if (question.type == 'multiple_choice' && question.userAnswers != null) {
        _answers[question.id] = question.userAnswers;
      } else if ((question.type == 'single_choice' || question.type == 'rating') && question.userAnswer != null) {
        _answers[question.id] = question.userAnswer;
      }
    }
  }

  void _submitSurvey() {
    if (_survey == null) return;
    
    // Tüm soruların cevaplanıp cevaplanmadığını kontrol et
    final questions = _survey!.questions;
    bool allAnswered = true;
    List<String> unansweredQuestions = [];

    for (final question in questions) {
      if (!_answers.containsKey(question.id) || 
          (_answers[question.id] is List && (_answers[question.id] as List).isEmpty)) {
        allAnswered = false;
        unansweredQuestions.add(question.question);
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm soruları cevaplayınız: ${unansweredQuestions.join(", ")}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Provider üzerinden cevapları gönder
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    surveyProvider.submitSurveyResponse(widget.surveyId, _answers).then((success) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anket yanıtlarınız başarıyla gönderildi'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(surveyProvider.error ?? 'Anket yanıtları gönderilirken bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anket Detayı'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _loadSurvey,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : _survey == null
                    ? const Center(child: Text('Anket bulunamadı'))
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSurveyHeader(),
                            SizedBox(height: 24.h),
                            _buildQuestions(),
                            SizedBox(height: 24.h),
                            _buildSubmitButton(),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildSurveyHeader() {
    if (_survey == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _survey!.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          _survey!.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Oluşturan: ${_survey!.createdBy}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Bitiş: ${_formatDate(_survey!.endDate)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (_survey!.hasVoted)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                'Bu ankete daha önce katıldınız. Cevaplarınızı güncelleyebilirsiniz.',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestions() {
    if (_survey == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sorular',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16.h),
        ...List.generate(_survey!.questions.length, (index) {
          final question = _survey!.questions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${question.question}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 12.h),
                _buildQuestionWidget(question),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionWidget(SurveyQuestion question) {
    switch (question.type) {
      case 'single_choice':
        return _buildSingleChoiceQuestion(question);
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(question);
      case 'text':
        return _buildTextQuestion(question);
      case 'rating':
        return _buildRatingQuestion(question);
      default:
        return Text('Desteklenmeyen soru tipi: ${question.type}');
    }
  }

  Widget _buildSingleChoiceQuestion(SurveyQuestion question) {
    if (question.options == null || question.options!.isEmpty) {
      return Text('Bu soru için seçenekler bulunamadı');
    }
    
    return Column(
      children: question.options!.map((option) {
        return RadioListTile<String>(
          title: Text(option.text),
          value: option.id,
          groupValue: _answers[question.id] as String?,
          onChanged: (value) {
            setState(() {
              _answers[question.id] = value;
            });
          },
          subtitle: _survey!.hasVoted && option.votes > 0
              ? LinearProgressIndicator(
                  value: option.percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              : null,
          secondary: _survey!.hasVoted
              ? Text('${option.votes} oy (${option.percentage.toStringAsFixed(1)}%)')
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceQuestion(SurveyQuestion question) {
    if (question.options == null || question.options!.isEmpty) {
      return Text('Bu soru için seçenekler bulunamadı');
    }
    
    if (!_answers.containsKey(question.id)) {
      _answers[question.id] = <String>[];
    }
    
    return Column(
      children: question.options!.map((option) {
        return CheckboxListTile(
          title: Text(option.text),
          value: (_answers[question.id] as List<String>?)?.contains(option.id) ?? false,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                (_answers[question.id] as List<String>? ?? []).add(option.id);
              } else {
                (_answers[question.id] as List<String>?)?.remove(option.id);
              }
            });
          },
          subtitle: _survey!.hasVoted && option.votes > 0
              ? LinearProgressIndicator(
                  value: option.percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              : null,
          secondary: _survey!.hasVoted
              ? Text('${option.votes} oy (${option.percentage.toStringAsFixed(1)}%)')
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildTextQuestion(SurveyQuestion question) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cevabınızı buraya yazın',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: 3,
      controller: TextEditingController(text: _answers[question.id] as String?),
      onChanged: (value) {
        _answers[question.id] = value;
      },
    );
  }

  Widget _buildRatingQuestion(SurveyQuestion question) {
    final currentRating = _answers[question.id] != null 
        ? int.tryParse(_answers[question.id].toString()) ?? 0 
        : 0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: index < currentRating ? Colors.amber : Colors.grey,
                size: 36,
              ),
              onPressed: () {
                setState(() {
                  _answers[question.id] = (index + 1).toString();
                });
              },
            );
          }),
        ),
        Text(
          currentRating > 0 ? '$currentRating / 5' : 'Puanlamak için yıldızlara tıklayın',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting || _survey?.hasVoted == true ? null : _submitSurvey,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          backgroundColor: _survey?.hasVoted == true ? Colors.grey : null,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator()
            : Text(_survey?.hasVoted == true ? 'Zaten Katıldınız' : 'Anketi Gönder'),
      ),
    );
  }
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
} 