package com.playmate.service;

import com.playmate.dto.CreatePostRequest;
import com.playmate.dto.PostResponse;
import com.playmate.entity.Post;
import com.playmate.entity.PostStatus;
import com.playmate.entity.PostType;
import com.playmate.repository.PostRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PostService {
    
    private final PostRepository postRepository;
    private final UserRepository userRepository;
    
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
        Page<Post> posts = postRepository.findByKeyword(status, keyword, pageable);
        return posts.map(this::convertToResponse);
    }
    
    public Page<PostResponse> getPostsByUserIds(List<Long> userIds, PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByUserIdInAndStatusOrderByCreateTimeDesc(userIds, status, pageable);
        return posts.map(this::convertToResponse);
    }
    
    @Transactional
    @SuppressWarnings("null")
    public PostResponse createPost(Long userId, CreatePostRequest request) {
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
    @SuppressWarnings("null")
    public PostResponse updatePost(Long postId, Long userId, CreatePostRequest request) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Post post = optionalPost.get();
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
    @SuppressWarnings("null")
    public void deletePost(Long postId, Long userId) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Post post = optionalPost.get();
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("无权删除此动态");
        }
        
        post.setStatus(PostStatus.DELETED);
        postRepository.save(post);
    }
    
    @Transactional
    @SuppressWarnings("null")
    public void likePost(Long postId, Long userId) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Post post = optionalPost.get();
        post.setLikeCount(post.getLikeCount() + 1);
        postRepository.save(post);
    }
    
    @Transactional
    @SuppressWarnings("null")
    public void unlikePost(Long postId, Long userId) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Post post = optionalPost.get();
        if (post.getLikeCount() > 0) {
            post.setLikeCount(post.getLikeCount() - 1);
            postRepository.save(post);
        }
    }
    
    @SuppressWarnings("null")
    public PostResponse getPostById(Long postId) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Post post = optionalPost.get();
        return convertToResponse(post);
    }
    
    private PostResponse convertToResponse(Post post) {
        PostResponse response = new PostResponse();
        response.setId(post.getId());
        
        // 设置用户信息
        userRepository.findById(post.getUserId()).ifPresent(user -> {
            PostResponse.UserInfo userInfo = new PostResponse.UserInfo();
            userInfo.setId(user.getId());
            userInfo.setUsername(user.getUsername());
            userInfo.setAvatar(user.getAvatar());
            response.setUser(userInfo);
        });
        
        response.setContent(post.getContent());
        response.setImages(post.getImages());
        response.setTags(post.getTags());
        response.setType(post.getType());
        response.setStatus(post.getStatus());
        response.setCreateTime(post.getCreateTime());
        response.setUpdateTime(post.getUpdateTime());
        response.setLikeCount(post.getLikeCount());
        response.setCommentCount(post.getCommentCount());
        response.setShareCount(post.getShareCount());
        response.setIsLiked(false);
        response.setIsCollected(false);
        response.setIsPinned(post.getIsPinned());
        response.setLocation(post.getLocation());
        response.setGameName(post.getGameName());
        response.setVideoUrl(post.getVideoUrl());
        
        return response;
    }
}