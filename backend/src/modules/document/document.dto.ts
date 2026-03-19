export type DocType = "PAN" | "AADHAAR" | "SALARY_SLIP" | "BANK_STATEMENT";

export interface UploadDocumentDto {
  type: DocType;
}
