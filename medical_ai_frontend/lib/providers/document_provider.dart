import 'package:flutter/material.dart';
import 'dart:io';

enum DocumentType { 
  labReport, 
  prescription, 
  discharge, 
  xray, 
  consultation, 
  insurance, 
  general 
}

enum ProcessingStatus { 
  pending, 
  processing, 
  completed, 
  failed 
}

class MedicalDocument {
  final String id;
  final String name;
  final String fileName;
  final DocumentType type;
  final DateTime uploadDate;
  final String filePath;
  final int fileSizeBytes;
  final String? patientId;
  final String? doctorId;
  final ProcessingStatus processingStatus;
  final List<String> extractedText;
  final Map<String, dynamic>? metadata;
  final List<String> tags;
  final String? thumbnailPath;

  MedicalDocument({
    required this.id,
    required this.name,
    required this.fileName,
    required this.type,
    required this.uploadDate,
    required this.filePath,
    required this.fileSizeBytes,
    this.patientId,
    this.doctorId,
    this.processingStatus = ProcessingStatus.pending,
    this.extractedText = const [],
    this.metadata,
    this.tags = const [],
    this.thumbnailPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileName': fileName,
      'type': type.toString(),
      'uploadDate': uploadDate.toIso8601String(),
      'filePath': filePath,
      'fileSizeBytes': fileSizeBytes,
      'patientId': patientId,
      'doctorId': doctorId,
      'processingStatus': processingStatus.toString(),
      'extractedText': extractedText,
      'metadata': metadata,
      'tags': tags,
      'thumbnailPath': thumbnailPath,
    };
  }
}

class DocumentProvider extends ChangeNotifier {
  List<MedicalDocument> _documents = [];
  List<MedicalDocument> _filteredDocuments = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  String _searchQuery = '';
  DocumentType? _selectedType;
  ProcessingStatus? _selectedStatus;

  // Getters
  List<MedicalDocument> get documents => _filteredDocuments;
  List<MedicalDocument> get filteredDocuments => _filteredDocuments;
  List<MedicalDocument> get allDocuments => _documents;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  DocumentType? get selectedType => _selectedType;
  ProcessingStatus? get selectedStatus => _selectedStatus;

  // Demo documents
  void _initializeDemoDocuments() {
    _documents = [
      MedicalDocument(
        id: '1',
        name: 'Blood Test Results - March 2024',
        fileName: 'blood_test_march_2024.pdf',
        type: DocumentType.labReport,
        uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        filePath: '/documents/blood_test_march_2024.pdf',
        fileSizeBytes: 245760,
        patientId: 'P001',
        doctorId: 'D001',
        processingStatus: ProcessingStatus.completed,
        extractedText: ['Hemoglobin: 14.2 g/dL', 'White Blood Cell Count: 7,200/μL'],
        tags: ['blood test', 'routine checkup', 'march 2024'],
      ),
      MedicalDocument(
        id: '2',
        name: 'Heart Medication Prescription',
        fileName: 'heart_medication_rx.pdf',
        type: DocumentType.prescription,
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        filePath: '/documents/heart_medication_rx.pdf',
        fileSizeBytes: 89120,
        patientId: 'P001',
        doctorId: 'D002',
        processingStatus: ProcessingStatus.completed,
        extractedText: ['Metformin 500mg', 'Take twice daily', 'Duration: 3 months'],
        tags: ['prescription', 'heart medication', 'metformin'],
      ),
      MedicalDocument(
        id: '3',
        name: 'Chest X-Ray Report',
        fileName: 'chest_xray_report.pdf',
        type: DocumentType.xray,
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        filePath: '/documents/chest_xray_report.pdf',
        fileSizeBytes: 1548320,
        patientId: 'P001',
        doctorId: 'D003',
        processingStatus: ProcessingStatus.processing,
        extractedText: [],
        tags: ['x-ray', 'chest', 'radiology'],
      ),
      MedicalDocument(
        id: '4',
        name: 'Hospital Discharge Summary',
        fileName: 'discharge_summary_feb2024.pdf',
        type: DocumentType.discharge,
        uploadDate: DateTime.now().subtract(const Duration(days: 30)),
        filePath: '/documents/discharge_summary_feb2024.pdf',
        fileSizeBytes: 456780,
        patientId: 'P001',
        doctorId: 'D001',
        processingStatus: ProcessingStatus.completed,
        extractedText: ['Admitted for chest pain', 'Discharged in stable condition', 'Follow-up in 2 weeks'],
        tags: ['discharge', 'chest pain', 'cardiology'],
      ),
    ];
    _applyFilters();
  }

  // Initialize with demo data
  void initialize() {
    _setLoading(true);
    _initializeDemoDocuments();
    _setLoading(false);
  }

  // Upload documents
  Future<bool> uploadDocuments(List<File> files) async {
    _setUploading(true);
    _clearError();

    try {
      for (File file in files) {
        // Simulate processing time
        await Future.delayed(const Duration(seconds: 1));

        final document = MedicalDocument(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _extractDocumentName(file.path),
          fileName: file.path.split('/').last,
          type: _inferDocumentType(file.path),
          uploadDate: DateTime.now(),
          filePath: file.path,
          fileSizeBytes: await file.length(),
          processingStatus: ProcessingStatus.pending,
        );

        _documents.add(document);
        
        // Simulate AI processing
        _processDocument(document.id);
      }

      _applyFilters();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setUploading(false);
    }
  }

  // Process document with AI
  Future<void> _processDocument(String documentId) async {
    final docIndex = _documents.indexWhere((d) => d.id == documentId);
    if (docIndex == -1) return;

    // Update status to processing
    _documents[docIndex] = MedicalDocument(
      id: _documents[docIndex].id,
      name: _documents[docIndex].name,
      fileName: _documents[docIndex].fileName,
      type: _documents[docIndex].type,
      uploadDate: _documents[docIndex].uploadDate,
      filePath: _documents[docIndex].filePath,
      fileSizeBytes: _documents[docIndex].fileSizeBytes,
      patientId: _documents[docIndex].patientId,
      doctorId: _documents[docIndex].doctorId,
      processingStatus: ProcessingStatus.processing,
      extractedText: _documents[docIndex].extractedText,
      metadata: _documents[docIndex].metadata,
      tags: _documents[docIndex].tags,
    );
    notifyListeners();

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));

    // Update with processed results
    _documents[docIndex] = MedicalDocument(
      id: _documents[docIndex].id,
      name: _documents[docIndex].name,
      fileName: _documents[docIndex].fileName,
      type: _documents[docIndex].type,
      uploadDate: _documents[docIndex].uploadDate,
      filePath: _documents[docIndex].filePath,
      fileSizeBytes: _documents[docIndex].fileSizeBytes,
      patientId: _documents[docIndex].patientId,
      doctorId: _documents[docIndex].doctorId,
      processingStatus: ProcessingStatus.completed,
      extractedText: ['Sample extracted text', 'Medical terminology detected'],
      metadata: {'confidence': 0.95, 'language': 'en'},
      tags: ['auto-generated', 'processed'],
    );

    _applyFilters();
  }

  // Search and filter methods
  void searchDocuments(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByType(DocumentType? type) {
    _selectedType = type;
    _applyFilters();
  }

  void filterByStatus(ProcessingStatus? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedStatus = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredDocuments = _documents.where((doc) {
      bool matchesSearch = _searchQuery.isEmpty ||
          doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.extractedText.any((text) => 
              text.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          doc.tags.any((tag) => 
              tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      bool matchesType = _selectedType == null || doc.type == _selectedType;
      bool matchesStatus = _selectedStatus == null || doc.processingStatus == _selectedStatus;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    // Sort by upload date (newest first)
    _filteredDocuments.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    notifyListeners();
  }

  // Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      _documents.removeWhere((doc) => doc.id == documentId);
      _applyFilters();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get document statistics
  Map<String, int> getDocumentStats() {
    return {
      'total': _documents.length,
      'pending': _documents.where((d) => d.processingStatus == ProcessingStatus.pending).length,
      'processing': _documents.where((d) => d.processingStatus == ProcessingStatus.processing).length,
      'completed': _documents.where((d) => d.processingStatus == ProcessingStatus.completed).length,
      'failed': _documents.where((d) => d.processingStatus == ProcessingStatus.failed).length,
    };
  }

  // Helper methods
  String _extractDocumentName(String filePath) {
    final fileName = filePath.split('/').last;
    return fileName.replaceAll('_', ' ').replaceAll('.pdf', '');
  }

  DocumentType _inferDocumentType(String filePath) {
    final fileName = filePath.toLowerCase();
    if (fileName.contains('lab') || fileName.contains('blood') || fileName.contains('test')) {
      return DocumentType.labReport;
    } else if (fileName.contains('prescription') || fileName.contains('rx')) {
      return DocumentType.prescription;
    } else if (fileName.contains('xray') || fileName.contains('x-ray')) {
      return DocumentType.xray;
    } else if (fileName.contains('discharge')) {
      return DocumentType.discharge;
    } else if (fileName.contains('consultation')) {
      return DocumentType.consultation;
    } else if (fileName.contains('insurance')) {
      return DocumentType.insurance;
    }
    return DocumentType.general;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Additional methods for search and filtering
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setTypeFilter(DocumentType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(ProcessingStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }
}
