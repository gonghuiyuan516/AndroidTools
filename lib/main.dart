import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

void main() {
  runApp(const AndroidToolsApp());
}

class AndroidToolsApp extends StatelessWidget {
  const AndroidToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = TDThemeData.defaultData();

    return TDTheme(
      data: themeData,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AndroidTools',
        theme: themeData.systemThemeDataLight,
        home: const ApkSignerPage(),
      ),
    );
  }
}

enum SignatureScheme {
  v1('V1 (JAR Signature)'),
  v2('V2 (APK Signature Scheme v2, 包含 V1)'),
  v3('V3 (APK Signature Scheme v3, 包含 V1/V2)'),
  v4('V4 (APK Signature Scheme v4, 包含 V1/V2/V3)');

  const SignatureScheme(this.label);

  final String label;

  bool get requiresApkSigner => this != SignatureScheme.v1;
}

enum SignSource {
  configured('使用已配置签名'),
  custom('使用指定文件签名');

  const SignSource(this.label);

  final String label;
}

class ApkSignerPage extends StatefulWidget {
  const ApkSignerPage({super.key});

  @override
  State<ApkSignerPage> createState() => _ApkSignerPageState();
}

class _ApkSignerPageState extends State<ApkSignerPage> {
  final _apkController = TextEditingController();
  final _outputController = TextEditingController();
  final _keystoreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _storePasswordController = TextEditingController();
  final _keyPasswordController = TextEditingController();
  final _logController = TextEditingController();

  SignatureScheme _scheme = SignatureScheme.v2;
  SignSource _signSource = SignSource.custom;
  bool _saveSignature = false;
  bool _isSigning = false;

  @override
  void dispose() {
    _apkController.dispose();
    _outputController.dispose();
    _keystoreController.dispose();
    _aliasController.dispose();
    _storePasswordController.dispose();
    _keyPasswordController.dispose();
    _logController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = TDTheme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: const TDNavBar(
        title: 'Android APK 签名',
        useDefaultBack: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
            children: [
              _buildNotice(theme),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
                decoration: BoxDecoration(
                  color: theme.whiteColor1,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFileRow(
                      label: 'APK文件',
                      controller: _apkController,
                      hintText: '请选择需要签名的 APK 文件',
                      buttonText: '选择 APK',
                      buttonIcon: TDIcons.folder_open,
                      onTap: _pickApkFile,
                    ),
                    const SizedBox(height: 20),
                    _buildFileRow(
                      label: '输出路径',
                      controller: _outputController,
                      hintText: '请选择签名输出目录',
                      buttonText: '选择目录',
                      buttonIcon: TDIcons.folder_export,
                      onTap: _pickOutputDirectory,
                    ),
                    const SizedBox(height: 20),
                    _buildSchemeRow(theme),
                    const SizedBox(height: 28),
                    _buildSourceSelector(theme),
                    const SizedBox(height: 20),
                    if (_signSource == SignSource.configured)
                      _buildConfiguredSignaturePlaceholder(theme)
                    else
                      _buildKeystoreSection(theme),
                    const SizedBox(height: 24),
                    _buildPasswordSection(theme),
                    const SizedBox(height: 24),
                    _buildLogSection(theme),
                    const SizedBox(height: 28),
                    TDButton(
                      text: _isSigning ? '签名中...' : '开始签名',
                      theme: TDButtonTheme.primary,
                      shape: TDButtonShape.round,
                      width: 320,
                      height: 52,
                      onTap: _isSigning ? null : _startSigning,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotice(TDThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.whiteColor1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE1D8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TDText(
              '温馨提示：批量签名、使用已配置签名、保存签名和自动选择签名策略为预留能力。当前页面优先提供单个 APK 的签名流程。',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFFF25543),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE9FFF4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              TDIcons.secured,
              size: 24,
              color: Color(0xFF12B76A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String buttonText,
    required IconData buttonIcon,
    required VoidCallback onTap,
  }) {
    return _buildLabeledRow(
      label: label,
      child: Row(
        children: [
          Expanded(
            child: _buildReadOnlyField(
              controller: controller,
              hintText: hintText,
            ),
          ),
          const SizedBox(width: 12),
          TDButton(
            text: buttonText,
            icon: buttonIcon,
            theme: TDButtonTheme.primary,
            type: TDButtonType.outline,
            width: 126,
            height: 48,
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeRow(TDThemeData theme) {
    return _buildLabeledRow(
      label: '签名策略',
      child: GestureDetector(
        onTap: _showSchemePicker,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.whiteColor1,
            border: Border.all(color: theme.componentStrokeColor),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: TDText(
                  _scheme.label,
                  style: TextStyle(
                    fontSize: theme.fontBodyLarge?.size,
                    color: theme.textColorPrimary,
                  ),
                ),
              ),
              Icon(
                TDIcons.chevron_down,
                size: 20,
                color: theme.textColorSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceSelector(TDThemeData theme) {
    return _buildLabeledRow(
      label: '签名来源',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSourceOption(
            title: SignSource.configured.label,
            selected: _signSource == SignSource.configured,
            enabled: false,
            onTap: () {
              setState(() {
                _signSource = SignSource.configured;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSourceOption(
            title: SignSource.custom.label,
            selected: _signSource == SignSource.custom,
            enabled: true,
            onTap: () {
              setState(() {
                _signSource = SignSource.custom;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TDTag(
                _signSource == SignSource.configured ? '预留功能' : '当前可用',
                theme: _signSource == SignSource.configured
                    ? TDTagTheme.warning
                    : TDTagTheme.success,
                isLight: true,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _signSource == SignSource.custom
                    ? () {
                        setState(() {
                          _saveSignature = !_saveSignature;
                        });
                      }
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _signSource == SignSource.custom
                              ? (_saveSignature
                                  ? theme.brandNormalColor
                                  : const Color(0xFFD0D5DD))
                              : const Color(0xFFD0D5DD),
                          width: 2,
                        ),
                        color: _saveSignature && _signSource == SignSource.custom
                            ? theme.brandNormalColor
                            : Colors.transparent,
                      ),
                      child: _saveSignature
                          ? const Icon(
                              TDIcons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    TDText(
                      '保存签名',
                      style: TextStyle(
                        fontSize: theme.fontBodyMedium?.size,
                        color: _signSource == SignSource.custom
                            ? theme.textColorSecondary
                            : theme.textColorPlaceholder,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required String title,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final theme = TDTheme.of(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled
                    ? (selected ? theme.brandNormalColor : const Color(0xFFD0D5DD))
                    : const Color(0xFFD0D5DD),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: enabled
                            ? theme.brandNormalColor
                            : const Color(0xFFD0D5DD),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          TDText(
            title,
            style: TextStyle(
              fontSize: theme.fontBodyLarge?.size,
              color: enabled
                  ? theme.textColorPrimary
                  : theme.textColorPlaceholder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguredSignaturePlaceholder(TDThemeData theme) {
    return _buildLabeledRow(
      label: '已配置签名',
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TDText(
                '当前版本未接入本地签名配置列表',
                style: TextStyle(
                  fontSize: theme.fontBodyMedium?.size,
                  color: theme.textColorPlaceholder,
                ),
              ),
            ),
            Icon(
              TDIcons.chevron_down,
              size: 20,
              color: theme.textColorPlaceholder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeystoreSection(TDThemeData theme) {
    return Column(
      children: [
        _buildFileRow(
          label: '密钥文件',
          controller: _keystoreController,
          hintText: '请选择 .jks 或 .keystore 文件',
          buttonText: '选择签名',
          buttonIcon: TDIcons.folder_open,
          onTap: _pickKeystoreFile,
        ),
        const SizedBox(height: 20),
        _buildLabeledRow(
          label: '签名别名',
          child: _buildEditableField(
            controller: _aliasController,
            hintText: '请输入 keystore 中的别名',
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(TDThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEEF5)),
      ),
      child: Column(
        children: [
          _buildLabeledRow(
            label: 'Store 密码',
            child: _buildEditableField(
              controller: _storePasswordController,
              hintText: '请输入 keystore 密码',
              obscureText: true,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledRow(
            label: 'Key 密码',
            child: _buildEditableField(
              controller: _keyPasswordController,
              hintText: '可为空，默认与 Store 密码一致',
              obscureText: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogSection(TDThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TDText(
          '签名详情',
          style: TextStyle(
            fontSize: theme.fontTitleMedium?.size,
            fontWeight: FontWeight.w600,
            color: theme.textColorPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TDTextarea(
          controller: _logController,
          readOnly: true,
          minLines: 8,
          maxLines: 8,
          layout: TDTextareaLayout.vertical,
          bordered: true,
          showBottomDivider: false,
          hintText: '签名日志会显示在这里',
          textareaDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledRow({
    required String label,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TDText(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return _buildFieldFrame(
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration.collapsed(hintText: hintText),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return _buildFieldFrame(
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration.collapsed(hintText: hintText),
      ),
    );
  }

  Widget _buildFieldFrame({required Widget child}) {
    final theme = TDTheme.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.componentStrokeColor),
      ),
      alignment: Alignment.centerLeft,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: theme.fontBodyLarge?.size,
          color: theme.textColorPrimary,
        ),
        child: IconTheme(
          data: IconThemeData(color: theme.textColorSecondary),
          child: child,
        ),
      ),
    );
  }

  Future<void> _pickApkFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'APK', extensions: ['apk']),
      ],
    );

    if (file == null) {
      return;
    }

    setState(() {
      _apkController.text = file.path;
      if (_outputController.text.trim().isEmpty) {
        _outputController.text = File(file.path).parent.path;
      }
    });
  }

  Future<void> _pickOutputDirectory() async {
    final path = await getDirectoryPath(confirmButtonText: '选择输出目录');
    if (path == null) {
      return;
    }

    setState(() {
      _outputController.text = path;
    });
  }

  Future<void> _pickKeystoreFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Keystore', extensions: ['jks', 'keystore']),
      ],
    );

    if (file == null) {
      return;
    }

    setState(() {
      _keystoreController.text = file.path;
    });
  }

  Future<void> _showSchemePicker() async {
    TDPicker.showMultiPicker(
      context,
      title: '选择签名策略',
      data: [
        SignatureScheme.values.map((item) => item.label).toList(),
      ],
      initialIndexes: [SignatureScheme.values.indexOf(_scheme)],
      onConfirm: (selectedIndexes) {
        final index = selectedIndexes.first;
        if (index >= 0 && index < SignatureScheme.values.length) {
          setState(() {
            _scheme = SignatureScheme.values[index];
          });
        }
      },
    );
  }

  Future<void> _startSigning() async {
    final apkPath = _apkController.text.trim();
    final outputDir = _outputController.text.trim();
    final keystorePath = _keystoreController.text.trim();
    final alias = _aliasController.text.trim();
    final storePassword = _storePasswordController.text;
    final keyPassword = _keyPasswordController.text.isEmpty
        ? _storePasswordController.text
        : _keyPasswordController.text;

    if (apkPath.isEmpty) {
      _showMessage('请先选择 APK 文件');
      return;
    }
    if (outputDir.isEmpty) {
      _showMessage('请先选择输出目录');
      return;
    }
    if (_signSource != SignSource.custom) {
      _showMessage('当前版本仅支持指定文件签名');
      return;
    }
    if (keystorePath.isEmpty || alias.isEmpty || storePassword.isEmpty) {
      _showMessage('请完整填写 keystore、别名和密码');
      return;
    }

    final apkFile = File(apkPath);
    final keystoreFile = File(keystorePath);
    final outputDirectory = Directory(outputDir);

    if (!apkFile.existsSync()) {
      _showMessage('APK 文件不存在');
      return;
    }
    if (!keystoreFile.existsSync()) {
      _showMessage('签名文件不存在');
      return;
    }
    if (!outputDirectory.existsSync()) {
      _showMessage('输出目录不存在');
      return;
    }

    setState(() {
      _isSigning = true;
      _logController.text = '';
    });

    try {
      _appendLog('开始签名，共 1 条');
      _appendLog('签名策略：${_scheme.label}');
      _appendLog('输入 APK：$apkPath');
      _appendLog('输出目录：$outputDir');
      _appendLog('签名别名：$alias');

      if (_scheme.requiresApkSigner) {
        final apksigner = _findExecutable('apksigner');
        if (apksigner == null) {
          _appendLog('未找到 apksigner，无法执行 ${_scheme.label}');
          _appendLog('请安装 Android Build Tools 并将 apksigner 加入 PATH。');
          _showMessage('缺少 apksigner，当前仅支持 V1');
          return;
        }
      }

      final jarsigner = _findExecutable('jarsigner');
      if (jarsigner == null) {
        _appendLog('未找到 jarsigner，无法执行 V1 签名。');
        _showMessage('未找到 jarsigner');
        return;
      }

      final outputPath = _buildOutputPath(apkFile.path, outputDir);
      final copiedFile = await apkFile.copy(outputPath);
      _appendLog('已创建输出文件：${copiedFile.path}');
      _appendLog('调用 jarsigner 执行签名...');

      final result = await Process.run(jarsigner, [
        '-keystore',
        keystorePath,
        '-storepass',
        storePassword,
        '-keypass',
        keyPassword,
        copiedFile.path,
        alias,
      ]);

      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();

      if (stdout.isNotEmpty) {
        _appendLog(stdout);
      }
      if (stderr.isNotEmpty) {
        _appendLog(stderr);
      }

      if (result.exitCode == 0) {
        _appendLog('签名成功：$outputPath');
        _appendLog('签名完成');
        _showMessage('签名成功');
      } else {
        if (File(outputPath).existsSync()) {
          File(outputPath).deleteSync();
        }
        _appendLog('签名失败，退出码：${result.exitCode}');
        _showMessage('签名失败');
      }
    } catch (error) {
      _appendLog('执行异常：$error');
      _showMessage('签名执行异常');
    } finally {
      if (mounted) {
        setState(() {
          _isSigning = false;
        });
      }
    }
  }

  String _buildOutputPath(String apkPath, String outputDir) {
    final basename = File(apkPath).uri.pathSegments.last;
    final dotIndex = basename.lastIndexOf('.');
    final name = dotIndex == -1 ? basename : basename.substring(0, dotIndex);
    return '$outputDir${Platform.pathSeparator}${name}_sign.apk';
  }

  String? _findExecutable(String name) {
    final pathValue = Platform.environment['PATH'] ?? '';
    final separator = Platform.isWindows ? ';' : ':';
    final extension = Platform.isWindows ? '.exe' : '';

    for (final dir in pathValue.split(separator)) {
      final trimmed = dir.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final candidate = File(
        '$trimmed${Platform.pathSeparator}$name$extension',
      );
      if (candidate.existsSync()) {
        return candidate.path;
      }
    }

    return null;
  }

  void _appendLog(String message) {
    final current = _logController.text;
    _logController.text = current.isEmpty ? message : '$current\n$message';
  }

  void _showMessage(String message) {
    TDToast.showText(
      message,
      context: context,
    );
  }
}
