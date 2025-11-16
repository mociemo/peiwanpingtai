package com.playmate.repository;

import com.playmate.entity.Comment;
import com.playmate.entity.CommentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

public interface CommentRepository extends MongoRepository<Comment, String> {
    
    Page<Comment> findByPostIdAndStatusOrderByCreateTimeDesc(String postId, CommentStatus status, Pageable pageable);
    
    Page<Comment> findByPostIdAndParentIdAndStatusOrderByCreateTimeDesc(String postId, String parentId, CommentStatus status, Pageable pageable);
    
    Page<Comment> findByUserIdAndStatusOrderByCreateTimeDesc(String userId, CommentStatus status, Pageable pageable);
    
    @Query(value = "{ 'postId': ?0, 'status': ?1 }", count = true)
    long countByPostIdAndStatus(String postId, CommentStatus status);
    
    @Query(value = "{ 'userId': ?0, 'status': ?1 }", count = true)
    long countByUserIdAndStatus(String userId, CommentStatus status);
    
    @Query("{ 'postId': ?0, 'status': ?1 }")
    Page<Comment> findTopCommentsByPostId(String postId, CommentStatus status, Pageable pageable);
}