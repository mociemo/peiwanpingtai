import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/rating_model.dart';

class RatingService {
  Future<RatingResponse> createRating(
    String token,
    RatingRequest ratingRequest,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/ratings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(ratingRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RatingResponse.fromJson(data['data']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '创建评价失败');
    }
  }

  Future<List<RatingResponse>> getUserRatings(
    String userId, {
    int page = 0,
    int size = 10,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/ratings/user/$userId?page=$page&size=$size',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> ratingsJson = data['data'];
      return ratingsJson.map((json) => RatingResponse.fromJson(json)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取用户评价失败');
    }
  }

  Future<double> getPlayerAverageRating(String playerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ratings/average/$playerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as num).toDouble();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取平均评分失败');
    }
  }

  Future<RatingStats> getPlayerRatingStats(String playerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ratings/stats/$playerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RatingStats.fromJson(data['data']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取评分统计失败');
    }
  }
}
