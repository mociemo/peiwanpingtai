package com.playmate.service;

import com.playmate.dto.FollowResponse;
import com.playmate.dto.UserStatsResponse;
import com.playmate.entity.Follow;
import com.playmate.entity.FollowStatus;
import com.playmate.repository.FollowRepository;
import com.playmate.repository.PostRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FollowService {
    
    private final FollowRepository followRepository;
    private final UserRepository userRepository;
    private final PostRepository postRepository;
    
    public Page<FollowResponse> getFollowers(Long userId, Pageable pageable) {
        Page<Follow> follows = followRepository.findByFollowingIdAndStatusOrderByCreateTimeDesc(userId, FollowStatus.FOLLOWING, pageable);
        return follows.map(this::convertToResponse);
    }
    
    public Page<FollowResponse> getFollowing(Long userId, Pageable pageable) {
        Page<Follow> follows = followRepository.findByFollowerIdAndStatusOrderByCreateTimeDesc(userId, FollowStatus.FOLLOWING, pageable);
        return follows.map(this::convertToResponse);
    }
    
    public Page<FollowResponse> getMutualFollowers(Long userId1, Long userId2, Pageable pageable) {
        List<Long> user1Following = getFollowingIds(userId1);
        List<Long> user2Following = getFollowingIds(userId2);
        
        // 找出共同关注的人
        List<Long> mutualIds = user1Following.stream()
            .filter(user2Following::contains)
            .toList();
        
        if (mutualIds.isEmpty()) {
            return Page.empty();
        }
        
        Page<Follow> mutualFollows = followRepository.findByFollowerIdInAndStatusOrderByCreateTimeDesc(mutualIds, FollowStatus.FOLLOWING, pageable);
        return mutualFollows.map(this::convertToResponse);
    }
    
    public boolean isFollowing(Long followerId, Long followingId) {
        return followRepository.existsByFollowerIdAndFollowingIdAndStatus(followerId, followingId, FollowStatus.FOLLOWING);
    }
    
    @Transactional
    public FollowResponse followUser(Long followerId, Long followingId) {
        // 检查是否已经关注
        if (isFollowing(followerId, followingId)) {
            throw new RuntimeException("已经关注该用户");
        }
        
        // 检查是否是同一个人
        if (followerId.equals(followingId)) {
            throw new RuntimeException("不能关注自己");
        }
        
        // 检查是否存在之前的关注记录
        Follow follow = followRepository.findByFollowerIdAndFollowingId(followerId, followingId);
        if (follow != null) {
            follow.setStatus(FollowStatus.FOLLOWING);
            follow.setCreateTime(LocalDateTime.now());
        } else {
            follow = new Follow();
            follow.setFollowerId(followerId);
            follow.setFollowingId(followingId);
            follow.setStatus(FollowStatus.FOLLOWING);
            follow.setCreateTime(LocalDateTime.now());
        }
        
        Follow savedFollow = followRepository.save(follow);
        return convertToResponse(savedFollow);
    }
    
    @Transactional
    public void unfollowUser(Long followerId, Long followingId) {
        Follow follow = followRepository.findByFollowerIdAndFollowingId(followerId, followingId);
        if (follow == null) {
            throw new RuntimeException("未关注该用户");
        }
        
        follow.setStatus(FollowStatus.REJECTED);
        followRepository.save(follow);
    }
    
    @Transactional
    public void blockUser(Long blockerId, Long blockedId) {
        // 检查是否存在关注关系
        Follow follow = followRepository.findByFollowerIdAndFollowingId(blockerId, blockedId);
        if (follow == null) {
            follow = new Follow();
            follow.setFollowerId(blockerId);
            follow.setFollowingId(blockedId);
        }
        
        follow.setStatus(FollowStatus.BLOCKED);
        follow.setCreateTime(LocalDateTime.now());
        followRepository.save(follow);
    }
    
    @Transactional
    public void unblockUser(Long blockerId, Long blockedId) {
        Follow follow = followRepository.findByFollowerIdAndFollowingId(blockerId, blockedId);
        if (follow == null || follow.getStatus() != FollowStatus.BLOCKED) {
            throw new RuntimeException("未拉黑该用户");
        }
        
        followRepository.delete(follow);
    }
    
    public UserStatsResponse getUserStats(Long userId) {
        UserStatsResponse stats = new UserStatsResponse();
        stats.setUserId(userId);
        
        // 获取粉丝数
        long followersCount = followRepository.countByFollowingIdAndStatus(userId, FollowStatus.FOLLOWING);
        stats.setFollowersCount((int) followersCount);
        
        // 获取关注数
        long followingCount = followRepository.countByFollowerIdAndStatus(userId, FollowStatus.FOLLOWING);
        stats.setFollowingCount((int) followingCount);
        
        // 获取动态数
        long postsCount = postRepository.countByUserIdAndStatus(userId, com.playmate.entity.PostStatus.PUBLISHED);
        stats.setPostsCount((int) postsCount);
        
        // 获取获赞数（需要结合点赞记录）
        stats.setLikedCount(0);
        
        // 设置最后活跃时间
        stats.setLastActiveTime(LocalDateTime.now());
        
        return stats;
    }
    
    public List<Long> getFollowingIds(Long userId) {
        return followRepository.findFollowingIdsByFollowerIdAndStatus(userId, FollowStatus.FOLLOWING);
    }
    
    public List<Long> getFollowerIds(Long userId) {
        return followRepository.findFollowerIdsByFollowingIdAndStatus(userId, FollowStatus.FOLLOWING);
    }
    
    private FollowResponse convertToResponse(Follow follow) {
        FollowResponse response = new FollowResponse();
        response.setId(follow.getId());
        response.setStatus(follow.getStatus());
        response.setCreateTime(follow.getCreateTime());
        
        // 设置关注者信息
        userRepository.findById(follow.getFollowerId()).ifPresent(user -> {
            FollowResponse.UserInfo followerInfo = new FollowResponse.UserInfo();
            followerInfo.setId(user.getId());
            followerInfo.setUsername(user.getUsername());
            followerInfo.setAvatar(user.getAvatar());
            response.setFollower(followerInfo);
        });
        
        // 设置被关注者信息
        userRepository.findById(follow.getFollowingId()).ifPresent(user -> {
            FollowResponse.UserInfo followingInfo = new FollowResponse.UserInfo();
            followingInfo.setId(user.getId());
            followingInfo.setUsername(user.getUsername());
            followingInfo.setAvatar(user.getAvatar());
            response.setFollowing(followingInfo);
        });
        
        return response;
    }
}