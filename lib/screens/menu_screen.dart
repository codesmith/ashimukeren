import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メニュー'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(
            leading: Icon(Icons.person, color: Colors.amber),
            title: Text('プロフィール'),
            subtitle: Text('ユーザー情報の確認・編集'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.settings, color: Colors.amber),
            title: Text('設定'),
            subtitle: Text('アプリの設定'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.history, color: Colors.amber),
            title: Text('学習履歴'),
            subtitle: Text('過去の学習記録を確認'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('ヘルプ'),
            subtitle: Text('使い方やよくある質問'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info, color: Colors.amber),
            title: Text('アプリについて'),
            subtitle: Text('バージョン情報・利用規約'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ログアウト'),
            subtitle: const Text('アプリからログアウト'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ログアウト'),
                  content: const Text('ログアウトしますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // ここでログアウト処理を実装
                      },
                      child: const Text('ログアウト'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}