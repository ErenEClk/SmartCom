import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/survey_provider.dart';
import 'package:smart_community_ai/core/models/survey_model.dart';
import 'package:smart_community_ai/features/surveys/screens/survey_detail_screen.dart';

class SurveysScreen extends StatefulWidget {
  const SurveysScreen({super.key});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final success = await surveyProvider.fetchSurveys();
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(surveyProvider.error ?? 'Anketler yüklenirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anketler yüklenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anketler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif Anketler'),
            Tab(text: 'Geçmiş Anketler'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSurveys,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<SurveyProvider>(
              builder: (context, surveyProvider, child) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveSurveys(surveyProvider.surveys),
                    _buildPastSurveys(surveyProvider.surveys),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildActiveSurveys(List<SurveyModel> allSurveys) {
    final activeSurveys = allSurveys.where((survey) => survey.isActive).toList();
    return _buildSurveyList(activeSurveys, true);
  }

  Widget _buildPastSurveys(List<SurveyModel> allSurveys) {
    final pastSurveys = allSurveys.where((survey) => !survey.isActive).toList();
    return _buildSurveyList(pastSurveys, false);
  }

  Widget _buildSurveyList(List<SurveyModel> surveys, bool isActive) {
    return surveys.isEmpty
        ? Center(
            child: Text(
              isActive ? 'Aktif anket bulunmamaktadır.' : 'Geçmiş anket bulunmamaktadır.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadSurveys,
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: surveys.length,
              itemBuilder: (context, index) {
                final survey = surveys[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurveyDetailScreen(surveyId: survey.id),
                        ),
                      ).then((_) => _loadSurveys()); // Geri dönüldüğünde anketleri yenile
                    },
                    borderRadius: BorderRadius.circular(12),
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (survey.hasVoted)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Katıldınız',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            survey.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Oluşturan: ${survey.createdBy}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Bitiş: ${_formatDate(survey.endDate)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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