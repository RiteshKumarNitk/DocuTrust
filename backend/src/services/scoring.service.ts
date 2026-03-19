import type { ValidationResult } from "./validation.service";

export interface ScoreBreakdownItem {
  label: string;
  weight: number;
  passed: boolean;
  points: number;
}

export interface ScoringWeights {
  panValid: number;
  nameExists: number;
  incomeValid: number;
  dobExists: number;
}

export const WEIGHTS: ScoringWeights = {
  panValid: 40,
  incomeValid: 30,
  nameExists: 20,
  dobExists: 10,
};

export function calculateScore(validation: ValidationResult): number {
  let score = 0;
  if (validation.panValid) score += WEIGHTS.panValid;
  if (validation.incomeValid) score += WEIGHTS.incomeValid;
  if (validation.nameExists) score += WEIGHTS.nameExists;
  if (validation.dobExists) score += WEIGHTS.dobExists;
  return score;
}

export function getScoreBreakdown(validation: ValidationResult): ScoreBreakdownItem[] {
  return [
    {
      label: "PAN valid",
      weight: WEIGHTS.panValid,
      passed: validation.panValid,
      points: validation.panValid ? WEIGHTS.panValid : 0,
    },
    {
      label: "Income valid",
      weight: WEIGHTS.incomeValid,
      passed: validation.incomeValid,
      points: validation.incomeValid ? WEIGHTS.incomeValid : 0,
    },
    {
      label: "Name exists",
      weight: WEIGHTS.nameExists,
      passed: validation.nameExists,
      points: validation.nameExists ? WEIGHTS.nameExists : 0,
    },
    {
      label: "DOB exists",
      weight: WEIGHTS.dobExists,
      passed: validation.dobExists,
      points: validation.dobExists ? WEIGHTS.dobExists : 0,
    },
  ];
}
