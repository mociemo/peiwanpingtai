package com.playmate.repository;

import com.playmate.entity.CommentLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommentLikeRepository extends JpaRepository<CommentLike, Long> {
    
    boolean existsByCommentIdAndUserId(Long commentId, Long userId);
    
    CommentLike findByCommentIdAndUserId(Long commentId, Long userId);
    
    List<CommentLike> findByUserId(Long userId);
    
    List<CommentLike> findByCommentId(Long commentId);
    
    @Modifying
    @Query("DELETE FROM CommentLike cl WHERE cl.comment.id = :commentId AND cl.user.id = :userId")
    void deleteByCommentIdAndUserId(@Param("commentId") Long commentId, @Param("userId") Long userId);
    
    @Query("SELECT COUNT(cl) FROM CommentLike cl WHERE cl.comment.id = :commentId")
    Long countByCommentId(@Param("commentId") Long commentId);
}