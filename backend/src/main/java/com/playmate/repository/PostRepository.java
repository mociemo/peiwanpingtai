package com.playmate.repository;

import com.playmate.entity.Post;
import com.playmate.entity.PostStatus;
import com.playmate.entity.PostType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface PostRepository extends MongoRepository<Post, String> {
    
    Page<Post> findByStatusOrderByCreateTimeDesc(PostStatus status, Pageable pageable);
    
    Page<Post> findByUserIdAndStatusOrderByCreateTimeDesc(String userId, PostStatus status, Pageable pageable);
    
    Page<Post> findByTypeAndStatusOrderByCreateTimeDesc(PostType type, PostStatus status, Pageable pageable);
    
    Page<Post> findByUserIdInAndStatusOrderByCreateTimeDesc(List<String> userIds, PostStatus status, Pageable pageable);
    
    @Query("{ 'status': ?0, 'isPinned': true }")
    Page<Post> findPinnedPosts(PostStatus status, Pageable pageable);
    
    @Query("{ 'status': ?0, 'content': { $regex: ?1, $options: 'i' } }")
    Page<Post> findByKeyword(PostStatus status, String keyword, Pageable pageable);
    
    @Query("{ 'status': ?0, 'gameName': ?1 }")
    Page<Post> findByGameName(PostStatus status, String gameName, Pageable pageable);
    
    long countByUserIdAndStatus(String userId, PostStatus status);
}