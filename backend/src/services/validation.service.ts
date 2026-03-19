import { ParsedDocument } from "./parser.service";

export interface ValidationResult {
  panValid: boolean;
  nameExists: boolean;
  incomeValid: boolean;
  dobExists: boolean;
}

export function validate(data: ParsedDocument): ValidationResult {
  return {
    panValid: isPANValid(data.pan),
    nameExists: isNameValid(data.name),
    incomeValid: isIncomeValid(data.income),
    dobExists: !!data.dob,
  };
}

function isPANValid(pan: string | null): boolean {
  if (!pan) return false;

  const cleaned = pan.trim().toUpperCase();
  if (!/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(cleaned)) return false;

  // Validate checksum character (10th character) per PAN algorithm
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const nums = "0123456789";
  const base = [...cleaned.slice(0, 9)];

  let total = 0;
  for (let i = 0; i < base.length; i++) {
    const ch = base[i];
    if (/[0-9]/.test(ch)) {
      total += Number(ch) * (i + 1);
    } else {
      total += (chars.indexOf(ch) + 1) * (i + 1);
    }
  }

  const checkIndex = total % 26;
  const expected = chars[checkIndex];
  return cleaned[9] === expected;
}

function isNameValid(name: string | null): boolean {
  if (!name) return false;
  return name.trim().split(/\s+/).length >= 2;
}

function isIncomeValid(income: number | null): boolean {
  return income !== null && income >= 10000;
}
