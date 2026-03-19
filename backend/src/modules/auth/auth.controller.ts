import { Router } from "express";
import { fail, success } from "../../utils/response.util";
import { loginUser, registerUser } from "./auth.service";

export const authRouter = Router();

authRouter.post("/register", async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await registerUser({ email, password });
    return success(res, result, 201);
  } catch (error) {
    return fail(res, error);
  }
});

authRouter.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await loginUser({ email, password });
    return success(res, result);
  } catch (error) {
    return fail(res, error);
  }
});
