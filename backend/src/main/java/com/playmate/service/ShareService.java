package com.playmate.service;

import com.playmate.dto.ShareRequest;
import com.playmate.dto.ShareResponse;
import com.playmate.entity.ShareRecord;
import com.playmate.entity.User;
import com.playmate.entity.Post;
import com.playmate.entity.Order;
import com.playmate.repository.ShareRecordRepository;
import com.playmate.repository.UserRepository;
import com.playmate.repository.PostRepository;
import com.playmate.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class ShareService {

    @Autowired
    private ShareRecordRepository shareRecordRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private OrderRepository orderRepository;

    /**
     * 生成分享链接
     */
    public ShareResponse generateShareLink(ShareRequest request) {
        // 生成唯一的分享ID
        String shareId = UUID.randomUUID().toString().replace("-", "");
        
        // 创建分享记录
        ShareRecord shareRecord = new ShareRecord();
        shareRecord.setShareId(shareId);
        shareRecord.setUserId(request.getUserId());
        shareRecord.setShareType(request.getShareType());
        shareRecord.setShareId(request.getShareId());
        shareRecord.setPlatform(request.getPlatform());
        shareRecord.setCreateTime(LocalDateTime.now());
        shareRecord.setExpireTime(LocalDateTime.now().plusDays(7)); // 7天后过期
        shareRecord.setViewCount(0);
        
        shareRecordRepository.save(shareRecord);
        
        // 构建分享链接
        String shareUrl = "https://playmate.example.com/share/" + shareId;
        
        // 获取分享内容信息
        Map<String, Object> contentInfo = getContentInfo(request.getShareType(), request.getShareId());
        
        // 构建响应
        ShareResponse response = new ShareResponse();
        response.setShareId(shareId);
        response.setShareUrl(shareUrl);
        response.setTitle((String) contentInfo.get("title"));
        response.setDescription((String) contentInfo.get("description"));
        response.setImageUrl((String) contentInfo.get("imageUrl"));
        response.setExpireTime(shareRecord.getExpireTime());
        
        return response;
    }

    /**
     * 获取分享内容
     */
    public Map<String, Object> getSharedContent(String shareId) {
        ShareRecord shareRecord = shareRecordRepository.findByShareId(shareId)
                .orElseThrow(() -> new RuntimeException("分享链接不存在或已过期"));
        
        // 检查是否过期
        if (shareRecord.getExpireTime().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("分享链接已过期");
        }
        
        // 增加浏览次数
        shareRecord.setViewCount(shareRecord.getViewCount() + 1);
        shareRecordRepository.save(shareRecord);
        
        // 获取分享内容
        return getContentInfo(shareRecord.getShareType(), shareRecord.getShareId());
    }

    /**
     * 记录分享行为
     */
    public void recordShareAction(ShareRequest request) {
        // 这里可以记录用户的分享行为，用于数据分析
        // 可以创建一个分享行为记录表，记录用户分享的时间、平台等信息
    }

    /**
     * 获取用户的分享统计
     */
    public Map<String, Object> getShareStats(String userId) {
        Map<String, Object> stats = new HashMap<>();
        
        // 总分享次数
        long totalShares = shareRecordRepository.countByUserId(userId);
        stats.put("totalShares", totalShares);
        
        // 总浏览次数
        Integer totalViews = shareRecordRepository.sumViewCountByUserId(userId);
        stats.put("totalViews", totalViews != null ? totalViews : 0);
        
        // 各类型分享次数
        Map<String, Long> shareTypeStats = new HashMap<>();
        shareTypeStats.put("user", shareRecordRepository.countByUserIdAndShareType(userId, "user"));
        shareTypeStats.put("post", shareRecordRepository.countByUserIdAndShareType(userId, "post"));
        shareTypeStats.put("order", shareRecordRepository.countByUserIdAndShareType(userId, "order"));
        stats.put("shareTypeStats", shareTypeStats);
        
        return stats;
    }

    /**
     * 获取分享内容信息
     */
    private Map<String, Object> getContentInfo(String shareType, String shareId) {
        Map<String, Object> contentInfo = new HashMap<>();
        
        switch (shareType) {
            case "user":
                User user = userRepository.findById(shareId)
                        .orElseThrow(() -> new RuntimeException("用户不存在"));
                contentInfo.put("title", user.getNickname() + "的陪玩名片");
                contentInfo.put("description", user.getIntro() != null ? user.getIntro() : "快来体验专业的陪玩服务");
                contentInfo.put("imageUrl", user.getAvatar());
                break;
                
            case "post":
                Post post = postRepository.findById(shareId)
                        .orElseThrow(() -> new RuntimeException("动态不存在"));
                contentInfo.put("title", "精彩动态分享");
                contentInfo.put("description", post.getContent().length() > 50 
                        ? post.getContent().substring(0, 50) + "..." 
                        : post.getContent());
                contentInfo.put("imageUrl", post.getImages() != null && !post.getImages().isEmpty() 
                        ? post.getImages().get(0) 
                        : "");
                break;
                
            case "order":
                Order order = orderRepository.findById(shareId)
                        .orElseThrow(() -> new RuntimeException("订单不存在"));
                contentInfo.put("title", "陪玩订单分享");
                contentInfo.put("description", "体验了" + order.getServiceType() + "服务，非常棒！");
                contentInfo.put("imageUrl", order.getPlayerAvatar());
                break;
                
            default:
                throw new RuntimeException("不支持的分享类型");
        }
        
        return contentInfo;
    }
}