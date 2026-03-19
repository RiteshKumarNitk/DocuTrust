import { Worker, Job } from "bullmq";
import { Prisma } from "@prisma/client";
import { prisma } from "../prisma/client";
import { ocrService } from "../services/ocr.service";
import { parseDocument } from "../services/parser.service";
import { validate } from "../services/validation.service";
import { calculateScore } from "../services/scoring.service";
import { REDIS_HOST, REDIS_PORT } from "../config";

interface JobData {
  documentId: string;
}

const worker = new Worker<JobData>(
  "document-processing",
  async (job: Job<JobData>) => {
    const { documentId } = job.data;

    const doc = await prisma.document.findUnique({
      where: { id: documentId },
    });

    if (!doc) {
      throw new Error(`Document not found: ${documentId}`);
    }

    await prisma.document.update({
      where: { id: documentId },
      data: { status: "PROCESSING" },
    });

    const text = await ocrService(doc.fileUrl);
    const parsed = parseDocument(text);
    const validation = validate(parsed);
    const score = calculateScore(validation);

    await prisma.document.update({
      where: { id: documentId },
      data: {
        extracted: parsed as any,
        score,
        result: score >= 70 ? "APPROVED" : "REJECTED",
        status: "DONE",
      },
    });
  },
  {
    connection: {
      host: REDIS_HOST,
      port: REDIS_PORT,
    },
    concurrency: 5,
  },
);

worker.on("failed", async (job, err) => {
  if (!job?.data?.documentId) return;
  await prisma.document.update({
    where: { id: job.data.documentId },
    data: { status: "FAILED", errorMsg: err.message },
  });
  // eslint-disable-next-line no-console
  console.error(`Job failed for document ${job.data.documentId} (attempt ${job.attemptsMade + 1}):`, err);
});

// Keep the worker running when invoked directly
if (process.argv[1]?.endsWith("worker.ts") || process.argv[1]?.endsWith("worker.js")) {
  // no-op; worker starts on import
}

export default worker;
