package com.playmate.repository;

import com.playmate.entity.Follow;
import com.playmate.entity.FollowStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface FollowRepository extends JpaRepository<Follow, Long> {
    
    boolean existsByFollowerIdAndFollowingIdAndStatus(Long followerId, Long followingId, FollowStatus status);
    
    Follow findByFollowerIdAndFollowingId(Long followerId, Long followingId);
    
    Page<Follow> findByFollowerIdAndStatusOrderByCreateTimeDesc(Long followerId, FollowStatus status, Pageable pageable);
    
    Page<Follow> findByFollowingIdAndStatusOrderByCreateTimeDesc(Long followingId, FollowStatus status, Pageable pageable);
    
    @Query("SELECT COUNT(f) FROM Follow f WHERE f.followerId = :userId AND f.status = :status")
    long countByFollowerIdAndStatus(@Param("userId") Long userId, @Param("status") FollowStatus status);
    
    @Query("SELECT COUNT(f) FROM Follow f WHERE f.followingId = :userId AND f.status = :status")
    long countByFollowingIdAndStatus(@Param("userId") Long userId, @Param("status") FollowStatus status);
    
    @Query("SELECT f.followingId FROM Follow f WHERE f.followerId = :userId AND f.status = :status")
    List<Long> findFollowingIdsByFollowerIdAndStatus(@Param("userId") Long userId, @Param("status") FollowStatus status);
    
    @Query("SELECT f.followerId FROM Follow f WHERE f.followingId = :userId AND f.status = :status")
    List<Long> findFollowerIdsByFollowingIdAndStatus(@Param("userId") Long userId, @Param("status") FollowStatus status);
    
    @Query("SELECT f FROM Follow f WHERE f.followerId = :userId AND f.status = :status ORDER BY f.createTime DESC")
    List<Follow> findRecentFollowingByFollowerId(@Param("userId") Long userId, @Param("status") FollowStatus status, Pageable pageable);
    
    Page<Follow> findByFollowerIdInAndStatusOrderByCreateTimeDesc(List<Long> followerIds, FollowStatus status, Pageable pageable);
}