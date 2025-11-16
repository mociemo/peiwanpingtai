import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/share_model.dart';

class ShareService {
  Future<ShareResponse> generateShareLink(
    String token,
    ShareRequest shareRequest,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/share/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(shareRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ShareResponse.fromJson(data['data']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '生成分享链接失败');
    }
  }

  Future<Map<String, dynamic>> getSharedContent(String shareId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/share/$shareId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取分享内容失败');
    }
  }

  Future<void> recordShareAction(
    String token,
    ShareRequest shareRequest,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/share/record'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(shareRequest.toJson()),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '记录分享行为失败');
    }
  }

  Future<ShareStats> getShareStats(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/share/stats/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ShareStats.fromJson(data['data']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取分享统计失败');
    }
  }
}