import 'dart:convert';

void decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    print('Invalid token format');
    return;
  }

  final header = _decodeBase64(parts[0]);
  final payload = _decodeBase64(parts[1]);

  print('Header: $header');
  print('Payload: $payload');
}

String _decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');
  while (output.length % 4 != 0) {
    output += '=';
  }
  return utf8.decode(base64Url.decode(output));
}

// Map<String, dynamic> parseJwtPayLoad(String token) {
//   final parts = token.split('.');
//   if (parts.length != 3) {
//     throw Exception('invalid token');
//   }

//   final payload = _decodeBase64(parts[1]);
//   final payloadMap = json.decode(payload);
//   if (payloadMap is! Map<String, dynamic>) {
//     throw Exception('invalid payload');
//   }

//   return payloadMap;
// }

// Map<String, dynamic> parseJwtHeader(String token) {
//   final parts = token.split('.');
//   if (parts.length != 3) {
//     throw Exception('invalid token');
//   }

//   final payload = _decodeBase64(parts[0]);
//   final payloadMap = json.decode(payload);
//   if (payloadMap is! Map<String, dynamic>) {
//     throw Exception('invalid payload');
//   }

//   return payloadMap;
// }

// String _decodeBase64(String str) {
//   String output = str.replaceAll('-', '+').replaceAll('_', '/');

//   switch (output.length % 4) {
//     case 0:
//       break;
//     case 2:
//       output += '==';
//       break;
//     case 3:
//       output += '=';
//       break;
//     default:
//       throw Exception('Illegal base64url string!"');
//   }

//   return utf8.decode(base64Url.decode(output));
// }
