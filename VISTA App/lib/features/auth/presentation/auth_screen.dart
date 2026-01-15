import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

/// شاشة تسجيل الدخول وإنشاء الحساب
class AuthScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AuthScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _toggleMode() {
    HapticFeedback.lightImpact();
    setState(() => _isLogin = !_isLogin);
  }

  Future<void> _submit() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    
    // محاكاة طلب API
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    widget.onComplete();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                
                // الشعار
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // العنوان
                Text(
                  _isLogin ? AppConstants.login : AppConstants.register,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _isLogin
                      ? 'أدخل بياناتك للمتابعة'
                      : 'أنشئ حسابك الجديد',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // حقل البريد الإلكتروني
                _buildTextField(
                  controller: _emailController,
                  label: AppConstants.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),
                
                const SizedBox(height: 16),
                
                // حقل كلمة المرور
                _buildTextField(
                  controller: _passwordController,
                  label: AppConstants.password,
                  icon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                
                // حقل تأكيد كلمة المرور (للتسجيل فقط)
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: AppConstants.confirmPassword,
                    icon: Icons.lock_outlined,
                    obscureText: true,
                    isDark: isDark,
                  ),
                ],
                
                // نسيت كلمة المرور
                if (_isLogin) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // TODO: تنفيذ استعادة كلمة المرور
                      },
                      child: Text(
                        AppConstants.forgotPassword,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // زر الإرسال
                AppButton(
                  text: _isLogin ? AppConstants.login : AppConstants.register,
                  onPressed: _submit,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  size: AppButtonSize.large,
                ),
                
                const SizedBox(height: 24),
                
                // الفاصل
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppConstants.orContinueWith,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // أزرار التسجيل الاجتماعي
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onPressed: () {},
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.apple,
                        label: 'Apple',
                        onPressed: () {},
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // التبديل بين تسجيل الدخول والتسجيل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isLogin ? AppConstants.register : AppConstants.login,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _isLogin ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 24,
                color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
