package com.playmate.service;

import com.playmate.dto.CreatePostRequest;
import com.playmate.dto.PostResponse;
import com.playmate.entity.Post;
import com.playmate.entity.PostLike;
import com.playmate.entity.PostStatus;
import com.playmate.entity.PostType;
import com.playmate.repository.PostLikeRepository;
import com.playmate.repository.PostRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@SuppressWarnings("null")
public class PostService {

    private final PostRepository postRepository;
    private final UserRepository userRepository;
    private final PostLikeRepository postLikeRepository;

    public Page<PostResponse> getPosts(PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByStatusOrderByCreateTimeDesc(status, pageable);
        return posts.map(this::convertToResponse);
    }

    public Page<PostResponse> getUserPosts(Long userId, PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByUserIdAndStatusOrderByCreateTimeDesc(userId, status, pageable);
        return posts.map(this::convertToResponse);
    }

    public Page<PostResponse> getPostsByType(PostType type, PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByTypeAndStatusOrderByCreateTimeDesc(type, status, pageable);
        return posts.map(this::convertToResponse);
    }

    public Page<PostResponse> getPostsByGame(String gameName, PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByGameName(status, gameName, pageable);
        return posts.map(this::convertToResponse);
    }

    public Page<PostResponse> searchPosts(String keyword, PostStatus status, Pageable pageable) {
        PostStatus useStatus = status != null ? status : PostStatus.PUBLISHED;

        if (keyword == null || keyword.trim().isEmpty()) {
            return postRepository.findByStatusOrderByCreateTimeDesc(useStatus, pageable)
                    .map(this::convertToResponse);
        }

        Page<Post> posts = postRepository.findByKeyword(useStatus, keyword, pageable);
        return posts.map(this::convertToResponse);
    }

    public Page<PostResponse> getPostsByUserIds(List<Long> userIds, PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByUserIdInAndStatusOrderByCreateTimeDesc(userIds, status, pageable);
        return posts.map(this::convertToResponse);
    }

    @Transactional
    public PostResponse createPost(Long userId, CreatePostRequest request) {
        if (userId == null) {
            throw new IllegalArgumentException("用户ID不能为空");
        }
        if (request == null) {
            throw new IllegalArgumentException("请求参数不能为空");
        }

        Post post = new Post();
        post.setUserId(userId);
        post.setContent(request.getContent());
        post.setImages(request.getImages());
        post.setTags(request.getTags());
        post.setType(request.getType() != null ? request.getType() : PostType.TEXT);
        post.setStatus(PostStatus.PUBLISHED);
        post.setLocation(request.getLocation());
        post.setGameName(request.getGameName());
        post.setVideoUrl(request.getVideoUrl());
        post.setCreateTime(LocalDateTime.now());

        Post savedPost = postRepository.save(post);
        return convertToResponse(savedPost);
    }

    @Transactional
    public PostResponse updatePost(Long postId, Long userId, CreatePostRequest request) {
        if (postId == null) {
            throw new IllegalArgumentException("动态ID不能为空");
        }
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }

        Post post = optionalPost.orElseThrow(() -> new RuntimeException("动态不存在"));
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("无权修改此动态");
        }

        post.setContent(request.getContent());
        post.setImages(request.getImages());
        post.setTags(request.getTags());
        post.setType(request.getType());
        post.setLocation(request.getLocation());
        post.setGameName(request.getGameName());
        post.setVideoUrl(request.getVideoUrl());
        post.setUpdateTime(LocalDateTime.now());

        Post updatedPost = postRepository.save(post);
        return convertToResponse(updatedPost);
    }

    @Transactional
    public void deletePost(Long postId, Long userId) {
        if (postId == null) {
            throw new IllegalArgumentException("动态ID不能为空");
        }
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }

        Post post = optionalPost.orElseThrow(() -> new RuntimeException("动态不存在"));
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("无权删除此动态");
        }

        post.setStatus(PostStatus.DELETED);
        postRepository.save(post);
    }

    @Transactional
    public void likePost(@Nullable Long postId, @Nullable Long userId) {
        if (postId == null || userId == null) {
            throw new IllegalArgumentException("动态ID和用户ID不能为空");
        }
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }

        Post post = optionalPost.orElseThrow(() -> new RuntimeException("动态不存在"));

        // 检查是否已经点赞
        if (postLikeRepository.existsByPostIdAndUserId(postId, userId)) {
            throw new RuntimeException("已经点赞过了");
        }

        // 创建点赞记录
        PostLike postLike = new PostLike();
        postLike.setPost(post);
        postLike.setUser(userRepository.findById(userId).orElseThrow(() -> new RuntimeException("用户不存在")));
        postLikeRepository.save(postLike);

        // 更新点赞数
        post.setLikeCount(post.getLikeCount() + 1);
        postRepository.save(post);
    }

    @Transactional
    public void unlikePost(@Nullable Long postId, @Nullable Long userId) {
        if (postId == null || userId == null) {
            throw new IllegalArgumentException("动态ID和用户ID不能为空");
        }
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }

        Post post = optionalPost.orElseThrow(() -> new RuntimeException("动态不存在"));

        // 检查是否已点赞
        if (!postLikeRepository.existsByPostIdAndUserId(postId, userId)) {
            throw new RuntimeException("还未点赞");
        }

        // 删除点赞记录
        postLikeRepository.deleteByPostIdAndUserId(postId, userId);

        // 更新点赞数
        if (post.getLikeCount() > 0) {
            post.setLikeCount(post.getLikeCount() - 1);
            postRepository.save(post);
        }
    }

    public boolean isPostLiked(@Nullable Long postId, @Nullable Long userId) {
        if (postId == null || userId == null) {
            return false;
        }
        return postLikeRepository.existsByPostIdAndUserId(postId, userId);
    }

    @SuppressWarnings("nullness")
    public PostResponse getPostById(Long postId) {
        if (postId == null) {
            throw new IllegalArgumentException("动态ID不能为空");
        }

        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }

        Post post = optionalPost.orElseThrow(() -> new RuntimeException("动态不存在"));
        return convertToResponse(post);
    }

    @NonNull
    private PostResponse convertToResponse(@NonNull Post post) {
        PostResponse response = new PostResponse();
        response.setId(post.getId() != null ? post.getId() : 0L);

        // 设置用户信息
        if (post.getUserId() != null) {
            userRepository.findById(post.getUserId()).ifPresent(user -> {
                PostResponse.UserInfo userInfo = new PostResponse.UserInfo();
                userInfo.setId(user.getId() != null ? user.getId() : 0L);
                userInfo.setUsername(user.getUsername());
                userInfo.setAvatar(user.getAvatar());
                response.setUser(userInfo);
            });
        }

        response.setContent(post.getContent());
        response.setImages(post.getImages());
        response.setTags(post.getTags());
        response.setType(post.getType());
        response.setStatus(post.getStatus());
        response.setCreateTime(post.getCreateTime());
        response.setUpdateTime(post.getUpdateTime());
        response.setLikeCount(post.getLikeCount() != null ? post.getLikeCount() : 0);
        response.setCommentCount(post.getCommentCount() != null ? post.getCommentCount() : 0);
        response.setShareCount(post.getShareCount() != null ? post.getShareCount() : 0);
        response.setIsLiked(false);
        response.setIsCollected(false);
        response.setIsPinned(post.getIsPinned() != null ? post.getIsPinned() : false);
        response.setLocation(post.getLocation());
        response.setGameName(post.getGameName());
        response.setVideoUrl(post.getVideoUrl());

        return response;
    }

    /**
     * 搜索动态
     */
    public Page<PostResponse> searchPosts(String keyword, String gameType, Pageable pageable) {
        PostStatus useStatus = PostStatus.PUBLISHED;

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasGame = gameType != null && !gameType.trim().isEmpty();

        Page<Post> posts;
        if (hasKeyword && hasGame) {
            posts = postRepository.findByGameNameAndKeyword(useStatus, gameType, keyword, pageable);
        } else if (hasKeyword) {
            posts = postRepository.findByKeyword(useStatus, keyword, pageable);
        } else if (hasGame) {
            posts = postRepository.findByGameName(useStatus, gameType, pageable);
        } else {
            posts = postRepository.findByStatusOrderByCreateTimeDesc(useStatus, pageable);
        }

        return posts.map(this::convertToResponse);
    }
}