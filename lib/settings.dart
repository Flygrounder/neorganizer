import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:neorganizer/bottom_bar.dart';
import 'package:neorganizer/top_bar.dart';
import 'package:webdav_client/webdav_client.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar('Настройки', displayBackButton: false),
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
  final GlobalKey<FormState> _formKey = GlobalKey();
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
      var storage = GetIt.I.get<WebDavSettingsStorage>();
      var settings = await storage.loadSettings();
      setState(() {
        _serverAddressController.text = settings.address;
        _usernameController.text = settings.username;
        _passwordController.text = settings.password;
        _directoryController.text = settings.directory;
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
      child: ListView(
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
                      var settings = WebDavSettings(
                          address: _serverAddressController.text,
                          username: _usernameController.text,
                          password: _passwordController.text,
                          directory: _directoryController.text);
                      var storage = GetIt.I.get<WebDavSettingsStorage>();
                      await storage.saveSettings(settings);
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

class WebDavSettings {
  final String address;
  final String username;
  final String password;
  final String directory;

  WebDavSettings(
      {required this.address,
      required this.username,
      required this.password,
      required this.directory});
}

class WebDavSettingsStorage {
  static const _addressKey = "webdav-server-address";
  static const _usernameKey = "webdav-username";
  static const _passwordKey = "webdav-password";
  static const _directoryKey = "webdav-directory";

  FlutterSecureStorage secureStorage;

  WebDavSettingsStorage({required this.secureStorage});

  Future<void> saveSettings(WebDavSettings settings) {
    return Future.wait([
      secureStorage.write(key: _addressKey, value: settings.address),
      secureStorage.write(key: _usernameKey, value: settings.username),
      secureStorage.write(key: _passwordKey, value: settings.password),
      secureStorage.write(key: _directoryKey, value: settings.directory),
    ]);
  }

  Future<WebDavSettings> loadSettings() async {
    var storageMap = await secureStorage.readAll();
    return WebDavSettings(
        address: storageMap[_addressKey] ?? "",
        username: storageMap[_usernameKey] ?? "",
        password: storageMap[_passwordKey] ?? "",
        directory: storageMap[_directoryKey] ?? "");
  }
}
