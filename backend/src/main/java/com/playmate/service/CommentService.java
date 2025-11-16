package com.playmate.service;

import com.playmate.dto.CommentRequest;
import com.playmate.dto.CommentResponse;
import com.playmate.entity.Comment;
import com.playmate.entity.CommentStatus;
import com.playmate.entity.Post;
import com.playmate.repository.CommentRepository;
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
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentService {
    
    private final CommentRepository commentRepository;
    private final PostRepository postRepository;
    private final UserRepository userRepository;
    
    public Page<CommentResponse> getCommentsByPostId(Long postId, Pageable pageable) {
        Page<Comment> comments = commentRepository.findByPostIdAndParentIdAndStatusOrderByCreateTimeDesc(postId, null, CommentStatus.PUBLISHED, pageable);
        return comments.map(comment -> convertToResponse(comment, true));
    }
    
    public Page<CommentResponse> getRepliesByCommentId(Long commentId, CommentStatus status, Pageable pageable) {
        Optional<Comment> parentComment = commentRepository.findById(commentId);
        if (parentComment.isEmpty()) {
            throw new RuntimeException("评论不存在");
        }
        
        Page<Comment> replies = commentRepository.findByPostIdAndParentIdAndStatusOrderByCreateTimeDesc(
            parentComment.get().getPostId(), commentId, status, pageable);
        return replies.map(comment -> convertToResponse(comment, false));
    }
    
    public Page<CommentResponse> getUserComments(Long userId, CommentStatus status, Pageable pageable) {
        Page<Comment> comments = commentRepository.findByUserIdAndStatusOrderByCreateTimeDesc(userId, status, pageable);
        return comments.map(comment -> convertToResponse(comment, true));
    }
    
    @Transactional
    public CommentResponse createComment(Long userId, Long postId, CommentRequest request) {
        Optional<Post> optionalPost = postRepository.findById(postId);
        if (optionalPost.isEmpty()) {
            throw new RuntimeException("动态不存在");
        }
        
        Comment comment = new Comment();
        comment.setPostId(postId);
        comment.setUserId(userId);
        comment.setContent(request.getContent());
        comment.setParentId(request.getParentId());
        comment.setReplyToUserId(request.getReplyToUserId());
        comment.setStatus(CommentStatus.PUBLISHED);
        comment.setCreateTime(LocalDateTime.now());
        
        Comment savedComment = commentRepository.save(comment);
        
        // 更新动态的评论数
        Post post = optionalPost.get();
        post.setCommentCount(post.getCommentCount() + 1);
        postRepository.save(post);
        
        return convertToResponse(savedComment, true);
    }
    
    @Transactional
    public CommentResponse updateComment(Long commentId, Long userId, CommentRequest request) {
        Optional<Comment> optionalComment = commentRepository.findById(commentId);
        if (optionalComment.isEmpty()) {
            throw new RuntimeException("评论不存在");
        }
        
        Comment comment = optionalComment.get();
        if (!comment.getUserId().equals(userId)) {
            throw new RuntimeException("无权修改此评论");
        }
        
        comment.setContent(request.getContent());
        Comment updatedComment = commentRepository.save(comment);
        return convertToResponse(updatedComment, true);
    }
    
    @Transactional
    public void deleteComment(Long commentId, Long userId) {
        Optional<Comment> optionalComment = commentRepository.findById(commentId);
        if (optionalComment.isEmpty()) {
            throw new RuntimeException("评论不存在");
        }
        
        Comment comment = optionalComment.get();
        if (!comment.getUserId().equals(userId)) {
            throw new RuntimeException("无权删除此评论");
        }
        
        comment.setStatus(CommentStatus.DELETED);
        commentRepository.save(comment);
        
        // 更新动态的评论数
        Optional<Post> optionalPost = postRepository.findById(comment.getPostId());
        optionalPost.ifPresent(post -> {
            post.setCommentCount(post.getCommentCount() - 1);
            postRepository.save(post);
        });
    }
    
    @Transactional
    public void likeComment(Long commentId, Long userId) {
        Optional<Comment> optionalComment = commentRepository.findById(commentId);
        if (optionalComment.isEmpty()) {
            throw new RuntimeException("评论不存在");
        }
        
        Comment comment = optionalComment.get();
        comment.setLikeCount(comment.getLikeCount() + 1);
        commentRepository.save(comment);
    }
    
    @Transactional
    public void unlikeComment(Long commentId, Long userId) {
        Optional<Comment> optionalComment = commentRepository.findById(commentId);
        if (optionalComment.isEmpty()) {
            throw new RuntimeException("评论不存在");
        }
        
        Comment comment = optionalComment.get();
        if (comment.getLikeCount() > 0) {
            comment.setLikeCount(comment.getLikeCount() - 1);
            commentRepository.save(comment);
        }
    }
    
    public CommentResponse getCommentById(Long commentId) {
        Optional<Comment> optionalComment = commentRepository.findById(commentId);
        if (optionalComment.isEmpty()) {
            throw new RuntimeException("评论不存在");
        }
        
        Comment comment = optionalComment.get();
        return convertToResponse(comment, true);
    }
    
    private CommentResponse convertToResponse(Comment comment, boolean includeReplies) {
        CommentResponse response = new CommentResponse();
        response.setId(comment.getId());
        response.setPostId(comment.getPostId());
        
        // 设置用户信息
        userRepository.findById(comment.getUserId()).ifPresent(user -> {
            CommentResponse.UserInfo userInfo = new CommentResponse.UserInfo();
            userInfo.setId(user.getId());
            userInfo.setUsername(user.getUsername());
            userInfo.setAvatar(user.getAvatar());
            response.setUser(userInfo);
        });
        
        // 设置回复用户信息
        if (comment.getReplyToUserId() != null) {
            userRepository.findById(comment.getReplyToUserId()).ifPresent(user -> {
                CommentResponse.UserInfo replyToUserInfo = new CommentResponse.UserInfo();
                replyToUserInfo.setId(user.getId());
                replyToUserInfo.setUsername(user.getUsername());
                replyToUserInfo.setAvatar(user.getAvatar());
                response.setReplyToUser(replyToUserInfo);
            });
        }
        
        response.setContent(comment.getContent());
        response.setParentId(comment.getParentId());
        response.setStatus(comment.getStatus());
        response.setLikeCount(comment.getLikeCount());
        response.setIsLiked(false);
        response.setCreateTime(comment.getCreateTime());
        
        // 加载回复
        if (includeReplies) {
            List<Comment> replies = commentRepository.findByPostIdAndParentIdAndStatusOrderByCreateTimeDesc(
                comment.getPostId(), comment.getId(), CommentStatus.PUBLISHED, 
                org.springframework.data.domain.PageRequest.of(0, 5)
            ).getContent();
            
            List<CommentResponse> replyResponses = replies.stream()
                .map(reply -> convertToResponse(reply, false))
                .collect(Collectors.toList());
            response.setReplies(replyResponses);
        }
        
        return response;
    }
}