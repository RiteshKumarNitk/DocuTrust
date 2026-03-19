import fs from "fs";
import path from "path";
import { prisma } from "../../prisma/client";
import { UPLOAD_DEST } from "../../config";
import { enqueueDocument } from "../../queue/document.queue";
import type { DocType } from "./document.dto";

export interface DocumentRecord {
  id: string;
  userId: string;
  fileUrl: string;
  type: DocType;
  status: string;
  score?: number | null;
  result?: string | null;
  extracted?: unknown | null;
  errorMsg?: string | null;
}

export async function createDocument(
  userId: string,
  fileUrl: string,
  type: DocType,
): Promise<DocumentRecord> {
  // If we're storing uploads on disk, ensure the upload directory exists.
  if (!fileUrl.startsWith("http")) {
    await ensureUploadDir();
  }

  const doc = await prisma.document.create({
    data: {
      userId,
      fileUrl,
      type,
      status: "PENDING",
    },
  });

  // Enqueue job (fire-and-forget) so API can respond fast.
  enqueueDocument(doc.id).catch((err) => {
    // eslint-disable-next-line no-console
    console.error("Failed to enqueue document job", err);
  });

  return doc;
}

export async function getDocumentById(userId: string, documentId: string) {
  return prisma.document.findFirst({
    where: { id: documentId, userId },
  });
}

export async function listDocuments(userId: string) {
  return prisma.document.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
  });
}

async function ensureUploadDir() {
  try {
    await fs.promises.mkdir(UPLOAD_DEST, { recursive: true });
  } catch {
    // ignore
  }
}
