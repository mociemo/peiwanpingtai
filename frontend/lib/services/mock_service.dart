class MockService {
  /// 模拟API响应
  static Map<String, dynamic> mockHealthResponse() {
    return {
      'status': 'success',
      'message': 'Backend is running (Mock)',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> mockHelloResponse() {
    return {
      'message': 'Hello from PlayMate Backend! (Mock)',
      'status': 'ok',
    };
  }

  static Map<String, dynamic> mockLoginResponse(String username, String password) {
    if (username == 'test' && password == '123456') {
      return {
        'success': true,
        'data': {
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': '1',
            'username': 'test',
            'nickname': '测试用户',
            'avatar': 'https://via.placeholder.com/100',
            'email': 'test@example.com',
          }
        }
      };
    } else {
      return {
        'success': false,
        'message': '用户名或密码错误',
      };
    }
  }

  static Map<String, dynamic> mockUserListResponse() {
    return {
      'success': true,
      'data': [
        {
          'id': '1',
          'username': 'player1',
          'nickname': '玩家一号',
          'avatar': 'https://via.placeholder.com/100',
          'rating': 4.8,
          'gameTypes': ['王者荣耀', '和平精英'],
          'price': 50.0,
          'intro': '资深玩家，带你上分！',
        },
        {
          'id': '2',
          'username': 'player2',
          'nickname': '玩家二号',
          'avatar': 'https://via.placeholder.com/100',
          'rating': 4.5,
          'gameTypes': ['英雄联盟', '绝地求生'],
          'price': 80.0,
          'intro': '专业陪玩，体验一流！',
        },
      ]
    };
  }
}