import { parseDocument } from "./parser.service";

describe("parseDocument", () => {
  it("extracts PAN, name, income, and dob from clean text", () => {
    const text = "PAN: ABCDE1234F\nName: Rahul Sharma\nIncome: INR 45,000\nDOB: 01/01/1990";
    const result = parseDocument(text);
    expect(result.pan).toBe("ABCDE1234F");
    expect(result.name).toBe("Rahul Sharma");
    expect(result.income).toBe(45000);
    expect(result.dob).toBe("01/01/1990");
  });

  it("extracts fields from noisy OCR output", () => {
    const text = "\n\nPAN ABCDE1234F  some other text\nNAME:   Rahul   Sharma\nRs. 12,345\nDOB - 02-02-1992\n";
    const result = parseDocument(text);
    expect(result.pan).toBe("ABCDE1234F");
    expect(result.name).toBe("Rahul Sharma");
    expect(result.income).toBe(12345);
    expect(result.dob).toBe("02-02-1992");
  });

  it("returns null for missing PAN", () => {
    const text = "Name: Foo Bar\nINR 9999\nDOB: 03/03/1993";
    const result = parseDocument(text);
    expect(result.pan).toBeNull();
  });

  it("ignores income values below noise threshold", () => {
    const text = "Income: Rs. 999\nPAN: ABCDE1234F";
    const result = parseDocument(text);
    expect(result.income).toBeNull();
  });

  it("parses name when labeled in Hindi", () => {
    const text = "नाम: Ravi Kumar\nPAN: ABCDE1234F";
    const result = parseDocument(text);
    expect(result.name).toBe("Ravi Kumar");
  });
});
