import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          // Navigation
          'dashboard': 'Dashboard',
          'documents': 'Documents',
          'ai_chat': 'AI Chat',
          'analytics': 'Analytics',
          'settings': 'Settings',
          
          // Settings Panel
          'settings_title': 'Settings',
          'customize_experience': 'Customize your Medical AI experience',
          'appearance': 'Appearance',
          'notifications': 'Notifications',
          'privacy_security': 'Privacy & Security',
          'account': 'Account',
          
          // Appearance
          'dark_mode': 'Dark Mode',
          'light_mode': 'Light Mode',
          'language': 'Language',
          'english': 'English',
          'bahasa_malaysia': 'Bahasa Malaysia',
          'chinese': '中文',
          'Choose your preferred language': 'Choose your preferred language',
          'Switch to light theme': 'Switch to light theme',
          'Switch to dark theme': 'Switch to dark theme',
          
          // Notifications
          'document_processing': 'Document Processing',
          'document_processing_desc': 'Get notified when documents are processed',
          'ai_insights': 'AI Insights',
          'ai_insights_desc': 'Receive AI-generated insights and alerts',
          
          // Privacy & Security
          'data_encryption': 'Data Encryption',
          'data_encryption_desc': 'All data is encrypted end-to-end',
          'privacy_policy': 'Privacy Policy',
          'privacy_policy_desc': 'Review our privacy practices',
          'terms_of_service': 'Terms of Service',
          'terms_of_service_desc': 'Read our terms and conditions',
          
          // Account
          'export_data': 'Export Data',
          'export_data_desc': 'Download your data',
          'sign_out': 'Sign Out',
          'sign_out_desc': 'Sign out from your account',
          
          // Chat
          'type_your_message': 'Type your message here...',
          'send': 'Send',
          'thinking': 'Thinking...',
          
          // Document Types
          'lab_report': 'Lab Report',
          'prescription': 'Prescription',
          'xray': 'X-Ray',
          'discharge_summary': 'Discharge Summary',
          'consultation': 'Consultation',
          'insurance': 'Insurance',
          'general': 'General',
          'lab_reports': 'Lab Reports',
          'prescriptions': 'Prescriptions',
          'discharge_papers': 'Discharge Papers',
          'xray_imaging': 'X-Ray & Imaging',
          'consultation_notes': 'Consultation Notes',
          'insurance_forms': 'Insurance Forms',
          'general_documents': 'General Documents',
          
          // Common
          'no_documents_found': 'No documents found',
          'upload_first_document': 'Upload your first document to get started',
          'coming_soon': 'Coming soon!',
          'document_sharing_coming_soon': 'Document sharing coming soon!',
          
          // Legacy
          'welcome': 'Welcome back, Doctor',
          'patients': 'Patients',
          'chats': 'Chats',
          'logout': 'Logout',
          
          // Authentication
          'welcome_back_title': 'Welcome Back',
          'medical_companion_tagline': 'Your intelligent medical companion awaits',
          'email_address': 'Email Address',
          'enter_email_address': 'Enter your email address',
          'please_enter_email': 'Please enter your email',
          'please_enter_valid_email': 'Please enter a valid email',
          'password': 'Password',
          'enter_password': 'Enter your password',
          'please_enter_password': 'Please enter your password',
          'forgot_password': 'Forgot Password?',
          'forgot_password_coming_soon': 'Forgot password feature coming soon',
          'sign_in': 'Sign In',
          'demo_accounts': 'Demo Accounts',
          'doctor_account': 'Doctor Account',
          'nurse_account': 'Nurse Account',
          'admin_account': 'Admin Account',
          'use_any_password': 'Use any password to login',
          
          // Home & Navigation
          'welcome_back_user': 'Welcome back,',
          'registered_nurse': 'Registered Nurse',
          'medical_doctor': 'Medical Doctor',
          'administrator': 'Administrator',
          'user': 'User',
          
          // Dashboard
          'welcome_medical_ai': 'Welcome to Medical AI',
          'good_morning_doctor': 'Good morning, Doctor',
          'system_overview': 'System Overview',
          'recent_chat_sessions': 'Recent Chat Sessions',
          'recent_queries': 'Recent Queries',
          'recent_patients': 'Recent Patients',
          'no_chat_sessions': 'No chat sessions yet. Start your first consultation!',
          'no_queries_yet': 'No queries yet. Ask me anything about medical care!',
          
          // Auth Components
          'hospital_sso': 'Hospital Single Sign-On (SSO)',
          'username_password': 'Username & Password',
          'close': 'Close',
          'privacy_compliance': 'Privacy & Compliance',
        },
        'ms': {
          // Navigation
          'dashboard': 'Papan Pemuka',
          'documents': 'Dokumen',
          'ai_chat': 'Sembang AI',
          'analytics': 'Analitik',
          'settings': 'Tetapan',
          
          // Settings Panel
          'settings_title': 'Tetapan',
          'customize_experience': 'Sesuaikan pengalaman AI Perubatan anda',
          'appearance': 'Penampilan',
          'notifications': 'Pemberitahuan',
          'privacy_security': 'Privasi & Keselamatan',
          'account': 'Akaun',
          
          // Appearance
          'dark_mode': 'Mod Gelap',
          'light_mode': 'Mod Cerah',
          'language': 'Bahasa',
          'english': 'English',
          'bahasa_malaysia': 'Bahasa Malaysia',
          'chinese': '中文',
          'Choose your preferred language': 'Pilih bahasa pilihan anda',
          'Switch to light theme': 'Tukar ke tema cerah',
          'Switch to dark theme': 'Tukar ke tema gelap',
          
          // Notifications
          'document_processing': 'Pemprosesan Dokumen',
          'document_processing_desc': 'Dapatkan pemberitahuan apabila dokumen diproses',
          'ai_insights': 'Wawasan AI',
          'ai_insights_desc': 'Terima wawasan dan amaran yang dihasilkan AI',
          
          // Privacy & Security
          'data_encryption': 'Penyulitan Data',
          'data_encryption_desc': 'Semua data disulitkan dari hujung ke hujung',
          'privacy_policy': 'Dasar Privasi',
          'privacy_policy_desc': 'Semak amalan privasi kami',
          'terms_of_service': 'Terma Perkhidmatan',
          'terms_of_service_desc': 'Baca terma dan syarat kami',
          
          // Account
          'export_data': 'Eksport Data',
          'export_data_desc': 'Muat turun data anda',
          'sign_out': 'Log Keluar',
          'sign_out_desc': 'Log keluar dari akaun anda',
          
          // Chat
          'type_your_message': 'Taip mesej anda di sini...',
          'send': 'Hantar',
          'thinking': 'Berfikir...',
          
          // Document Types
          'lab_report': 'Laporan Makmal',
          'prescription': 'Preskripsi',
          'xray': 'X-Ray',
          'discharge_summary': 'Ringkasan Discaj',
          'consultation': 'Perundingan',
          'insurance': 'Insurans',
          'general': 'Umum',
          'lab_reports': 'Laporan Makmal',
          'prescriptions': 'Preskripsi',
          'discharge_papers': 'Kertas Discaj',
          'xray_imaging': 'X-Ray & Pengimejan',
          'consultation_notes': 'Nota Perundingan',
          'insurance_forms': 'Borang Insurans',
          'general_documents': 'Dokumen Umum',
          
          // Common
          'no_documents_found': 'Tiada dokumen dijumpai',
          'upload_first_document': 'Muat naik dokumen pertama anda untuk bermula',
          'coming_soon': 'Akan datang!',
          'document_sharing_coming_soon': 'Perkongsian dokumen akan datang!',
          
          // Legacy
          'welcome': 'Selamat datang kembali, Doktor',
          'patients': 'Pesakit',
          'chats': 'Sembang',
          'logout': 'Log Keluar',
          
          // Authentication
          'welcome_back_title': 'Selamat Datang Kembali',
          'medical_companion_tagline': 'Rakan perubatan pintar anda menunggu',
          'email_address': 'Alamat E-mel',
          'enter_email_address': 'Masukkan alamat e-mel anda',
          'please_enter_email': 'Sila masukkan e-mel anda',
          'please_enter_valid_email': 'Sila masukkan e-mel yang sah',
          'password': 'Kata Laluan',
          'enter_password': 'Masukkan kata laluan anda',
          'please_enter_password': 'Sila masukkan kata laluan anda',
          'forgot_password': 'Lupa Kata Laluan?',
          'forgot_password_coming_soon': 'Ciri lupa kata laluan akan datang',
          'sign_in': 'Log Masuk',
          'demo_accounts': 'Akaun Demo',
          'doctor_account': 'Akaun Doktor',
          'nurse_account': 'Akaun Jururawat',
          'admin_account': 'Akaun Pentadbir',
          'use_any_password': 'Gunakan sebarang kata laluan untuk log masuk',
          
          // Home & Navigation
          'welcome_back_user': 'Selamat datang kembali,',
          'registered_nurse': 'Jururawat Berdaftar',
          'medical_doctor': 'Doktor Perubatan',
          'administrator': 'Pentadbir',
          'user': 'Pengguna',
          
          // Dashboard
          'welcome_medical_ai': 'Selamat datang ke AI Perubatan',
          'good_morning_doctor': 'Selamat pagi, Doktor',
          'system_overview': 'Gambaran Keseluruhan Sistem',
          'recent_chat_sessions': 'Sesi Sembang Terkini',
          'recent_queries': 'Pertanyaan Terkini',
          'recent_patients': 'Pesakit Terkini',
          'no_chat_sessions': 'Belum ada sesi sembang lagi. Mulakan konsultasi pertama anda!',
          'no_queries_yet': 'Belum ada pertanyaan lagi. Tanya saya apa sahaja tentang penjagaan perubatan!',
          
          // Auth Components
          'hospital_sso': 'Log Masuk Tunggal Hospital (SSO)',
          'username_password': 'Nama Pengguna & Kata Laluan',
          'close': 'Tutup',
          'privacy_compliance': 'Privasi & Pematuhan',
        },
        'zh': {
          // Navigation
          'dashboard': '仪表板',
          'documents': '文档',
          'ai_chat': 'AI聊天',
          'analytics': '分析',
          'settings': '设置',
          
          // Settings Panel
          'settings_title': '设置',
          'customize_experience': '定制您的医疗AI体验',
          'appearance': '外观',
          'notifications': '通知',
          'privacy_security': '隐私与安全',
          'account': '账户',
          
          // Appearance
          'dark_mode': '深色模式',
          'light_mode': '浅色模式',
          'language': '语言',
          'english': 'English',
          'bahasa_malaysia': 'Bahasa Malaysia',
          'chinese': '中文',
          'Choose your preferred language': '选择您的首选语言',
          'Switch to light theme': '切换到浅色主题',
          'Switch to dark theme': '切换到深色主题',
          
          // Notifications
          'document_processing': '文档处理',
          'document_processing_desc': '文档处理完成时获得通知',
          'ai_insights': 'AI洞察',
          'ai_insights_desc': '接收AI生成的洞察和警报',
          
          // Privacy & Security
          'data_encryption': '数据加密',
          'data_encryption_desc': '所有数据均端到端加密',
          'privacy_policy': '隐私政策',
          'privacy_policy_desc': '查看我们的隐私做法',
          'terms_of_service': '服务条款',
          'terms_of_service_desc': '阅读我们的条款和条件',
          
          // Account
          'export_data': '导出数据',
          'export_data_desc': '下载您的数据',
          'sign_out': '注销',
          'sign_out_desc': '从您的账户注销',
          
          // Chat
          'type_your_message': '在此输入您的消息...',
          'send': '发送',
          'thinking': '思考中...',
          
          // Document Types
          'lab_report': '实验报告',
          'prescription': '处方',
          'xray': 'X光',
          'discharge_summary': '出院摘要',
          'consultation': '咨询',
          'insurance': '保险',
          'general': '通用',
          'lab_reports': '实验报告',
          'prescriptions': '处方',
          'discharge_papers': '出院文件',
          'xray_imaging': 'X光与影像',
          'consultation_notes': '咨询记录',
          'insurance_forms': '保险表格',
          'general_documents': '通用文档',
          
          // Common
          'no_documents_found': '未找到文档',
          'upload_first_document': '上传您的第一个文档开始使用',
          'coming_soon': '即将推出！',
          'document_sharing_coming_soon': '文档分享即将推出！',
          
          // Legacy
          'welcome': '欢迎回来，医生',
          'patients': '病人',
          'chats': '聊天',
          'logout': '登出',
          
          // Authentication
          'welcome_back_title': '欢迎回来',
          'medical_companion_tagline': '您的智能医疗助手在等待',
          'email_address': '电子邮件地址',
          'enter_email_address': '输入您的电子邮件地址',
          'please_enter_email': '请输入您的电子邮件',
          'please_enter_valid_email': '请输入有效的电子邮件',
          'password': '密码',
          'enter_password': '输入您的密码',
          'please_enter_password': '请输入您的密码',
          'forgot_password': '忘记密码？',
          'forgot_password_coming_soon': '忘记密码功能即将推出',
          'sign_in': '登录',
          'demo_accounts': '演示账户',
          'doctor_account': '医生账户',
          'nurse_account': '护士账户',
          'admin_account': '管理员账户',
          'use_any_password': '使用任意密码登录',
          
          // Home & Navigation
          'welcome_back_user': '欢迎回来，',
          'registered_nurse': '注册护士',
          'medical_doctor': '医学博士',
          'administrator': '管理员',
          'user': '用户',
          
          // Dashboard
          'welcome_medical_ai': '欢迎使用医疗AI',
          'good_morning_doctor': '早上好，医生',
          'system_overview': '系统概览',
          'recent_chat_sessions': '最近聊天会话',
          'recent_queries': '最近查询',
          'recent_patients': '最近患者',
          'no_chat_sessions': '还没有聊天会话。开始您的首次咨询！',
          'no_queries_yet': '还没有查询。问我任何关于医疗护理的问题！',
          
          // Auth Components
          'hospital_sso': '医院单点登录（SSO）',
          'username_password': '用户名和密码',
          'close': '关闭',
          'privacy_compliance': '隐私与合规',
        },
      };
}
