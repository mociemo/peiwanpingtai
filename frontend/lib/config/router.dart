import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/search/search_page.dart';
import '../pages/notifications/notifications_page.dart';
import '../pages/orders/create_order_page.dart';
import '../pages/orders/order_detail_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/chat/conversations_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/chat/voice_call_page.dart';
import '../pages/chat/video_call_page.dart';
import '../pages/chat/incoming_call_page.dart';
import '../pages/payment/recharge_page.dart';
import '../pages/payment/withdrawal_page.dart';
import '../pages/payment/bills_page.dart';
import '../pages/payment/withdrawal_records_page.dart';
import '../pages/payment/payment_process_page.dart';
import '../pages/community/post_list_page.dart';
import '../pages/community/create_post_page.dart';
import '../pages/community/post_detail_page.dart';
import '../pages/community/follow_list_page.dart';
import '../pages/community/user_profile_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => MaterialPage<void>(child: LoginPage()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: RegisterPage()),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: ProfilePage()),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: SearchPage()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: NotificationsPage()),
      ),
      GoRoute(
        path: '/orders',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: OrdersPage()),
      ),
      GoRoute(
        path: '/orders/create',
        pageBuilder: (context, state) => MaterialPage<void>(
          child: CreateOrderPage(
            player: state.extra as Map<String, dynamic>? ?? {},
          ),
        ),
      ),
      GoRoute(
        path: '/orders/:orderId',
        pageBuilder: (context, state) => MaterialPage<void>(
          child: OrderDetailPage(
            orderId: state.pathParameters['orderId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: ConversationsPage()),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        pageBuilder: (context, state) {
          // 这里需要从会话ID获取参与者信息，暂时使用默认值
          return MaterialPage<void>(
            child: ChatPage(
              conversationId: state.pathParameters['conversationId'] ?? '',
              participantId: '', // 需要从API获取
              participantName: '', // 需要从API获取
              participantAvatar: '', // 需要从API获取
            ),
          );
        },
      ),
      GoRoute(
        path: '/chat/:conversationId/voice',
        pageBuilder: (context, state) {
          // 这里需要从会话ID获取参与者信息，暂时使用默认值
          return MaterialPage<void>(
            child: VoiceCallPage(
              conversationId: state.pathParameters['conversationId'] ?? '',
              participantId: '', // 需要从API获取
              participantName: '', // 需要从API获取
              participantAvatar: '', // 需要从API获取
            ),
          );
        },
      ),
      GoRoute(
        path: '/chat/:conversationId/video',
        pageBuilder: (context, state) {
          // 这里需要从会话ID获取参与者信息，暂时使用默认值
          return MaterialPage<void>(
            child: VideoCallPage(
              conversationId: state.pathParameters['conversationId'] ?? '',
              participantId: '', // 需要从API获取
              participantName: '', // 需要从API获取
              participantAvatar: '', // 需要从API获取
            ),
          );
        },
      ),
      GoRoute(
        path: '/chat/:conversationId/incoming',
        pageBuilder: (context, state) {
          // 这里需要从会话ID获取参与者信息，暂时使用默认值
          return MaterialPage<void>(
            child: IncomingCallPage(
              conversationId: state.pathParameters['conversationId'] ?? '',
              participantId: '', // 需要从API获取
              participantName: '', // 需要从API获取
              participantAvatar: '', // 需要从API获取
              isVideoCall: state.uri.queryParameters['video'] == 'true',
            ),
          );
        },
      ),
      GoRoute(
        path: '/recharge',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: RechargePage()),
      ),
      GoRoute(
        path: '/withdrawal',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: WithdrawalPage()),
      ),
      GoRoute(
        path: '/withdrawal/records',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: WithdrawalRecordsPage()),
      ),
      GoRoute(
        path: '/bills',
        pageBuilder: (context, state) => MaterialPage<void>(child: BillsPage()),
      ),
      GoRoute(
        path: '/payment/process',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: PaymentProcessPage()),
      ),
      GoRoute(
        path: '/payment/order/detail',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return MaterialPage<void>(
            child: OrderDetailPage(orderId: args?['orderId']?.toString() ?? ''),
          );
        },
      ),
      GoRoute(
        path: '/community',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: PostListPage()),
      ),
      GoRoute(
        path: '/community/create',
        pageBuilder: (context, state) =>
            MaterialPage<void>(child: CreatePostPage()),
      ),
      GoRoute(
        path: '/community/posts/:postId',
        pageBuilder: (context, state) => MaterialPage<void>(
          child: PostDetailPage(postId: state.pathParameters['postId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/community/followers',
        pageBuilder: (context, state) => MaterialPage<void>(
          child: FollowListPage(userId: '0', isFollowers: true),
        ),
      ),
      GoRoute(
        path: '/community/following',
        pageBuilder: (context, state) => MaterialPage<void>(
          child: FollowListPage(userId: '0', isFollowers: false),
        ),
      ),
      GoRoute(
        path: '/profile/:userId',
        pageBuilder: (context, state) => MaterialPage<void>(
          child: UserProfilePage(userId: state.pathParameters['userId'] ?? ''),
        ),
      ),
    ],
  );
}
