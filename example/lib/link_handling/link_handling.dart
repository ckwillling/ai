// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const LinkHandlingApp());

class LinkHandlingApp extends StatelessWidget {
  const LinkHandlingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '链接处理示例',
      home: LinkHandlingExample(),
    );
  }
}

class LinkHandlingExample extends StatelessWidget {
  const LinkHandlingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('链接处理示例')),
      body: LlmChatView(
        provider: createLinkEchoProvider(),
        welcomeMessage: '欢迎！我会回显你的消息，你可以在消息中包含链接。\n\n'
            '点击下面的链接测试功能：\n'
            '- [Flutter 官网](https://flutter.dev) - 了解 Flutter 框架\n'
            '- [GitHub](https://github.com/flutter/flutter) - 查看源代码\n'
            '- [Google](https://google.com) - 搜索引擎\n\n'
            '你也可以在聊天中发送包含链接的消息！',
        // 通过样式传递链接点击处理回调
        style: LlmChatViewStyle(
          onTapLink: (text, href, title) async {
            if (href == null) return;
            
            // 显示确认对话框
            final shouldOpen = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('打开链接'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('要打开以下链接吗？'),
                      const SizedBox(height: 8),
                      Text(
                        href,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      if (title.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('标题: $title'),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('打开'),
                    ),
                  ],
                );
              },
            );

            if (shouldOpen == true) {
              try {
                final uri = Uri.parse(href);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('无法打开链接: $href')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('链接格式错误: $e')),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}

/// 创建一个带有链接示例的 EchoProvider
EchoProvider createLinkEchoProvider() {
  return EchoProvider();
}
