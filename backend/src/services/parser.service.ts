export interface ParsedDocument {
  pan: string | null;
  name: string | null;
  income: number | null;
  dob: string | null;
}

export function parseDocument(rawText: string): ParsedDocument {
  // Normalise whitespace and create an uppercase copy for pattern matching.
  const normalised = rawText.replace(/\s+/g, " ").trim();
  const upper = normalised.toUpperCase();

  return {
    pan: extractPAN(upper),
    name: extractName(normalised),
    income: extractIncome(upper),
    dob: extractDOB(upper),
  };
}

/**
 * PAN format: 5 uppercase letters + 4 digits + 1 uppercase letter.
 * Example: ABCDE1234F
 */
function extractPAN(text: string): string | null {
  return text.match(/\b[A-Z]{5}[0-9]{4}[A-Z]\b/)?.[0] ?? null;
}

/**
 * Name extraction attempts to find a "NAME" or "नाम" label and grabs up to 4 words after it.
 * This preserves original casing where possible.
 */
function extractName(text: string): string | null {
  // Capture 2–4 words following a NAME label, stopping at line breaks or another label.
  const match = text.match(/(?:NAME|नाम)[:\s]+([A-Za-z]+(?:\s+[A-Za-z]+){1,3})(?=\s*(?:$|INCOME|PAN|DOB|NAME|नाम|RS|INR|₹))/i);
  if (!match) return null;

  const name = match[1].trim().replace(/\s+/g, " ");
  if (name.split(" ").length < 2) return null;

  return name;
}

/**
 * Income extraction matches common Indian currency prefixes and parses integers.
 * It ignores values below a noise floor (e.g., < 1000).
 */
function extractIncome(text: string): number | null {
  const match = text.match(/(?:RS\.?|INR|₹)\s*([0-9,]+)/i);
  if (!match) return null;
  const cleaned = match[1].replace(/,/g, "");
  const num = parseInt(cleaned, 10);
  if (Number.isNaN(num) || num < 1000) return null;
  return num;
}

/**
 * DOB extraction supports DD/MM/YYYY or DD-MM-YYYY formats.
 */
function extractDOB(text: string): string | null {
  return text.match(/\b(\d{2}[\/\-]\d{2}[\/\-]\d{4})\b/)?.[1] ?? null;
}
