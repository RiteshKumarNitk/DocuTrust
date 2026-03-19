// A small stub to allow code that references `File` to compile on web.
// This class is never used on web; web code should use `Image.memory` / `Image.network` instead.

class File {
  File(String path);
}
