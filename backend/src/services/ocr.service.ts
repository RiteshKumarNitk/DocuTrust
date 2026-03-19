import Tesseract from "tesseract.js";

export async function ocrService(fileUrl: string): Promise<string> {
  const result = await Tesseract.recognize(fileUrl, "eng", {
    logger: () => {}, // suppress progress logs in production
  });
  return result.data.text;
}

// Later upgrade: replace with Google Cloud Vision for significantly better accuracy
// on real-world document photos (skewed, low-light, compressed JPEG)
//
// import vision from "@google-cloud/vision";
// const client = new vision.ImageAnnotatorClient();
// const [result] = await client.textDetection(fileUrl);
// return result.fullTextAnnotation?.text ?? "";
