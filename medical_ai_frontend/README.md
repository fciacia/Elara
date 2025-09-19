# Medical AI - Document Query Tool

An AI-powered intelligent medical document query tool designed specifically for Malaysian healthcare professionals and patients. This Flutter web application provides a modern, multilingual interface for processing and querying medical PDF documents using advanced AI capabilities.

## 🎯 Project Overview

This is a **non-functional frontend prototype** showcasing the UI/UX design for an AI-powered medical document query system. The application demonstrates modern healthcare application design patterns and user experience flows.

### Problem Statement

Healthcare professionals in Malaysia struggle to efficiently access critical information from vast, unstructured medical PDFs. Manual searches are time-consuming, error-prone, and limit clinical insights, impacting patient care. Our proposed AI query tool enables natural language smart search across all medical PDF documents via an intuitive chat-like interface.

## ✨ Key Features Demonstrated

### 1. 🤖 **Multimodal Medical Copilot**
- Handle charts, tables, handwriting, and medical images
- Comprehensive document processing pipeline
- Visual content extraction and analysis

### 2. 👥 **Role-Specific Views**
- **Patient View**: Plain English, safety-focused simplifications
- **Doctor View**: Clinical depth, drug interactions, medical correlations
- **Admin View**: Billing codes, compliance, documentation completeness

### 3. 🌏 **Cross-Language Medical Bridge**
- Support for English, Bahasa Melayu, Mandarin, and Tamil
- Cultural and linguistic adaptation for Malaysian healthcare
- Real-time translation capabilities

### 4. ⚠️ **Proactive Medical Intelligence**
- AI-driven risk detection and alerts
- Dosage validation and prescription consistency checks
- Compliance monitoring and documentation verification

### 5. 📈 **Patient Journey Knowledge Graph**
- Timeline construction of patient medical history
- Relationship mapping between diagnoses, treatments, and outcomes
- Progression tracking and predictive insights

### 6. 🔒 **Privacy-First Medical AI**
- Automatic de-identification of sensitive information
- HIPAA/Malaysian privacy law compliance
- Secure document processing and storage

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Chrome browser (for web development)

### Quick Start

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the application**
   ```bash
   flutter run -d chrome --web-port=8080
   ```

3. **Access the application**
   Open your browser: `http://localhost:8080`

### Demo Accounts

| Email | Role | Password |
|-------|------|----------|
| `sarah.ahmad@hospital.my` | Doctor | Any password |
| `ahmad.ali@email.com` | Patient | Any password |
| `admin@hospital.my` | Admin | Any password |

## 🎨 Features Overview

- **Multilingual Interface**: English, Bahasa Melayu, Mandarin, Tamil
- **Role-Based Dashboards**: Different views for patients, doctors, and administrators
- **AI Chat Interface**: Gemini-like chat for document queries
- **Document Management**: Upload and process medical PDFs
- **Analytics Dashboard**: Insights and trends visualization
- **Responsive Design**: Works on desktop, tablet, and mobile

## 🔧 Technical Stack

- **Framework**: Flutter Web
- **State Management**: Provider + GetX
- **UI**: Material Design 3
- **Charts**: FL Chart
- **Fonts**: Google Fonts (Inter)

## 📱 Supported Languages

- 🇺🇸 English (Default)
- 🇲🇾 Bahasa Melayu
- 🇨🇳 中文 (Mandarin)
- 🇮🇳 தமிழ் (Tamil)

## 🔮 Future Integration

This frontend is designed to integrate with:
- AWS Textract (PDF processing)
- AWS Bedrock (AI/LLM)
- AWS Rekognition (Medical imaging)
- AWS Comprehend Medical (Entity extraction)

**Made for Malaysian Healthcare** 🇲🇾
