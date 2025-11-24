package com.playmate.repository;

import com.playmate.entity.Comment;
import com.playmate.entity.CommentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


public interface CommentRepository extends JpaRepository<Comment, Long> {
    
    Page<Comment> findByPostIdAndStatusOrderByCreateTimeDesc(Long postId, CommentStatus status, Pageable pageable);
    
    Page<Comment> findByPostIdAndParentIdAndStatusOrderByCreateTimeDesc(Long postId, Long parentId, CommentStatus status, Pageable pageable);
    
    Page<Comment> findByUserIdAndStatusOrderByCreateTimeDesc(Long userId, CommentStatus status, Pageable pageable);
    
    @Query("SELECT COUNT(c) FROM Comment c WHERE c.postId = :postId AND c.status = :status")
    long countByPostIdAndStatus(@Param("postId") Long postId, @Param("status") CommentStatus status);
    
    @Query("SELECT COUNT(c) FROM Comment c WHERE c.userId = :userId AND c.status = :status")
    long countByUserIdAndStatus(@Param("userId") Long userId, @Param("status") CommentStatus status);
    
    @Query("SELECT c FROM Comment c WHERE c.postId = :postId AND c.status = :status ORDER BY c.likeCount DESC, c.createTime DESC")
    Page<Comment> findTopCommentsByPostId(@Param("postId") Long postId, @Param("status") CommentStatus status, Pageable pageable);
}