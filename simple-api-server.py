#!/usr/bin/env python3
"""
简单的API服务器 - 用于前后端对接测试
替代Spring Boot后端，提供基本的API接口
"""

from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import os
import json

app = Flask(__name__)
CORS(app)  # 允许跨域请求

# 模拟数据
USERS = {
    "test@example.com": {
        "id": 1,
        "username": "testuser",
        "email": "test@example.com",
        "nickname": "测试用户",
        "avatar": "https://via.placeholder.com/100",
        "balance": 100.0,
        "level": 1,
        "experience": 0
    }
}

@app.route('/')
def home():
    return jsonify({"message": "PlayMate API Server is running", "status": "OK"})

@app.route('/api/health')
def health():
    return jsonify({"status": "OK", "message": "Server is healthy"})

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    username = data.get('username')
    password = data.get('password')
    
    # 支持用户名或邮箱登录
    user_key = None
    if username in ["testuser", "admin"]:
        user_key = "test@example.com"
    elif "@" in username:
        user_key = username
    
    if user_key and user_key in USERS:
        user_data = USERS[user_key].copy()
        user_data['username'] = username
        return jsonify({
            "success": True,
            "message": "登录成功",
            "data": {
                "token": "mock-jwt-token-12345",
                "user": user_data
            }
        })
    else:
        return jsonify({
            "success": False,
            "message": "用户名或密码错误"
        }), 401

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    username = data.get('username')
    password = data.get('password')
    nickname = data.get('nickname', username)
    email = data.get('email', f"{username}@example.com")
    
    # 简单验证
    if not username or not password:
        return jsonify({
            "success": False,
            "message": "用户名和密码不能为空"
        }), 400
    
    # 模拟用户名已存在检查
    if username in ["testuser", "admin"]:
        return jsonify({
            "success": False,
            "message": "用户名已存在"
        }), 400
    
    # 创建新用户
    new_user = {
        "id": len(USERS) + 2,
        "username": username,
        "email": email,
        "nickname": nickname,
        "avatar": "https://via.placeholder.com/100",
        "balance": 0.0,
        "level": 1,
        "experience": 0
    }
    
    return jsonify({
        "success": True,
        "message": "注册成功",
        "data": new_user
    })

@app.route('/api/user/info')
def user_info():
    # 模拟从token获取用户信息 - 这里应该检查Authorization header
    # 为了演示，直接返回测试用户信息
    return jsonify({
        "success": True,
        "data": USERS.get("test@example.com")
    })

@app.route('/api/posts')
def posts():
    return jsonify({
        "success": True,
        "data": {
            "posts": [
                {
                    "id": 1,
                    "title": "欢迎来到PlayMate",
                    "content": "这是一个测试帖子",
                    "author": "testuser",
                    "createTime": "2024-01-01T00:00:00",
                    "likes": 10,
                    "comments": 5
                }
            ],
            "total": 1
        }
    })

@app.route('/api/players')
def players():
    return jsonify({
        "success": True,
        "data": {
            "players": [
                {
                    "id": 1,
                    "nickname": "专业陪玩",
                    "level": 10,
                    "price": 50.0,
                    "games": ["王者荣耀", "LOL"],
                    "avatar": "https://via.placeholder.com/100",
                    "description": "经验丰富的陪玩玩家"
                }
            ],
            "total": 1
        }
    })

if __name__ == '__main__':
    print("🚀 启动简单API服务器...")
    print("📍 地址: http://localhost:8888")
    print("🔗 健康检查: http://localhost:8888/api/health")
    print("🌐 前端可以正常连接到后端了!")
    app.run(host='0.0.0.0', port=8888, debug=True)