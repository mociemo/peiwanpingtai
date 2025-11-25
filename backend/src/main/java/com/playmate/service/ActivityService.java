package com.playmate.service;

import com.playmate.entity.Activity;
import com.playmate.entity.Activity.ActivityStatus;
import com.playmate.entity.Activity.ActivityType;
import com.playmate.repository.ActivityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class ActivityService {
    
    private final ActivityRepository activityRepository;
    
    public List<Activity> getAllActivities() {
        return activityRepository.findAll();
    }
    
    public List<Activity> getActiveActivities() {
        return activityRepository.findActiveActivitiesOrderBySort();
    }
    
    public List<Activity> getOngoingActivities() {
        return activityRepository.findOngoingActivities(LocalDateTime.now());
    }
    
    @SuppressWarnings("null")
    public Optional<Activity> getActivityById(Long id) {
        return activityRepository.findById(id);
    }
    
    public List<Activity> getActivitiesByStatus(ActivityStatus status) {
        return activityRepository.findByStatus(status);
    }
    
    public List<Activity> getActivitiesByType(ActivityType type) {
        return activityRepository.findByType(type);
    }
    
    public Activity createActivity(Activity activity) {
        // 验证时间
        if (activity.getStartTime().isAfter(activity.getEndTime())) {
            throw new RuntimeException("活动开始时间不能晚于结束时间");
        }
        
        // 验证参与人数限制
        if (activity.getParticipantLimit() != null && activity.getParticipantLimit() <= 0) {
            throw new RuntimeException("参与人数限制必须大于0");
        }
        
        return activityRepository.save(activity);
    }
    
    @SuppressWarnings("null")
    public Activity updateActivity(Long id, Activity activityDetails) {
        return activityRepository.findById(id)
            .map(activity -> {
                // 验证时间
                if (activityDetails.getStartTime().isAfter(activityDetails.getEndTime())) {
                    throw new RuntimeException("活动开始时间不能晚于结束时间");
                }
                
                activity.setTitle(activityDetails.getTitle());
                activity.setDescription(activityDetails.getDescription());
                activity.setImageUrl(activityDetails.getImageUrl());
                activity.setType(activityDetails.getType());
                activity.setStatus(activityDetails.getStatus());
                activity.setStartTime(activityDetails.getStartTime());
                activity.setEndTime(activityDetails.getEndTime());
                activity.setDiscountRate(activityDetails.getDiscountRate());
                activity.setMinAmount(activityDetails.getMinAmount());
                activity.setMaxDiscount(activityDetails.getMaxDiscount());
                activity.setParticipantLimit(activityDetails.getParticipantLimit());
                activity.setSortOrder(activityDetails.getSortOrder());
                
                return activityRepository.save(activity);
            })
            .orElseThrow(() -> new RuntimeException("活动不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public void deleteActivity(Long id) {
        if (!activityRepository.existsById(id)) {
            throw new RuntimeException("活动不存在，ID: " + id);
        }
        activityRepository.deleteById(id);
    }
    
    @SuppressWarnings("null")
    public Activity startActivity(Long id) {
        return activityRepository.findById(id)
            .map(activity -> {
                if (activity.getStatus() == ActivityStatus.ACTIVE) {
                    throw new RuntimeException("活动已经是进行中状态");
                }
                if (activity.getStartTime().isAfter(LocalDateTime.now())) {
                    throw new RuntimeException("活动开始时间未到");
                }
                activity.setStatus(ActivityStatus.ACTIVE);
                return activityRepository.save(activity);
            })
            .orElseThrow(() -> new RuntimeException("活动不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public Activity pauseActivity(Long id) {
        return activityRepository.findById(id)
            .map(activity -> {
                if (activity.getStatus() != ActivityStatus.ACTIVE) {
                    throw new RuntimeException("只能暂停进行中的活动");
                }
                activity.setStatus(ActivityStatus.SUSPENDED);
                return activityRepository.save(activity);
            })
            .orElseThrow(() -> new RuntimeException("活动不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public Activity endActivity(Long id) {
        return activityRepository.findById(id)
            .map(activity -> {
                if (activity.getStatus() == ActivityStatus.ENDED || activity.getStatus() == ActivityStatus.CANCELLED) {
                    throw new RuntimeException("活动已经结束或取消");
                }
                activity.setStatus(ActivityStatus.ENDED);
                return activityRepository.save(activity);
            })
            .orElseThrow(() -> new RuntimeException("活动不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public Activity cancelActivity(Long id) {
        return activityRepository.findById(id)
            .map(activity -> {
                if (activity.getStatus() == ActivityStatus.ENDED || activity.getStatus() == ActivityStatus.CANCELLED) {
                    throw new RuntimeException("活动已经结束或取消");
                }
                activity.setStatus(ActivityStatus.CANCELLED);
                return activityRepository.save(activity);
            })
            .orElseThrow(() -> new RuntimeException("活动不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public Activity incrementParticipantCount(Long id) {
        return activityRepository.findById(id)
            .map(activity -> {
                if (activity.getParticipantLimit() != null && 
                    activity.getParticipantCount() >= activity.getParticipantLimit()) {
                    throw new RuntimeException("活动参与人数已满");
                }
                activity.setParticipantCount(activity.getParticipantCount() + 1);
                return activityRepository.save(activity);
            })
            .orElseThrow(() -> new RuntimeException("活动不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public Activity decrementParticipantCount(Long id) {
        return activityRepository.findById(id)
            .map(activity -> {
                if (activity.getParticipantCount() <= 0) {
                    throw new RuntimeException("参与人数不能为负数");
                }
                activity.setParticipantCount(activity.getParticipantCount() - 1);
                return activityRepository.save(activity);
            })
            .orElseThrow(() -> new RuntimeException("活动不存在，ID: " + id));
    }
    
    // 定时任务：自动更新活动状态
    @Scheduled(fixedRate = 60000) // 每分钟执行一次
    public void autoUpdateActivityStatus() {
        LocalDateTime now = LocalDateTime.now();
        
        // 处理过期的活动
        List<Activity> expiredActivities = activityRepository.findExpiredActivities(now);
        expiredActivities.forEach(activity -> {
            activity.setStatus(ActivityStatus.ENDED);
            activityRepository.save(activity);
        });
        
        // 处理人数已满的活动
        List<Activity> fullActivities = activityRepository.findFullActivities();
        fullActivities.forEach(activity -> {
            activity.setStatus(ActivityStatus.ENDED);
            activityRepository.save(activity);
        });
    }
}