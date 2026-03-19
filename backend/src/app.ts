import express, { NextFunction, Request, Response } from "express";
import cors from "cors";
import morgan from "morgan";
import { PORT, NODE_ENV } from "./config";
import { authRouter } from "./modules/auth/auth.controller";
import { documentRouter } from "./modules/document/document.controller";
import { ApiError } from "./utils/error.util";

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (NODE_ENV !== "production") {
  app.use(morgan("dev"));
}

app.use("/api/auth", authRouter);
app.use("/api/document", documentRouter);

app.get("/health", (_req, res) => res.send("ok"));

// Global error handler
app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({ success: false, error: err.message });
  }

  console.error(err);
  return res.status(500).json({ success: false, error: "Internal server error" });
});

if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

export default app;
