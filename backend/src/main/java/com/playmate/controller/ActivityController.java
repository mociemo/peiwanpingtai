package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.Activity;
import com.playmate.entity.Activity.ActivityStatus;
import com.playmate.entity.Activity.ActivityType;
import com.playmate.service.ActivityService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/activities")
@RequiredArgsConstructor
public class ActivityController {
    
    private final ActivityService activityService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<Activity>>> getAllActivities() {
        try {
            List<Activity> activities = activityService.getAllActivities();
            return ResponseEntity.ok(ApiResponse.success("获取活动列表成功", activities));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<Activity>>> getActiveActivities() {
        try {
            List<Activity> activities = activityService.getActiveActivities();
            return ResponseEntity.ok(ApiResponse.success("获取活跃活动成功", activities));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/ongoing")
    public ResponseEntity<ApiResponse<List<Activity>>> getOngoingActivities() {
        try {
            List<Activity> activities = activityService.getOngoingActivities();
            return ResponseEntity.ok(ApiResponse.success("获取进行中活动成功", activities));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Activity>> getActivityById(@PathVariable Long id) {
        try {
            Optional<Activity> activity = activityService.getActivityById(id);
            if (activity.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success("获取活动成功", activity.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<ApiResponse<List<Activity>>> getActivitiesByStatus(@PathVariable ActivityStatus status) {
        try {
            List<Activity> activities = activityService.getActivitiesByStatus(status);
            return ResponseEntity.ok(ApiResponse.success("获取活动成功", activities));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/type/{type}")
    public ResponseEntity<ApiResponse<List<Activity>>> getActivitiesByType(@PathVariable ActivityType type) {
        try {
            List<Activity> activities = activityService.getActivitiesByType(type);
            return ResponseEntity.ok(ApiResponse.success("获取活动成功", activities));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Activity>> createActivity(@RequestBody Activity activity) {
        try {
            Activity createdActivity = activityService.createActivity(activity);
            return ResponseEntity.ok(ApiResponse.success("创建活动成功", createdActivity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Activity>> updateActivity(
            @PathVariable Long id, 
            @RequestBody Activity activity) {
        try {
            Activity updatedActivity = activityService.updateActivity(id, activity);
            return ResponseEntity.ok(ApiResponse.success("更新活动成功", updatedActivity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<String>> deleteActivity(@PathVariable Long id) {
        try {
            activityService.deleteActivity(id);
            return ResponseEntity.ok(ApiResponse.success("删除活动成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/start")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Activity>> startActivity(@PathVariable Long id) {
        try {
            Activity activity = activityService.startActivity(id);
            return ResponseEntity.ok(ApiResponse.success("启动活动成功", activity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/pause")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Activity>> pauseActivity(@PathVariable Long id) {
        try {
            Activity activity = activityService.pauseActivity(id);
            return ResponseEntity.ok(ApiResponse.success("暂停活动成功", activity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/end")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Activity>> endActivity(@PathVariable Long id) {
        try {
            Activity activity = activityService.endActivity(id);
            return ResponseEntity.ok(ApiResponse.success("结束活动成功", activity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/cancel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Activity>> cancelActivity(@PathVariable Long id) {
        try {
            Activity activity = activityService.cancelActivity(id);
            return ResponseEntity.ok(ApiResponse.success("取消活动成功", activity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/{id}/join")
    public ResponseEntity<ApiResponse<Activity>> joinActivity(@PathVariable Long id) {
        try {
            Activity activity = activityService.incrementParticipantCount(id);
            return ResponseEntity.ok(ApiResponse.success("参加活动成功", activity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/{id}/leave")
    public ResponseEntity<ApiResponse<Activity>> leaveActivity(@PathVariable Long id) {
        try {
            Activity activity = activityService.decrementParticipantCount(id);
            return ResponseEntity.ok(ApiResponse.success("退出活动成功", activity));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}