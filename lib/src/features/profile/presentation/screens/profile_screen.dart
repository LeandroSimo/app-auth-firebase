import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../data/services/user_profile_service.dart';
import '../../data/domain/entities/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  String? _error;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Se for um mock user, usa o ID do usuário atual logado
      String actualUserId = widget.userId;
      final currentUser = FirebaseAuth.instance.currentUser;

      if (widget.userId.startsWith('user_')) {
        if (currentUser != null) {
          actualUserId = currentUser.uid;
        }
      }

      // Verifica se é o perfil do usuário atual
      _isCurrentUser = currentUser != null && actualUserId == currentUser.uid;

      final profile = await _profileService.getUserProfile(actualUserId);

      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userProfile = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _userProfile != null
          ? _buildProfileWidget()
          : _buildNotFoundWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.mediaQuery.width * 0.16,
              color: Colors.red[300],
            ),
            SizedBox(height: context.mediaQuery.height * 0.02),
            Text(
              'Erro ao carregar perfil',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.mediaQuery.height * 0.01),
            Text(
              _error!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.mediaQuery.height * 0.03),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: context.mediaQuery.width * 0.16,
              color: Colors.grey[400],
            ),
            SizedBox(height: context.mediaQuery.height * 0.02),
            Text(
              'Perfil não encontrado',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.mediaQuery.height * 0.01),
            Text(
              'Os dados do perfil não foram encontrados no servidor.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.mediaQuery.height * 0.03),
            ElevatedButton.icon(
              onPressed: _createDefaultProfile,
              icon: const Icon(Icons.add),
              label: const Text('Criar Perfil'),
            ),
            SizedBox(height: context.mediaQuery.height * 0.02),
            TextButton(
              onPressed: _loadUserProfile,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDefaultProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final defaultProfile = UserProfile(
          id: currentUser.uid,
          name: currentUser.displayName ?? 'Usuário',
          email: currentUser.email ?? '',
          photoURL: currentUser.photoURL,
          postsCount: 5,
          age: 23,
          interests: [
            'Tecnologia',
            'Esportes',
            'Música',
            'Viagens',
            'Religião',
          ],
        );

        await _profileService.updateUserProfile(defaultProfile);

        // Recarrega o perfil
        await _loadUserProfile();
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao criar perfil: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileWidget() {
    final profile = _userProfile!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header com foto e informações básicas
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withAlpha((0.8 * 255).round()),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(context.mediaQuery.width * 0.06),
                child: Column(
                  children: [
                    // Foto do perfil
                    GestureDetector(
                      onTap: _isCurrentUser
                          ? () => _showPhotoOptions(context)
                          : null,
                      child: Stack(
                        children: [
                          Container(
                            width: context.mediaQuery.width * 0.3,
                            height: context.mediaQuery.width * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: context.mediaQuery.width * 0.01,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: context.mediaQuery.width * 0.02,
                                  offset: Offset(
                                    0,
                                    context.mediaQuery.width * 0.01,
                                  ),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child:
                                  profile.photoURL != null &&
                                      profile.photoURL!.isNotEmpty
                                  ? Image.network(
                                      profile.photoURL!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return _buildDefaultAvatar();
                                          },
                                    )
                                  : _buildDefaultAvatar(),
                            ),
                          ),
                          if (_isCurrentUser)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showPhotoOptions(context),
                                child: Container(
                                  width: context.mediaQuery.width * 0.08,
                                  height: context.mediaQuery.width * 0.08,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: context.mediaQuery.width * 0.04,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          if (_isUploadingPhoto)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.02),

                    // Nome do usuário
                    Text(
                      profile.name.isNotEmpty ? profile.name : 'Usuário',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.01),

                    // Email
                    if (profile.email.isNotEmpty)
                      Text(
                        profile.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Estatísticas
          Container(
            margin: EdgeInsets.all(context.mediaQuery.width * 0.04),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.article_outlined,
                    value: profile.postsCount.toString(),
                    label: 'Posts',
                  ),
                ),
                SizedBox(width: context.mediaQuery.width * 0.04),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.cake_outlined,
                    value: '${profile.age} anos',
                    label: 'Idade',
                  ),
                ),
              ],
            ),
          ),

          // Interesses/Gostos
          if (profile.interests.isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: context.mediaQuery.width * 0.04,
              ),
              padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  context.mediaQuery.width * 0.03,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_outlined,
                        color: Theme.of(context).primaryColor,
                        size: context.mediaQuery.width * 0.06,
                      ),
                      SizedBox(width: context.mediaQuery.width * 0.02),
                      Text(
                        'Interesses',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: context.mediaQuery.height * 0.02),
                  Wrap(
                    spacing: context.mediaQuery.width * 0.02,
                    runSpacing: context.mediaQuery.width * 0.02,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.mediaQuery.width * 0.03,
                          vertical: context.mediaQuery.height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(
                            context.mediaQuery.width * 0.05,
                          ),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withAlpha((0.3 * 255).round()),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          interest,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          SizedBox(height: context.mediaQuery.height * 0.04),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.mediaQuery.width * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: context.mediaQuery.width * 0.08,
          ),
          SizedBox(height: context.mediaQuery.height * 0.01),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Icon(
        Icons.person,
        size: context.mediaQuery.width * 0.15,
        color: Colors.white.withAlpha((0.8 * 255).round()),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.mediaQuery.width * 0.05),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(context.mediaQuery.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.mediaQuery.width * 0.1,
                height: context.mediaQuery.height * 0.005,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(
                    context.mediaQuery.width * 0.005,
                  ),
                ),
              ),
              SizedBox(height: context.mediaQuery.height * 0.025),
              Text(
                'Foto do Perfil',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.mediaQuery.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    isLoading: _isUploadingPhoto,
                    onTap: _isUploadingPhoto
                        ? null
                        : () {
                            Navigator.pop(context);
                            _takePhoto();
                          },
                  ),
                  _buildPhotoOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    isLoading: _isUploadingPhoto,
                    onTap: _isUploadingPhoto
                        ? null
                        : () {
                            Navigator.pop(context);
                            _pickFromGallery();
                          },
                  ),
                  _buildPhotoOption(
                    context,
                    icon: Icons.delete,
                    label: 'Remover',
                    isLoading: _isUploadingPhoto,
                    onTap: _isUploadingPhoto
                        ? null
                        : () {
                            Navigator.pop(context);
                            _removePhoto();
                          },
                  ),
                ],
              ),
              SizedBox(height: context.mediaQuery.height * 0.025),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Column(
          children: [
            Container(
              width: context.mediaQuery.width * 0.15,
              height: context.mediaQuery.width * 0.15,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  context.mediaQuery.width * 0.075,
                ),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: context.mediaQuery.width * 0.075,
                        height: context.mediaQuery.width * 0.075,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: context.mediaQuery.width * 0.075,
                    ),
            ),
            SizedBox(height: context.mediaQuery.height * 0.01),
            Text(
              isLoading ? 'Processando...' : label,
              style: TextStyle(
                fontSize: context.mediaQuery.width * 0.03,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _takePhoto() async {
    if (_isUploadingPhoto) return;

    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      final imageFile = await _imagePickerService.pickImageFromCamera();
      if (imageFile != null) {
        await _uploadProfilePhoto(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _pickFromGallery() async {
    if (_isUploadingPhoto) return;

    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      final imageFile = await _imagePickerService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadProfilePhoto(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _uploadProfilePhoto(File imageFile) async {
    try {
      final authCubit = context.read<AuthCubit>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final isStorageConnected = await _storageService.checkStorageConnection();
      if (!isStorageConnected) {
        throw Exception('Firebase Storage não está configurado corretamente');
      }

      final photoURL = await _storageService.uploadProfilePhoto(imageFile);

      if (mounted) {
        await authCubit.updateUserPhotoURL(photoURL);

        setState(() {
          _userProfile = _userProfile!.copyWith(photoURL: photoURL);
        });

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Foto do perfil atualizada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto do perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePhoto() async {
    if (_isUploadingPhoto) return;

    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      final authCubit = context.read<AuthCubit>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      if (mounted) {
        await authCubit.updateUserPhotoURL('');

        setState(() {
          _userProfile = _userProfile!.copyWith(photoURL: '');
        });

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Foto do perfil removida com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto do perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }
}
