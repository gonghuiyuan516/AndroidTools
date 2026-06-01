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
        home: const AndroidToolsHomePage(),
      ),
    );
  }
}

class AndroidToolsHomePage extends StatelessWidget {
  const AndroidToolsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = TDTheme.of(context);

    return Scaffold(
      backgroundColor: theme.bgColorPage,
      appBar: const TDNavBar(
        title: 'AndroidTools',
        useDefaultBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.whiteColor1,
              borderRadius: BorderRadius.circular(theme.radiusExtraLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDText(
                  'TDesign Flutter 已接入',
                  style: TextStyle(
                    fontSize: theme.fontTitleLarge?.size,
                    fontWeight: FontWeight.w600,
                    color: theme.textColorPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TDText(
                  '当前项目已经引入 tdesign_flutter，可直接基于 TDesign 组件库继续开发桌面工具页面。',
                  style: TextStyle(
                    fontSize: theme.fontBodyMedium?.size,
                    color: theme.textColorSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TDTag('Windows', theme: TDTagTheme.primary),
                    TDTag('macOS', theme: TDTagTheme.success),
                    TDTag('Linux', theme: TDTagTheme.warning),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TDCellGroup(
            title: '组件接入状态',
            cells: const [
              TDCell(
                title: 'TDNavBar',
                note: '已启用',
                arrow: false,
              ),
              TDCell(
                title: 'TDButton',
                note: '已启用',
                arrow: false,
              ),
              TDCell(
                title: 'TDTag',
                note: '已启用',
                arrow: false,
              ),
              TDCell(
                title: 'TDCellGroup',
                note: '已启用',
                arrow: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TDButton(
            text: '开始构建 AndroidTools',
            theme: TDButtonTheme.primary,
            shape: TDButtonShape.filled,
            onTap: () {
              TDToast.showText(
                'TDesign Flutter 接入完成',
                context: context,
              );
            },
          ),
        ],
      ),
    );
  }
}
