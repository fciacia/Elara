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
        },
      };
}
