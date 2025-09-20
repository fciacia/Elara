import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'welcome': 'Welcome back, Doctor',
          'patients': 'Patients',
          'chats': 'Chats',
          'logout': 'Logout',
        },
        'ms': {
          'welcome': 'Selamat datang kembali, Doktor',
          'patients': 'Pesakit',
          'chats': 'Sembang',
          'logout': 'Log Keluar',
        },
        'zh': {
          'welcome': '欢迎回来，医生',
          'patients': '病人',
          'chats': '聊天',
          'logout': '登出',
        },
      };
}
