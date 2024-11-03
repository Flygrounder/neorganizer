import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:neorganizer/bottom_bar.dart';
import 'package:neorganizer/top_bar.dart';
import 'package:webdav_client/webdav_client.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar('Настройки'),
      body: Padding(padding: EdgeInsets.all(16.0), child: SettingsForm()),
      bottomNavigationBar: BottomBar(BottomBarTab.settings),
    );
  }
}

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  static const webdavServerAddressKey = "webdav-server-address";
  static const webdavUsernameKey = "webdav-username";
  static const webdavPasswordKey = "webdav-password";
  static const webdavDirectoryKey = "webdav-directory";

  final GlobalKey<FormState> _formKey = GlobalKey();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _serverAddressController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _directoryController = TextEditingController();
  Future<void>? connectionCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var data = await _secureStorage.readAll();
      setState(() {
        _serverAddressController.text = data[webdavServerAddressKey] ?? "";
        _usernameController.text = data[webdavUsernameKey] ?? "";
        _passwordController.text = data[webdavPasswordKey] ?? "";
        _directoryController.text = data[webdavDirectoryKey] ?? "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget connectionCheckWidget = FutureBuilder(
        future: connectionCheck,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return const SizedBox.shrink();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Проверка...');
          }
          if (snapshot.hasError) {
            return const Text('Ошибка');
          }
          return const Text('Успех');
        });

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(hintText: 'Адрес сервера'),
            controller: _serverAddressController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите адрес сервера';
              }
              if (!Uri.parse(value).isAbsolute) {
                return 'Некорректный адрес\nПример корректного адреса:\nhttps://cloud.flygrounder.ru/remote.php/dav/files/flygrounder';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Имя пользователя'),
            controller: _usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите имя пользователя';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Пароль'),
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите пароль';
              }
              return null;
            },
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Путь к папке'),
            controller: _directoryController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите путь к папке';
              }
              return null;
            },
          ),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      _secureStorage.write(
                          key: webdavServerAddressKey,
                          value: _serverAddressController.text);
                      _secureStorage.write(
                          key: webdavUsernameKey,
                          value: _usernameController.text);
                      _secureStorage.write(
                          key: webdavPasswordKey,
                          value: _passwordController.text);
                      _secureStorage.write(
                          key: webdavDirectoryKey,
                          value: _directoryController.text);
                    }
                  },
                  child: const Text('Сохранить')),
              ElevatedButton(
                  onPressed: () async {
                    var client = newClient(_serverAddressController.text,
                        user: _usernameController.text,
                        password: _passwordController.text);
                    setState(() {
                      connectionCheck =
                          client.readDir(_directoryController.text);
                    });
                  },
                  child: const Text('Проверить')),
            ],
          ),
          connectionCheckWidget
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serverAddressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _directoryController.dispose();
    super.dispose();
  }
}
