# DocuTrust Backend (Document Verification MVP)

This repository contains a Node.js + TypeScript backend for a document verification MVP.

## Features

- User authentication (register/login) with JWT
- File upload endpoint (multer disk storage)
- BullMQ queue for asynchronous document processing
- OCR (Tesseract.js) + field parsing + validation + scoring
- PostgreSQL database via Prisma

## Getting started

1. Copy the `.env.example` to `.env` and fill in values.
2. Install dependencies:

```bash
npm install
```

3. Generate Prisma client and run migrations:

```bash
npm run prisma:generate
npm run prisma:migrate
```

4. Start the API server:

```bash
npm run dev
```

5. Start the background worker in a separate terminal:

```bash
npx ts-node-dev src/queue/worker.ts
```

## API Endpoints

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/document/upload`
- `GET /api/document/:id`
- `GET /api/document/list`

## Testing

```bash
npm test
```
