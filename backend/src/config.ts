import dotenv from "dotenv";

dotenv.config();

function requiredEnv(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export const PORT = Number(process.env.PORT ?? 3000);
export const NODE_ENV = process.env.NODE_ENV ?? "development";

export const DATABASE_URL = requiredEnv("DATABASE_URL");
export const JWT_SECRET = requiredEnv("JWT_SECRET");
export const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN ?? "7d";

export const REDIS_HOST = process.env.REDIS_HOST ?? "localhost";
export const REDIS_PORT = Number(process.env.REDIS_PORT ?? 6379);

export const UPLOAD_DEST = process.env.UPLOAD_DEST ?? "./uploads";

export const CLOUDINARY_CLOUD_NAME = process.env.CLOUDINARY_CLOUD_NAME;
export const CLOUDINARY_API_KEY = process.env.CLOUDINARY_API_KEY;
export const CLOUDINARY_API_SECRET = process.env.CLOUDINARY_API_SECRET;
export const CLOUDINARY_ENABLED = Boolean(
  CLOUDINARY_CLOUD_NAME && CLOUDINARY_API_KEY && CLOUDINARY_API_SECRET,
);
