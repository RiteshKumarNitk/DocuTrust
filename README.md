# DocuTrust (Document Verification MVP)

This repository contains a full-stack MVP for document verification.

## Backend
Located in `backend/` (Node.js + Express + TypeScript)

- Uses PostgreSQL via Prisma
- Queues document processing jobs with BullMQ + Redis
- OCR via Tesseract.js
- Parses PAN, name, income, DOB
- Validates and scores documents

## Flutter App
Located in `flutter_app/` (Dart + Flutter)

- Uploads document images to the backend
- Polls for processing results
- Shows score and extracted fields
