# DocuTrust (Document Verification MVP)

This repository contains a full-stack MVP for document verification using OCR, parsing, and validation.

## Prerequisites

- Node.js (v16 or higher)
- Flutter SDK
- Docker (for Redis)
- SQLite (comes with Node.js)

## Backend Setup

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up the database:
   ```
   npx prisma generate
   npx prisma migrate dev --name init
   ```

4. Start Redis (in a separate terminal):
   ```
   docker run -d -p 6379:6379 redis
   ```

5. Start the backend server (in one terminal):
   ```
   npm run dev
   ```

6. Start the worker (in another terminal):
   ```
   npm run worker
   ```

The backend will run on `http://localhost:3000`.

## Flutter App Setup

1. Navigate to the Flutter app directory:
   ```
   cd flutter_app
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

## Usage

1. Open the Flutter app.
2. Select a document type (PAN, AADHAAR, etc.).
3. Choose and upload a document image.
4. Wait for processing (5-10 seconds).
5. View the verification score and extracted data.

## API Endpoints

- `POST /api/document/upload` - Upload a document
- `GET /api/document/:id` - Get document result

## Notes

- Authentication is disabled for demo purposes.
- Files are stored locally; Cloudinary is configured but may fail.
- Database uses SQLite for simplicity.
- Redis is required for job queuing.
