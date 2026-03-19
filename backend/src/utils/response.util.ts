import { Response } from "express";

export function success<T = unknown>(res: Response, data: T, statusCode = 200) {
  return res.status(statusCode).json({ success: true, data });
}

export function fail(res: Response, error: string | unknown, statusCode = 500) {
  const message = typeof error === "string" ? error : (error as Error).message ?? "Unexpected error";
  return res.status(statusCode).json({ success: false, error: message });
}
