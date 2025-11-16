package com.playmate.service;

import com.playmate.entity.HomeContent;
import com.playmate.entity.User;
import com.playmate.entity.Player;
import com.playmate.entity.Post;
import com.playmate.repository.HomeContentRepository;
import com.playmate.repository.UserRepository;
import com.playmate.repository.PlayerRepository;
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
    private PlayerRepository playerRepository;

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
        List<Player> players = playerRepository.findAllByOrderByRatingDesc();
        
        return players.stream()
                .limit(limit)
                .map(player -> {
                    User user = player.getUser();
                    // 转换为前端需要的格式
                    Map<String, Object> playerInfo = Map.of(
                        "id", user.getId(),
                        "nickname", user.getNickname(),
                        "avatar", user.getAvatar(),
                        "rating", player.getRating() != null ? player.getRating().doubleValue() : 0.0,
                        "gameTypes", player.getSkillTags() != null ? player.getSkillTags() : "",
                        "price", player.getServicePrice() != null ? player.getServicePrice().doubleValue() : 0.0,
                        "intro", player.getIntroduction() != null ? player.getIntroduction() : ""
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
                        "images", post.getMediaUrls() != null ? post.getMediaUrls() : new String[0],
                        "likes", post.getLikeCount() != null ? post.getLikeCount() : 0,
                        "comments", post.getCommentCount() != null ? post.getCommentCount() : 0,
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