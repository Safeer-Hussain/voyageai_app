import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  Directory('assets/icons').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);

  // Generate app icon 512x512
  File('assets/icons/app_icon.png').writeAsBytesSync(
    generateEmblemPng(
      width: 512,
      height: 512,
      bgR: 13,
      bgG: 18,
      bgB: 28,
      accentR: 16,
      accentG: 185,
      accentB: 129,
      goldR: 245,
      goldG: 158,
      goldB: 11,
      isIcon: true,
    ),
  );

  final destinations = [
    {
      'name': 'karakoram_hunza.png',
      'r1': 15,
      'g1': 23,
      'b1': 42,
      'r2': 16,
      'g2': 185,
      'b2': 129,
    },
    {
      'name': 'kyoto_old_town.png',
      'r1': 30,
      'g1': 20,
      'b1': 40,
      'r2': 239,
      'g2': 68,
      'b2': 68,
    },
    {
      'name': 'swiss_interlaken.png',
      'r1': 14,
      'g1': 35,
      'b1': 60,
      'r2': 56,
      'g2': 189,
      'b2': 248,
    },
    {
      'name': 'istanbul_bosphorus.png',
      'r1': 35,
      'g1': 24,
      'b1': 16,
      'r2': 245,
      'g2': 158,
      'b2': 11,
    },
    {
      'name': 'tokyo_shibuya.png',
      'r1': 20,
      'g1': 14,
      'b1': 38,
      'r2': 168,
      'g2': 85,
      'b2': 247,
    },
    {
      'name': 'airline_badge.png',
      'r1': 15,
      'g1': 23,
      'b1': 42,
      'r2': 245,
      'g2': 158,
      'b2': 11,
    },
    {
      'name': 'document_seal.png',
      'r1': 18,
      'g1': 28,
      'b1': 45,
      'r2': 16,
      'g2': 185,
      'b2': 129,
    },
  ];

  for (final dest in destinations) {
    File('assets/images/${dest['name']}').writeAsBytesSync(
      generateEmblemPng(
        width: 600,
        height: 380,
        bgR: dest['r1'] as int,
        bgG: dest['g1'] as int,
        bgB: dest['b1'] as int,
        accentR: dest['r2'] as int,
        accentG: dest['g2'] as int,
        accentB: dest['b2'] as int,
        goldR: 250,
        goldG: 204,
        goldB: 21,
        isIcon: false,
      ),
    );
  }

  // Also copy app_icon to android mipmap ic_launcher.png
  final mipmaps = [
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
  ];
  final iconBytes = File('assets/icons/app_icon.png').readAsBytesSync();
  for (final mipmap in mipmaps) {
    final file = File(mipmap);
    if (file.existsSync()) {
      file.writeAsBytesSync(iconBytes);
    }
  }
}

Uint8List generateEmblemPng({
  required int width,
  required int height,
  required int bgR,
  required int bgG,
  required int bgB,
  required int accentR,
  required int accentG,
  required int accentB,
  required int goldR,
  required int goldG,
  required int goldB,
  required bool isIcon,
}) {
  final rawData = Uint8List(height * (1 + width * 4));
  int offset = 0;
  final centerX = width / 2.0;
  final centerY = height / 2.0;
  final maxRadius = min(width, height) * 0.42;

  for (int y = 0; y < height; y++) {
    rawData[offset++] = 0; // Filter byte: None
    final ny = y / height;

    for (int x = 0; x < width; x++) {
      final nx = x / width;
      final dx = x - centerX;
      final dy = y - centerY;
      final dist = sqrt(dx * dx + dy * dy);

      // Base gradient
      double r = bgR + (accentR - bgR) * (nx * 0.3 + ny * 0.7);
      double g = bgG + (accentG - bgG) * (nx * 0.3 + ny * 0.7);
      double b = bgB + (accentB - bgB) * (nx * 0.3 + ny * 0.7);

      // Celestial / orbital ring
      final ringDist = (dist - maxRadius * 0.75).abs();
      if (ringDist < 2.5) {
        final alpha = 1.0 - (ringDist / 2.5);
        r = r * (1 - alpha) + goldR * alpha;
        g = g * (1 - alpha) + goldG * alpha;
        b = b * (1 - alpha) + goldB * alpha;
      }

      // Orbital flight arc (ellipse)
      final ellipseDist = ((dx * 1.3 + dy * 0.7).abs() - maxRadius * 0.85)
          .abs();
      if (ellipseDist < 2.0 && dist < maxRadius * 1.1) {
        final alpha = 1.0 - (ellipseDist / 2.0);
        r = r * (1 - alpha) + 255 * alpha;
        g = g * (1 - alpha) + 255 * alpha;
        b = b * (1 - alpha) + 255 * alpha;
      }

      // Compass rose 4-point star in center
      final angle = atan2(dy, dx);
      final starRadius = (cos(4 * angle).abs() * 0.6 + 0.4) * (maxRadius * 0.4);
      if (dist < starRadius) {
        final factor = (1.0 - dist / starRadius);
        r = r * (1 - factor) + (isIcon ? goldR : accentR) * factor;
        g = g * (1 - factor) + (isIcon ? goldG : accentG) * factor;
        b = b * (1 - factor) + (isIcon ? goldB : accentB) * factor;
      }

      // Vignette effect towards borders
      final borderDist =
          min(min(x, width - x), min(y, height - y)) / (width * 0.15);
      final vignette = borderDist.clamp(0.0, 1.0);
      r *= vignette;
      g *= vignette;
      b *= vignette;

      rawData[offset++] = r.round().clamp(0, 255);
      rawData[offset++] = g.round().clamp(0, 255);
      rawData[offset++] = b.round().clamp(0, 255);
      rawData[offset++] = 255; // Alpha
    }
  }

  return encodePng(width, height, rawData);
}

Uint8List encodePng(int width, int height, Uint8List rawData) {
  final compressed = zlib.encode(rawData);
  final buffer = BytesBuilder();

  // PNG Signature
  buffer.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR chunk
  final ihdrData = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // Bit depth: 8
    ..setUint8(9, 6) // Color type: RGBA (6)
    ..setUint8(10, 0) // Compression: deflate
    ..setUint8(11, 0) // Filter: basic
    ..setUint8(12, 0); // Interlace: none
  writeChunk(buffer, 'IHDR', ihdrData.buffer.asUint8List());

  // IDAT chunk
  writeChunk(buffer, 'IDAT', Uint8List.fromList(compressed));

  // IEND chunk
  writeChunk(buffer, 'IEND', Uint8List(0));

  return buffer.toBytes();
}

void writeChunk(BytesBuilder buffer, String type, Uint8List data) {
  final length = data.length;
  final lengthBytes = ByteData(4)..setUint32(0, length);
  buffer.add(lengthBytes.buffer.asUint8List());

  final typeBytes = Uint8List.fromList(type.codeUnits);
  buffer.add(typeBytes);

  if (data.isNotEmpty) {
    buffer.add(data);
  }

  // Calculate CRC-32 over chunk type and chunk data
  final crc = calculateCrc32(typeBytes, data);
  final crcBytes = ByteData(4)..setUint32(0, crc);
  buffer.add(crcBytes.buffer.asUint8List());
}

int calculateCrc32(Uint8List type, Uint8List data) {
  int crc = 0xffffffff;
  void update(int byte) {
    crc ^= byte;
    for (int k = 0; k < 8; k++) {
      if ((crc & 1) != 0) {
        crc = (crc >>> 1) ^ 0xedb88320;
      } else {
        crc = crc >>> 1;
      }
    }
  }

  for (final b in type) {
    update(b);
  }
  for (final b in data) {
    update(b);
  }
  return ~crc & 0xffffffff;
}
