import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/home_content_model.dart';

class HomeService {
  Future<List<HomeContent>> getFeaturedContent() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/home/featured'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> contentsJson = data['data'];
      return contentsJson
          .map((json) => HomeContent.fromJson(json))
          .toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取首页置顶内容失败');
    }
  }

  Future<List<RecommendedPlayer>> getRecommendedPlayers({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/home/recommended-players?limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> playersJson = data['data'];
      return playersJson
          .map((json) => RecommendedPlayer.fromJson(json))
          .toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取推荐陪玩人员失败');
    }
  }

  Future<List<HotPost>> getHotPosts({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/home/hot-posts?limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> postsJson = data['data'];
      return postsJson
          .map((json) => HotPost.fromJson(json))
          .toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取热门动态失败');
    }
  }
}