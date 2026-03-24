import fs from "fs";
import path from "path";
import multer from "multer";
import { Router } from "express";
import { success, fail } from "../../utils/response.util";
import { requireAuth, AuthRequest } from "../auth/auth.middleware";
import { createDocument, getDocumentById, listDocuments } from "./document.service";
import type { DocType } from "./document.dto";
import { CLOUDINARY_ENABLED, UPLOAD_DEST } from "../../config";
import { uploadToCloudinary } from "../../services/cloudinary.service";

const storage = multer.diskStorage({
  destination: UPLOAD_DEST,
  filename: (_req, file, cb) => {
    // Keep original filename prefixed with timestamp to avoid collisions
    const safe = `${Date.now()}-${file.originalname}`.replace(/\s+/g, "_");
    cb(null, safe);
  },
});

const upload = multer({ storage });

export const documentRouter = Router();

documentRouter.post(
  "/upload",
  upload.single("file"),
  async (req: AuthRequest, res) => {
    try {
      const file = req.file;
      const type = (req.body.type as DocType) ?? null;
      if (!file) {
        return fail(res, "Missing file", 400);
      }
      if (!type || !["PAN", "AADHAAR", "SALARY_SLIP", "BANK_STATEMENT"].includes(type)) {
        return fail(res, "Missing or invalid document type", 400);
      }

      // Default to local disk storage; if Cloudinary is configured we'll upload there
      let fileUrl = file.path;
      let uploadedToCloudinary = false;

      if (CLOUDINARY_ENABLED) {
        try {
          fileUrl = await uploadToCloudinary(file.path);
          uploadedToCloudinary = true;
        } catch (err) {
          // If Cloudinary upload fails, continue using the local file so processing can still work.
          // eslint-disable-next-line no-console
          console.warn("Cloudinary upload failed; falling back to local file storage", err);
        }
      }

      if (uploadedToCloudinary) {
        // Clean up the local copy if uploaded to Cloudinary
        await fs.promises.unlink(file.path).catch(() => {
          // ignore errors while deleting temporary upload
        });
      }

      const doc = await createDocument(req.user?.id ?? "demo-user", fileUrl, type);
      return success(res, {
        id: doc.id,
        status: doc.status,
        message: "Document queued for processing",
      });
    } catch (error) {
      return fail(res, error);
    }
  },
);

documentRouter.get("/:id", async (req: AuthRequest, res) => {
  try {
    const doc = await getDocumentById(req.user?.id ?? "demo-user", req.params.id);
    if (!doc) {
      return fail(res, "Document not found", 404);
    }
    return success(res, doc);
  } catch (error) {
    return fail(res, error);
  }
});

documentRouter.get("/list", async (req: AuthRequest, res) => {
  try {
    const docs = await listDocuments(req.user?.id ?? "demo-user");
    return success(res, docs);
  } catch (error) {
    return fail(res, error);
  }
});
