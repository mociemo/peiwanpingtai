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
public class PostService {
    
    private final PostRepository postRepository;
    private final UserRepository userRepository;
    
    public PostService(PostRepository postRepository, UserRepository userRepository) {
        this.postRepository = postRepository;
        this.userRepository = userRepository;
    }
    
    public Page<PostResponse> getPosts(PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByStatusOrderByCreateTimeDesc(status, pageable);
        return posts.map(this::convertToResponse);
    }
    
    public Page<PostResponse> getUserPosts(String userId, PostStatus status, Pageable pageable) {
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
    
    public Page<PostResponse> getPostsByUserIds(List<String> userIds, PostStatus status, Pageable pageable) {
        Page<Post> posts = postRepository.findByUserIdInAndStatusOrderByCreateTimeDesc(userIds, status, pageable);
        return posts.map(this::convertToResponse);
    }
    
    @Transactional
    @SuppressWarnings("null")
    public PostResponse createPost(String userId, CreatePostRequest request) {
        Post post = new Post();
        post.setUserId(userId);
        post.setContent(request.getContent());
        post.setMediaUrls(request.getImages() != null ? request.getImages().toArray(new String[0]) : new String[0]);
        post.setType(request.getType() != null ? request.getType() : PostType.TEXT);
        post.setStatus(PostStatus.PUBLISHED);
        post.setCreateTime(LocalDateTime.now());
        
        Post savedPost = postRepository.save(post);
        return convertToResponse(savedPost);
    }
    
    @Transactional
    @SuppressWarnings("null")
    public PostResponse updatePost(String postId, String userId, CreatePostRequest request) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Post post = optionalPost.get();
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("无权修改此动态");
        }
        
        post.setContent(request.getContent());
        post.setMediaUrls(request.getImages() != null ? request.getImages().toArray(new String[0]) : new String[0]);
        post.setType(request.getType());
        post.setUpdateTime(LocalDateTime.now());
        
        Post updatedPost = postRepository.save(post);
        return convertToResponse(updatedPost);
    }
    
    @Transactional
    @SuppressWarnings("null")
    public void deletePost(String postId, String userId) {
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
    public void likePost(String postId, String userId) {
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
    public void unlikePost(String postId, String userId) {
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
    public PostResponse getPostById(String postId) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Post post = optionalPost.get();
        return convertToResponse(post);
    }
    
    private PostResponse convertToResponse(Post post) {
        PostResponse response = new PostResponse();
        response.setId(Long.valueOf(post.getId()));
        
        // 设置用户信息
        userRepository.findById(Long.valueOf(post.getUserId())).ifPresent(user -> {
            PostResponse.UserInfo userInfo = new PostResponse.UserInfo();
            userInfo.setId(user.getId());
            userInfo.setUsername(user.getUsername());
            userInfo.setAvatar(user.getAvatar());
            response.setUser(userInfo);
        });
        
        response.setContent(post.getContent());
        response.setImages(java.util.Arrays.asList(post.getMediaUrls()));
        response.setType(post.getType());
        response.setStatus(post.getStatus());
        response.setCreateTime(post.getCreateTime());
        response.setUpdateTime(post.getUpdateTime());
        response.setLikeCount(post.getLikeCount());
        response.setCommentCount(post.getCommentCount());
        response.setShareCount(post.getShareCount());
        response.setIsLiked(false);
        response.setCollected(Boolean.FALSE);
        response.setPinned(post.getIsPinned());
        
        return response;
    }
}