package com.playmate.service;

import com.playmate.entity.HomeContent;
import com.playmate.entity.User;
import com.playmate.entity.Post;
import com.playmate.repository.HomeContentRepository;
import com.playmate.repository.UserRepository;
import com.playmate.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class HomeService {

    @Autowired
    private HomeContentRepository homeContentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PostRepository postRepository;

    /**
     * 获取首页置顶内容
     */
    public List<HomeContent> getFeaturedContent() {
        LocalDateTime now = LocalDateTime.now();
        return homeContentRepository.findByIsActiveTrueAndStartTimeBeforeAndEndTimeAfterOrderBySortOrderAsc(
                now, now);
    }

    /**
     * 获取首页推荐陪玩人员
     */
    public List<Object> getRecommendedPlayers(int limit) {
        // 这里可以根据评分、订单量、活跃度等指标推荐陪玩人员
        // 暂时返回评分最高的陪玩人员
        List<User> players = userRepository.findByRoleOrderByRatingDesc("player");
        
        return players.stream()
                .limit(limit)
                .map(player -> {
                    // 转换为前端需要的格式
                    Map<String, Object> playerInfo = Map.of(
                        "id", player.getId(),
                        "nickname", player.getNickname(),
                        "avatar", player.getAvatar(),
                        "rating", player.getRating() != null ? player.getRating() : 0.0,
                        "gameTypes", player.getGameTypes(),
                        "price", player.getPrice() != null ? player.getPrice() : 0.0,
                        "intro", player.getIntro() != null ? player.getIntro() : ""
                    );
                    return playerInfo;
                })
                .collect(Collectors.toList());
    }

    /**
     * 获取首页热门动态
     */
    public List<Object> getHotPosts(int limit) {
        // 这里可以根据点赞数、评论数等指标获取热门动态
        // 暂时返回最新的动态
        Sort sort = Sort.by(Sort.Direction.DESC, "createTime");
        List<Post> posts = postRepository.findAll(sort);
        
        return posts.stream()
                .limit(limit)
                .map(post -> {
                    // 转换为前端需要的格式
                    Map<String, Object> postInfo = Map.of(
                        "id", post.getId(),
                        "userId", post.getUserId(),
                        "content", post.getContent(),
                        "images", post.getImages() != null ? post.getImages() : List.of(),
                        "likes", post.getLikes() != null ? post.getLikes() : 0,
                        "comments", post.getComments() != null ? post.getComments() : 0,
                        "createTime", post.getCreateTime()
                    );
                    return postInfo;
                })
                .collect(Collectors.toList());
    }

    /**
     * 添加首页置顶内容
     */
    public HomeContent addFeaturedContent(HomeContent content) {
        content.setCreateTime(LocalDateTime.now());
        content.setUpdateTime(LocalDateTime.now());
        return homeContentRepository.save(content);
    }

    /**
     * 更新首页置顶内容
     */
    public HomeContent updateFeaturedContent(String id, HomeContent content) {
        HomeContent existingContent = homeContentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("内容不存在"));
        
        existingContent.setTitle(content.getTitle());
        existingContent.setDescription(content.getDescription());
        existingContent.setImageUrl(content.getImageUrl());
        existingContent.setLinkType(content.getLinkType());
        existingContent.setLinkId(content.getLinkId());
        existingContent.setSortOrder(content.getSortOrder());
        existingContent.setIsActive(content.getIsActive());
        existingContent.setStartTime(content.getStartTime());
        existingContent.setEndTime(content.getEndTime());
        existingContent.setUpdateTime(LocalDateTime.now());
        
        return homeContentRepository.save(existingContent);
    }

    /**
     * 删除首页置顶内容
     */
    public void deleteFeaturedContent(String id) {
        if (!homeContentRepository.existsById(id)) {
            throw new RuntimeException("内容不存在");
        }
        homeContentRepository.deleteById(id);
    }
}