import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/messaging_provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/models/message_model.dart';
import 'package:smart_community_ai/core/widgets/custom_drawer.dart';
import 'package:smart_community_ai/core/widgets/loading_indicator.dart';

class AdminMessagingScreen extends StatefulWidget {
  static const String routeName = '/admin-messaging';
  
  const AdminMessagingScreen({super.key});

  @override
  State<AdminMessagingScreen> createState() => _AdminMessagingScreenState();
}

class _AdminMessagingScreenState extends State<AdminMessagingScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;
  bool _showChatArea = false;
  String _selectedUserName = '';
  String _selectedUserId = '';
  List<UserModel> _users = [];
  bool _isLoadingUsers = false;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadMessages();
    _loadUsers();
  }

  Future<void> _loadMessages() async {
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    if (_selectedUserId.isNotEmpty) {
      // Önce konuşmayı oluştur veya getir
      final conversation = await messagingProvider.getOrCreateConversation(_selectedUserId);
      // Sonra mesajları yükle
      if (conversation != null) {
        await messagingProvider.loadMessages(conversation.id);
      } else {
        // Konuşma oluşturulamadıysa hata mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konuşma başlatılamadı')),
          );
        }
      }
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      // Gerçek uygulamada kullanıcıları API'den yükleyebilirsiniz
      // Şimdilik test verileri kullanıyoruz
      _users = authProvider.isTestMode ? _getTestUsers() : await authProvider.getUsers();
    } catch (e) {
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

  List<UserModel> _getTestUsers() {
    return [
      UserModel(
        id: 'user1',
        name: 'Test Kullanıcı',
        email: 'test@example.com',
        role: 'user',
        createdAt: '2023-01-01T00:00:00.000Z',
        updatedAt: '2023-01-01T00:00:00.000Z',
      ),
      UserModel(
        id: 'user2',
        name: 'Ahmet Yılmaz',
        email: 'ahmet@example.com',
        role: 'user',
        createdAt: '2023-01-02T00:00:00.000Z',
        updatedAt: '2023-01-02T00:00:00.000Z',
      ),
      UserModel(
        id: 'user3',
        name: 'Ayşe Demir',
        email: 'ayse@example.com',
        role: 'user',
        createdAt: '2023-01-03T00:00:00.000Z',
        updatedAt: '2023-01-03T00:00:00.000Z',
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _selectedUserId.isEmpty) return;
    
    _messageController.clear();
    
    setState(() {
      _isSending = true;
    });
    
    try {
      // Mesajı gönder
      final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
      await messagingProvider.sendMessage(_selectedUserId, message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj gönderilirken hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _selectUser(UserModel user) {
    setState(() {
      _selectedUserName = user.name;
      _selectedUserId = user.id;
      _showChatArea = true;
    });
  }

  void _showNewMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Mesaj'),
        content: _isLoadingUsers
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () {
                        Navigator.pop(context);
                        _selectUser(user);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessagingProvider>(
      builder: (context, messagingProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: _showChatArea ? _selectedUserName : 'Mesaj Yönetimi',
            showBackButton: _showChatArea,
            onBackPressed: _showChatArea ? () {
              setState(() {
                _showChatArea = false;
                _selectedUserName = '';
              });
            } : null,
            actions: [
              if (!_showChatArea)
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Yeni Mesaj',
                  onPressed: _showNewMessageDialog,
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMessages,
              ),
            ],
          ),
          body: SafeArea(
            child: _showChatArea ? _buildChatArea() : _buildUserList(),
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    // Aktif konuşmaları olan kullanıcıları göster
    return _isLoadingUsers
        ? const Center(child: CircularProgressIndicator())
        : _users.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Henüz mesajlaşma bulunmuyor',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: _showNewMessageDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Yeni Mesaj'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user.name.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      'Son mesaj...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bugün',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _selectUser(user),
                  );
                },
              );
  }

  Widget _buildChatArea() {
    final messagingProvider = Provider.of<MessagingProvider>(context);
    final messages = messagingProvider.messages;
    
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Henüz mesaj bulunmuyor'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isAdmin = message.senderId == authProvider.currentUser?.id;
                    
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Mesaj gönderme alanı
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Mesaj yazın...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isSending
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 