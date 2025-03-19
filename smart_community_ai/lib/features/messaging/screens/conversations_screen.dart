import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_community_ai/core/models/conversation_model.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/providers/messaging_provider.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/core/widgets/loading_indicator.dart';
import 'package:smart_community_ai/features/messaging/screens/messaging_screen.dart';
import 'package:smart_community_ai/features/messaging/screens/new_message_screen.dart';
import 'package:smart_community_ai/features/messaging/widgets/conversation_list_item.dart';

class ConversationsScreen extends StatefulWidget {
  static const String routeName = '/conversations';

  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late MessagingProvider _messagingProvider;
  bool _isLoading = true;
  String? _searchQuery;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _messagingProvider.loadConversations();
      
      if (!mounted) return;
      
      if (!success) {
        String errorMessage = _messagingProvider.error ?? 'Konuşmalar yüklenemedi';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konuşmalar yüklenirken hata oluştu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToMessaging(ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagingScreen(
          contactId: conversation.userId,
          contactName: conversation.userName,
        ),
      ),
    ).then((_) {
      // Konuşma ekranından döndüğünde konuşmaları yenile
      _loadConversations();
    });
  }

  List<ConversationModel> _getFilteredConversations() {
    final conversations = _messagingProvider.conversations;
    
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return conversations;
    }
    
    final query = _searchQuery!.toLowerCase();
    return conversations.where((conversation) {
      return conversation.userName.toLowerCase().contains(query) ||
          conversation.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mesajlar',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Konuşma ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Konuşmalar listesi
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : Consumer<MessagingProvider>(
                    builder: (context, provider, child) {
                      final filteredConversations = _getFilteredConversations();
                      
                      if (filteredConversations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery != null && _searchQuery!.isNotEmpty
                                    ? 'Arama sonucu bulunamadı'
                                    : 'Henüz mesajınız bulunmamaktadır',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredConversations.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final conversation = filteredConversations[index];
                            return ConversationListItem(
                              conversation: conversation,
                              onTap: () => _navigateToMessaging(conversation),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewMessageScreen()),
          ).then((_) {
            // Yeni mesaj ekranından döndüğünde konuşmaları yenile
            _loadConversations();
          });
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 