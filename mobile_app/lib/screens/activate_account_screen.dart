import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ActivateAccountScreen extends StatefulWidget {
  final String email;

  const ActivateAccountScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _activateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.activeAccount(
      widget.email,
      _keyController.text.trim(),
    );

    if (success) {
      // Hiển thị thông báo thành công
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.green.shade600,
              size: 32,
            ),
          ),
          title: const Text(
            'Kích hoạt thành công!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'Tài khoản của bạn đã được kích hoạt thành công. Bạn có thể đăng nhập ngay bây giờ.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đăng nhập ngay',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Icon
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Kích hoạt tài khoản',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Chúng tôi đã gửi mã kích hoạt đến email\n',
                      ),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const TextSpan(
                        text: '\nVui lòng kiểm tra email và nhập mã kích hoạt bên dưới.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Activation Key Field
                TextFormField(
                  controller: _keyController,
                  decoration: InputDecoration(
                    labelText: 'Mã kích hoạt',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    hintText: 'Nhập mã kích hoạt từ email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã kích hoạt';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Error Message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Activate Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _activateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'KÍCH HOẠT TÀI KHOẢN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Resend Email Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Không nhận được email?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kiểm tra thư mục spam hoặc liên hệ với chúng tôi để được hỗ trợ.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  child: const Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}