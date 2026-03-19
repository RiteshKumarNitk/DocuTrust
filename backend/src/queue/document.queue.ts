import { Queue } from "bullmq";
import { REDIS_HOST, REDIS_PORT } from "../config";

export const documentQueue = new Queue("document-processing", {
  connection: {
    host: REDIS_HOST,
    port: REDIS_PORT,
  },
  defaultJobOptions: {
    attempts: 3,
    backoff: { type: "exponential", delay: 2000 },
    removeOnComplete: { count: 100 },
    removeOnFail: { count: 50 },
  },
});

export async function enqueueDocument(documentId: string): Promise<void> {
  await documentQueue.add("process", { documentId });
}
