import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../../core/constants/theme_constants.dart';
import '../../core/routes/app_routes_path.dart';
import '../../core/utils/utils.dart';
import '../../core/constants/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/preferences_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a premium network request delay
      await Future.delayed(const Duration(milliseconds: 1200));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show a premium toast notification using localized strings
        AppUtils.showSnackBar(
          context: context,
          title: AppStrings.current.loginSuccessfulTitle,
          extraMessage: AppStrings.current.loginSuccessfulMessage,
          toastificationType: ToastificationType.success,
        );

        final preferences = context.read<PreferencesService>();
        // Save login state if remember me is checked
        await preferences.setLoggedIn(_rememberMe);

        if (mounted) {
          // Redirect to dashboard page
          context.go(AppRoutesPath.dashboard);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isWideScreen = size.width > 800;
    final strings = AppStrings.current;

    return Scaffold(
      backgroundColor: context.colors.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 1000 : 450,
              maxHeight: isWideScreen ? 600 : double.infinity,
            ),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.whiteColor,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              child: Row(
                children: [
                  if (isWideScreen)
                    Expanded(
                      flex: 11,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colors.primaryLightColor,
                              context.colors.lightBlueColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -100,
                              right: -100,
                              child: Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -50,
                              left: -50,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/app_logo_transparent.png',
                                      width: 48,
                                      height: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    strings.appName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 13,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen ? 50.0 : 24.0,
                        vertical: 40.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isWideScreen) ...[
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryLightColor
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/icons/app_logo_transparent.png',
                                    width: 48,
                                    height: 48,
                                    color: context.colors.primaryLightColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: Text(
                                  strings.appName,
                                  style: TextStyle(
                                    color: context.colors.primaryLightColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                            ],
                            SpacedText(
                              text: strings.loginHeaderTitle,
                              letterSpacing: 1.5,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            // Email/Username Input
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _passwordFocusNode.requestFocus(),
                              style: TextStyle(
                                  color:
                                      isDark ? Colors.white : Colors.black87),
                              decoration: InputDecoration(
                                labelText: strings.loginUsernameLabel,
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  CupertinoIcons.at,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[500],
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: context.colors.milkyColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      ThemeConstants.buttonRadius),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      ThemeConstants.buttonRadius),
                                  borderSide: BorderSide(
                                    color: context.colors.primaryLightColor,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return strings.loginUsernameError;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            // Password Input
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  _isLoading ? null : _handleLogin(),
                              style: TextStyle(
                                  color:
                                      isDark ? Colors.white : Colors.black87),
                              decoration: InputDecoration(
                                labelText: strings.loginPasswordLabel,
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  CupertinoIcons.lock,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[500],
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[500],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: context.colors.milkyColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      ThemeConstants.buttonRadius),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      ThemeConstants.buttonRadius),
                                  borderSide: BorderSide(
                                    color: context.colors.primaryLightColor,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return strings.loginPasswordRequiredError;
                                }
                                if (value.length < 6) {
                                  return strings.loginPasswordLengthError;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            // Remember me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor:
                                            context.colors.primaryLightColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      strings.loginRememberMe,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    AppUtils.showSnackBar(
                                      context: context,
                                      title: strings.loginRecoverPasswordTitle,
                                      extraMessage:
                                          strings.loginRecoverPasswordMessage,
                                      toastificationType:
                                          ToastificationType.info,
                                    );
                                  },
                                  child: Text(
                                    strings.loginForgotPassword,
                                    style: TextStyle(
                                      color: context.colors.primaryLightColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      context.colors.primaryLightColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        ThemeConstants.buttonRadius),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        strings.loginButtonLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
