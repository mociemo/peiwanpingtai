package com.playmate.repository;

import com.playmate.entity.Post;
import com.playmate.entity.PostStatus;
import com.playmate.entity.PostType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface PostRepository extends JpaRepository<Post, Long> {

    Page<Post> findByUserIdAndStatusOrderByCreateTimeDesc(Long userId, PostStatus status, Pageable pageable);

    Page<Post> findByStatusOrderByCreateTimeDesc(PostStatus status, Pageable pageable);

    Page<Post> findByTypeAndStatusOrderByCreateTimeDesc(PostType type, PostStatus status, Pageable pageable);

    Page<Post> findByUserIdInAndStatusOrderByCreateTimeDesc(List<Long> userIds, PostStatus status, Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.status = :status AND p.isPinned = true ORDER BY p.createTime DESC")
    Page<Post> findPinnedPosts(@Param("status") PostStatus status, Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.status = :status AND p.content LIKE %:keyword% ORDER BY p.createTime DESC")
    Page<Post> findByKeyword(@Param("status") PostStatus status, @Param("keyword") String keyword, Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.status = :status AND p.gameName = :gameName ORDER BY p.createTime DESC")
    Page<Post> findByGameName(@Param("status") PostStatus status, @Param("gameName") String gameName,
            Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.status = :status AND p.gameName = :gameName AND p.content LIKE %:keyword% ORDER BY p.createTime DESC")
    Page<Post> findByGameNameAndKeyword(@Param("status") PostStatus status, @Param("gameName") String gameName,
            @Param("keyword") String keyword, Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.status = :status AND p.userId IN :userIds AND p.content LIKE %:keyword% ORDER BY p.createTime DESC")
    Page<Post> findByUserIdsAndKeyword(@Param("status") PostStatus status, @Param("userIds") List<Long> userIds,
            @Param("keyword") String keyword, Pageable pageable);

    @Query("SELECT COUNT(p) FROM Post p WHERE p.userId = :userId AND p.status = :status")
    long countByUserIdAndStatus(@Param("userId") Long userId, @Param("status") PostStatus status);

    @Query("SELECT p FROM Post p WHERE p.status = :status AND p.userId = :userId ORDER BY p.createTime DESC")
    List<Post> findRecentPostsByUserId(@Param("userId") Long userId, @Param("status") PostStatus status,
            Pageable pageable);
}