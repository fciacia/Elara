import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class AWSApiService {
  static const String baseUrl = 'https://5hafl96p94.execute-api.us-east-1.amazonaws.com/dev';  // Original AWS endpoint
  
  final Dio _dio = Dio();
  
  AWSApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 60);
    _dio.options.headers = {
      'Accept': '*/*',  // Simplified to avoid CORS preflight
    };
    
    // Add interceptors for logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,  // Disable request body logging to avoid huge base64 logs
        responseBody: true,
        logPrint: (object) => print('[API] $object'),
      ),
    );
  }

  /// Query medical documents using the AI chat API
  Future<MedicalQueryResponse> queryMedicalDocuments({
    required String question,
    required String userType,
    String language = 'en',
    String? patientId,
  }) async {
    final requestData = {
      'question': question,
      'user_type': userType,
      'language': language,
      if (patientId != null) 'patient_id': patientId,
    };

    print('\n🌐 [HTTP] Making Lambda query request...');
    print('🔗 [HTTP] URL: ${_dio.options.baseUrl}/query');
    print('📤 [HTTP] Request method: POST');
    print('📋 [HTTP] Request payload:');
    print('   - question: "${question.length > 50 ? question.substring(0, 50) + "..." : question}"');
    print('   - user_type: $userType');
    print('   - language: $language');
    print('   - patient_id: ${patientId ?? "null"}');
    print('🚀 [HTTP] Sending request...');

    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await _dio.post(
        '/query',
        data: requestData,
      );
      
      stopwatch.stop();
      
      print('✅ [HTTP] Response received in ${stopwatch.elapsedMilliseconds}ms');
      print('📊 [HTTP] Status code: ${response.statusCode}');
      print('📝 [HTTP] Response headers:');
      response.headers.forEach((name, values) {
        print('   - $name: ${values.join(", ")}');
      });
      
      if (response.statusCode == 200) {
        print('📥 [HTTP] Response data preview:');
        final data = response.data;
        if (data is Map<String, dynamic>) {
          print('   - answer_length: ${data['answer']?.toString().length ?? 0}');
          print('   - confidence: ${data['confidence'] ?? "not provided"}');
          print('   - session_id: ${data['session_id'] ?? "not provided"}');
          print('   - sources_count: ${data['sources']?.length ?? 0}');
          print('   - conversation_id: ${data['conversation_id'] ?? "not provided"}');
        }
        
        print('🎯 [HTTP] Creating MedicalQueryResponse from JSON...');
        final medicalResponse = MedicalQueryResponse.fromJson(response.data);
        print('✅ [HTTP] Successfully parsed response\n');
        
        return medicalResponse;
      } else {
        print('❌ [HTTP] Request failed with status: ${response.statusCode}');
        print('📄 [HTTP] Error response body: ${response.data}');
        throw Exception('Query failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('\n🚨 [HTTP] DioException occurred!');
      print('🔍 [HTTP] Error type: ${e.type}');
      print('📝 [HTTP] Error message: ${e.message}');
      
      if (e.response != null) {
        print('📊 [HTTP] Error status code: ${e.response!.statusCode}');
        print('📄 [HTTP] Error response data: ${e.response!.data}');
        print('🔗 [HTTP] Error request path: ${e.response!.requestOptions.path}');
        
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
          throw Exception('Lambda error: ${errorData['error']}');
        } else {
          throw Exception('Query failed: ${e.message} (Status: ${e.response!.statusCode})');
        }
      } else {
        print('🌐 [HTTP] Network error - no response received');
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('\n💥 [HTTP] Unexpected error occurred!');
      print('🚨 [HTTP] Error type: ${e.runtimeType}');
      print('📝 [HTTP] Error details: $e');
      print('🔍 [HTTP] Stack trace preview: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      
      throw Exception('Unexpected error during Lambda request: $e');
    }
  }

  /// Upload document to AWS Lambda
  Future<DocumentUploadResponse> uploadDocument({
    required Uint8List fileBytes,
    required String fileName,
    required String fileType,
    String? patientId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('[DEBUG] Starting upload for file: $fileName');
      print('[DEBUG] File size: ${fileBytes.length} bytes');
      print('[DEBUG] File type: $fileType');
      print('[DEBUG] Patient ID: $patientId');
      
      // Convert file to base64 for JSON payload (to match your Lambda function)
      final base64FileContent = base64Encode(fileBytes);
      
      final requestData = {
        'docName': fileName,  // Lambda expects 'docName' not 'fileName'
        'fileContent': base64FileContent,  // Lambda expects 'fileContent'
        'fileSize': fileBytes.length,
        'fileType': fileType,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        if (patientId != null) 'patient_id': patientId,
        if (metadata != null) 'metadata': metadata,
      };

      print('[DEBUG] Sending JSON request to: ${_dio.options.baseUrl}/upload');
      print('[DEBUG] Request payload size: ${jsonEncode(requestData).length} bytes');
      
      final response = await _dio.post(
        '/upload',
        data: requestData,  // Send as Map, let Dio handle JSON encoding
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status < 500; // Accept 4xx responses for debugging
          },
        ),
      );
      
      print('[DEBUG] Upload response status: ${response.statusCode}');
      print('[DEBUG] Upload response data: ${response.data}');
      
      if (response.statusCode == 200) {
        // Adapt the response to match our expected format
        final responseData = response.data;
        
        return DocumentUploadResponse(
          documentId: responseData['item']?['docsname'] ?? fileName,
          fileName: responseData['item']?['docsname'] ?? fileName,
          status: 'uploaded',
          fileSizeBytes: fileBytes.length,
          fileType: fileType,
          uploadedAt: DateTime.now(),
          patientId: patientId,
          metadata: metadata,
          url: responseData['item']?['s3_key'] != null 
              ? 's3://my-medical-docs/${responseData['item']['s3_key']}'
              : null,
        );
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[DEBUG] DioException occurred: ${e.type}');
      print('[DEBUG] Error message: ${e.message}');
      print('[DEBUG] Response data: ${e.response?.data}');
      print('[DEBUG] Response status: ${e.response?.statusCode}');
      
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['error'] ?? 'Upload failed: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('[DEBUG] Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get uploaded documents list
  Future<List<DocumentInfo>> getDocuments({
    String? patientId,
    int limit = 50,
    String? nextToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        if (patientId != null) 'patient_id': patientId,
        if (nextToken != null) 'next_token': nextToken,
      };

      final response = await _dio.get(
        '/documents',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> documentsData = response.data['documents'] ?? [];
        return documentsData.map((doc) => DocumentInfo.fromJson(doc)).toList();
      } else {
        throw Exception('Failed to get documents with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['error'] ?? 'Failed to get documents: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final response = await _dio.delete('/documents/$documentId');
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['error'] ?? 'Delete failed: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Health check endpoint
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Medical Query Response Model
class MedicalQueryResponse {
  final String question;
  final String answer;
  final String language;
  final String userType;
  final String confidence;
  final int totalDocumentsFound;
  final List<DocumentSource>? sources;
  final String? sessionId;
  final DateTime timestamp;
  
  MedicalQueryResponse({
    required this.question,
    required this.answer,
    required this.language,
    required this.userType,
    required this.confidence,
    required this.totalDocumentsFound,
    this.sources,
    this.sessionId,
    required this.timestamp,
  });
  
  factory MedicalQueryResponse.fromJson(Map<String, dynamic> json) {
    return MedicalQueryResponse(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      language: json['language'] ?? 'en',
      userType: json['user_type'] ?? 'doctor',
      confidence: json['confidence'] ?? 'LOW',
      totalDocumentsFound: json['total_documents_found'] ?? 0,
      sources: json['sources'] != null 
          ? (json['sources'] as List).map((s) => DocumentSource.fromJson(s)).toList()
          : null,
      sessionId: json['session_id'],
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(
              json['timestamp'] is int 
                  ? json['timestamp'] * 1000  // Convert seconds to milliseconds
                  : int.parse(json['timestamp'].toString()) * 1000
            )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'language': language,
      'user_type': userType,
      'confidence': confidence,
      'total_documents_found': totalDocumentsFound,
      'sources': sources?.map((s) => s.toJson()).toList(),
      'session_id': sessionId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Document Source Model
class DocumentSource {
  final String id;
  final String excerpt;
  final String confidence;
  final String? title;
  final String? type;
  final double? relevanceScore;
  
  DocumentSource({
    required this.id,
    required this.excerpt,
    required this.confidence,
    this.title,
    this.type,
    this.relevanceScore,
  });
  
  factory DocumentSource.fromJson(Map<String, dynamic> json) {
    return DocumentSource(
      id: json['id'] ?? '',
      excerpt: json['excerpt'] ?? '',
      confidence: json['confidence'] ?? 'MEDIUM',
      title: json['title'],
      type: json['type'],
      relevanceScore: json['relevance_score']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'excerpt': excerpt,
      'confidence': confidence,
      'title': title,
      'type': type,
      'relevance_score': relevanceScore,
    };
  }
}

/// Document Upload Response Model
class DocumentUploadResponse {
  final String documentId;
  final String fileName;
  final String status;
  final String? url;
  final int fileSizeBytes;
  final String fileType;
  final DateTime uploadedAt;
  final String? patientId;
  final Map<String, dynamic>? metadata;
  
  DocumentUploadResponse({
    required this.documentId,
    required this.fileName,
    required this.status,
    this.url,
    required this.fileSizeBytes,
    required this.fileType,
    required this.uploadedAt,
    this.patientId,
    this.metadata,
  });
  
  factory DocumentUploadResponse.fromJson(Map<String, dynamic> json) {
    return DocumentUploadResponse(
      documentId: json['document_id'] ?? '',
      fileName: json['file_name'] ?? '',
      status: json['status'] ?? 'uploaded',
      url: json['url'],
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      fileType: json['file_type'] ?? '',
      uploadedAt: json['uploaded_at'] != null 
          ? DateTime.parse(json['uploaded_at'])
          : DateTime.now(),
      patientId: json['patient_id'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'file_name': fileName,
      'status': status,
      'url': url,
      'file_size_bytes': fileSizeBytes,
      'file_type': fileType,
      'uploaded_at': uploadedAt.toIso8601String(),
      'patient_id': patientId,
      'metadata': metadata,
    };
  }
}

/// Document Info Model
class DocumentInfo {
  final String id;
  final String fileName;
  final String fileType;
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final String status;
  final String? patientId;
  final Map<String, dynamic>? metadata;
  final String? thumbnailUrl;
  
  DocumentInfo({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    required this.uploadedAt,
    required this.status,
    this.patientId,
    this.metadata,
    this.thumbnailUrl,
  });
  
  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      id: json['id'] ?? '',
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      uploadedAt: json['uploaded_at'] != null 
          ? DateTime.parse(json['uploaded_at'])
          : DateTime.now(),
      status: json['status'] ?? 'uploaded',
      patientId: json['patient_id'],
      metadata: json['metadata'],
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'uploaded_at': uploadedAt.toIso8601String(),
      'status': status,
      'patient_id': patientId,
      'metadata': metadata,
      'thumbnail_url': thumbnailUrl,
    };
  }

  String get fileSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
