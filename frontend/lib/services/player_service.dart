import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/player_model.dart';

class PlayerService {
  static final Dio _dio = ApiService.dio;

  /// 获取玩家详情
  static Future<Player> getPlayerById(String id) async {
    try {
      final response = await _dio.get('/players/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Player.fromJson(data['data']);
        }
      }
      throw Exception('获取玩家详情失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取玩家详情失败: $e');
    }
  }

  /// 根据用户ID获取玩家信息
  static Future<Player> getPlayerByUserId(String userId) async {
    try {
      final response = await _dio.get('/players/user/$userId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Player.fromJson(data['data']);
        }
      }
      throw Exception('获取玩家信息失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取玩家信息失败: $e');
    }
  }

  /// 创建玩家档案
  static Future<Player> createPlayerProfile({
    required String userId,
    String? realName,
    String? idCard,
    required List<String> skillTags,
    required double servicePrice,
    String? introduction,
    Map<String, dynamic>? availableTime,
  }) async {
    try {
      final response = await _dio.post('/players', data: {
        'userId': userId,
        'realName': realName,
        'idCard': idCard,
        'skillTags': skillTags,
        'servicePrice': servicePrice,
        'introduction': introduction,
        'availableTime': availableTime,
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Player.fromJson(data['data']);
        }
      }
      throw Exception('创建玩家档案失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('创建玩家档案失败: $e');
    }
  }

  /// 更新玩家档案
  static Future<Player> updatePlayerProfile(
    String id, {
    String? realName,
    String? idCard,
    List<String>? skillTags,
    double? servicePrice,
    String? introduction,
    Map<String, dynamic>? availableTime,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (realName != null) data['realName'] = realName;
      if (idCard != null) data['idCard'] = idCard;
      if (skillTags != null) data['skillTags'] = skillTags;
      if (servicePrice != null) data['servicePrice'] = servicePrice;
      if (introduction != null) data['introduction'] = introduction;
      if (availableTime != null) data['availableTime'] = availableTime;

      final response = await _dio.put('/players/$id', data: data);
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return Player.fromJson(responseData['data']);
        }
      }
      throw Exception('更新玩家档案失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('更新玩家档案失败: $e');
    }
  }

  /// 搜索玩家
  static Future<List<Player>> searchPlayers({
    String? keyword,
    List<String>? skillTags,
    double? minPrice,
    double? maxPrice,
    CertificationStatus? certificationStatus,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      if (keyword != null) queryParams['keyword'] = keyword;
      if (skillTags != null) queryParams['skillTags'] = skillTags.join(',');
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (certificationStatus != null) {
        queryParams['certificationStatus'] = certificationStatus.name;
      }

      final response = await _dio.get(
        '/players/search',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> playersJson = data['data'];
          return playersJson
              .map((json) => Player.fromJson(json))
              .toList();
        }
      }
      throw Exception('搜索玩家失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('搜索玩家失败: $e');
    }
  }

  /// 获取推荐玩家
  static Future<List<Player>> getRecommendedPlayers({
    int limit = 10,
    String? gameCategory,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'limit': limit};
      if (gameCategory != null) queryParams['gameCategory'] = gameCategory;

      final response = await _dio.get(
        '/players/recommended',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> playersJson = data['data'];
          return playersJson
              .map((json) => Player.fromJson(json))
              .toList();
        }
      }
      throw Exception('获取推荐玩家失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取推荐玩家失败: $e');
    }
  }

  /// 审核玩家认证（管理员功能）
  static Future<bool> reviewPlayerCertification(
    String id, {
    required CertificationStatus status,
    String? reason,
  }) async {
    try {
      final response = await _dio.post('/players/$id/review', data: {
        'certificationStatus': status.name,
        'reason': reason,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('审核玩家认证失败: $e');
    }
  }

  /// 获取玩家统计数据
  static Future<Map<String, dynamic>> getPlayerStats(String id) async {
    try {
      final response = await _dio.get('/players/$id/stats');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('获取玩家统计数据失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取玩家统计数据失败: $e');
    }
  }

  /// 获取玩家档案信息
  static Future<Map<String, dynamic>> getPlayerProfile(String playerId) async {
    try {
      final response = await _dio.get('/players/$playerId/profile');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }
      throw Exception('获取玩家档案失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取玩家档案失败: $e');
    }
  }

  /// 获取玩家服务列表
  static Future<List<Map<String, dynamic>>> getPlayerServices(String playerId) async {
    try {
      final response = await _dio.get('/players/$playerId/services');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('获取玩家服务列表失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取玩家服务列表失败: $e');
    }
  }

  /// 获取玩家订单列表
  static Future<List<Map<String, dynamic>>> getPlayerOrders(String playerId) async {
    try {
      final response = await _dio.get('/players/$playerId/orders');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('获取玩家订单列表失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取玩家订单列表失败: $e');
    }
  }

  /// 添加玩家服务
  static Future<Map<String, dynamic>> addPlayerService(Map<String, dynamic> serviceData) async {
    try {
      final response = await _dio.post('/players/services', data: serviceData);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data;
        }
      }
      throw Exception('添加玩家服务失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('添加玩家服务失败: $e');
    }
  }

}