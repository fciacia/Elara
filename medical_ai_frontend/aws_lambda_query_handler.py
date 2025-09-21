import boto3
import json
import logging
import os
import time
from typing import Dict, List, Any, Optional
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS clients
dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-1')
s3 = boto3.client('s3')
bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')  # Bedrock is available in us-east-1

# Environment variables
DYNAMODB_TABLE = os.environ.get('DYNAMODB_TABLE', 'Elaradocs')
S3_BUCKET = os.environ.get('S3_BUCKET', 'my-medical-docs')
BEDROCK_MODEL_ID = os.environ.get('BEDROCK_MODEL_ID', 'anthropic.claude-3-haiku-20240307-v1:0')

# DynamoDB table
table = dynamodb.Table(DYNAMODB_TABLE)

class MedicalQueryProcessor:
    """Handle medical document queries with AI assistance"""
    
    def __init__(self):
        self.max_context_length = 4000  # Max characters to send to AI model
        self.max_documents = 5  # Max documents to retrieve for context
    
    def get_relevant_documents(self, patient_id: str, question: str) -> List[Dict]:
        """Retrieve relevant documents for the patient"""
        try:
            logger.info(f"Searching documents for patient: {patient_id}")
            
            # Query DynamoDB for patient documents
            if patient_id and patient_id != 'unknown':
                response = table.scan(
                    FilterExpression='patient_id = :pid',
                    ExpressionAttributeValues={':pid': patient_id},
                    Limit=self.max_documents
                )
            else:
                # If no specific patient, get recent documents
                response = table.scan(
                    Limit=self.max_documents
                )
            
            documents = response.get('Items', [])
            logger.info(f"Found {len(documents)} documents")
            
            # Sort by timestamp (most recent first)
            documents.sort(key=lambda x: int(x.get('timestamp', 0)), reverse=True)
            
            return documents[:self.max_documents]
            
        except ClientError as e:
            logger.error(f"Error retrieving documents: {e}")
            return []
    
    def extract_document_content(self, documents: List[Dict]) -> str:
        """Extract and combine content from documents for AI context"""
        context_parts = []
        total_length = 0
        
        for doc in documents:
            doc_info = {
                'filename': doc.get('docsname', 'Unknown'),
                'upload_date': doc.get('timestamp', ''),
                'content_type': doc.get('content_type', ''),
                'file_size': doc.get('file_size', 0)
            }
            
            # For now, we'll include document metadata
            # In a real implementation, you'd extract text content from the S3 files
            doc_summary = f"""
Document: {doc_info['filename']}
Type: {doc_info['content_type']}
Upload Date: {doc_info['upload_date']}
Size: {doc_info['file_size']} bytes
"""
            
            if total_length + len(doc_summary) < self.max_context_length:
                context_parts.append(doc_summary)
                total_length += len(doc_summary)
            else:
                break
        
        return "\n".join(context_parts)
    
    def create_system_prompt(self, user_type: str, language: str) -> str:
        """Create appropriate system prompt based on user type"""
        
        base_prompt = f"""You are a medical AI assistant responding in {language}. 
Your role is to provide helpful, accurate, and appropriate medical information based on the patient's documents."""
        
        if user_type.lower() == 'doctor':
            return base_prompt + """
You are assisting a medical doctor. Provide detailed, technical medical insights.
You can discuss diagnoses, treatment options, medical terminology, and clinical findings.
Be comprehensive and professional in your responses."""
            
        elif user_type.lower() == 'patient':
            return base_prompt + """
You are assisting a patient. Explain medical information in simple, understandable terms.
Avoid complex medical jargon. Be reassuring but honest.
Always recommend consulting with healthcare providers for medical decisions.
Do not provide specific medical advice or diagnoses."""
            
        elif user_type.lower() in ['nurse', 'healthcare_worker']:
            return base_prompt + """
You are assisting a healthcare professional. Provide detailed medical information
with appropriate clinical context. You can discuss medical procedures, patient care,
and clinical observations."""
            
        else:
            return base_prompt + """
Provide general medical information in accessible language.
Always recommend consulting healthcare professionals for medical advice."""
    
    def query_ai_model(self, question: str, context: str, system_prompt: str) -> Dict:
        """Query the AI model (AWS Bedrock Claude) for medical insights"""
        try:
            # Prepare the prompt for Claude
            user_message = f"""
Based on the following patient documents and medical information:

{context}

Please answer this question: {question}

Provide a helpful, accurate response based on the available information.
If the documents don't contain relevant information, please say so.
"""

            # Bedrock Claude request format
            request_body = {
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 1000,
                "system": system_prompt,
                "messages": [
                    {
                        "role": "user",
                        "content": user_message
                    }
                ]
            }
            
            logger.info(f"Querying Bedrock model: {BEDROCK_MODEL_ID}")
            
            response = bedrock.invoke_model(
                modelId=BEDROCK_MODEL_ID,
                body=json.dumps(request_body),
                contentType='application/json'
            )
            
            response_body = json.loads(response['body'].read())
            
            # Extract the answer from Claude's response
            answer = response_body.get('content', [{}])[0].get('text', 'Sorry, I could not generate a response.')
            
            # Determine confidence based on context availability
            confidence = 'HIGH' if len(context.strip()) > 100 else 'MEDIUM' if context.strip() else 'LOW'
            
            return {
                'answer': answer,
                'confidence': confidence,
                'model_used': BEDROCK_MODEL_ID
            }
            
        except Exception as e:
            logger.error(f"Error querying AI model: {e}")
            return {
                'answer': 'I apologize, but I encountered an error while processing your question. Please try again later.',
                'confidence': 'LOW',
                'model_used': 'error'
            }

def lambda_handler(event, context):
    """Main Lambda handler for medical document queries"""
    
    logger.info("=" * 50)
    logger.info("MEDICAL QUERY REQUEST STARTED")
    logger.info("=" * 50)
    logger.info(f"Event: {json.dumps(event, default=str)}")
    
    try:
        # Handle CORS preflight
        if event.get('httpMethod') == 'OPTIONS':
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST, OPTIONS'
                },
                'body': json.dumps({'message': 'CORS preflight'})
            }
        
        # Parse request
        body = event.get('body', '{}')
        if event.get('isBase64Encoded'):
            import base64
            body = base64.b64decode(body).decode('utf-8')
        
        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Invalid JSON in request body'})
            }
        
        # Extract query parameters
        question = data.get('question', '').strip()
        user_type = data.get('user_type', 'patient').lower()
        language = data.get('language', 'en')
        patient_id = data.get('patient_id', 'unknown')
        
        logger.info(f"Query: {question}")
        logger.info(f"User type: {user_type}")
        logger.info(f"Language: {language}")
        logger.info(f"Patient ID: {patient_id}")
        
        # Validate required parameters
        if not question:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Question is required'})
            }
        
        # Initialize query processor
        processor = MedicalQueryProcessor()
        
        # Get relevant documents
        documents = processor.get_relevant_documents(patient_id, question)
        logger.info(f"Retrieved {len(documents)} relevant documents")
        
        # Extract document content for context
        context = processor.extract_document_content(documents)
        logger.info(f"Context length: {len(context)} characters")
        
        # Create appropriate system prompt
        system_prompt = processor.create_system_prompt(user_type, language)
        
        # Query AI model
        ai_response = processor.query_ai_model(question, context, system_prompt)
        
        # Prepare document sources for response
        sources = []
        for doc in documents:
            sources.append({
                'id': doc.get('document_id', ''),
                'title': doc.get('docsname', 'Unknown Document'),
                'type': doc.get('content_type', ''),
                'relevance_score': 0.8,  # You could implement actual relevance scoring
                'excerpt': f"Document uploaded on {doc.get('timestamp', 'unknown date')}",
                'confidence': 'MEDIUM'
            })
        
        # Build complete response
        response_data = {
            'question': question,
            'answer': ai_response['answer'],
            'language': language,
            'user_type': user_type,
            'confidence': ai_response['confidence'],
            'total_documents_found': len(documents),
            'sources': sources,
            'session_id': f"session_{int(time.time())}",
            'timestamp': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
            'model_info': {
                'model_id': ai_response.get('model_used', 'unknown'),
                'context_length': len(context)
            }
        }
        
        logger.info("QUERY PROCESSED SUCCESSFULLY")
        logger.info(f"Response confidence: {ai_response['confidence']}")
        logger.info(f"Documents used: {len(documents)}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Content-Type': 'application/json'
            },
            'body': json.dumps(response_data)
        }
        
    except Exception as e:
        logger.error(f"Unexpected error in query handler: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({
                'error': 'Internal server error',
                'message': 'An error occurred while processing your medical query',
                'details': str(e)
            })
        }
