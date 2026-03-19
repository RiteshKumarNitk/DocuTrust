import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { prisma } from "../../prisma/client";
import { JWT_EXPIRES_IN, JWT_SECRET } from "../../config";
import { ApiError } from "../../utils/error.util";
import type { LoginDto, RegisterDto } from "./auth.dto";

export interface AuthPayload {
  id: string;
  email: string;
}

export async function registerUser(payload: RegisterDto) {
  const existing = await prisma.user.findUnique({ where: { email: payload.email } });
  if (existing) {
    throw new ApiError("Email already in use", 409);
  }

  const hashed = await bcrypt.hash(payload.password, 12);
  const user = await prisma.user.create({
    data: { email: payload.email, password: hashed },
  });

  return {
    id: user.id,
    email: user.email,
    token: signToken({ id: user.id, email: user.email }),
  };
}

export async function loginUser(payload: LoginDto) {
  const user = await prisma.user.findUnique({ where: { email: payload.email } });
  if (!user) {
    throw new ApiError("Invalid credentials", 401);
  }

  const match = await bcrypt.compare(payload.password, user.password);
  if (!match) {
    throw new ApiError("Invalid credentials", 401);
  }

  return {
    id: user.id,
    email: user.email,
    token: signToken({ id: user.id, email: user.email }),
  };
}

function signToken(payload: AuthPayload) {
  // JWT_SECRET is required and should always be a string.
  // Use casts to satisfy TypeScript in case the JWT library types are strict.
  return jwt.sign(payload, JWT_SECRET as any, {
    expiresIn: JWT_EXPIRES_IN as any,
  });
}
