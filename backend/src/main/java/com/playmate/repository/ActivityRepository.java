package com.playmate.repository;

import com.playmate.entity.Activity;
import com.playmate.entity.Activity.ActivityStatus;
import com.playmate.entity.Activity.ActivityType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ActivityRepository extends JpaRepository<Activity, Long> {
    
    List<Activity> findByStatus(ActivityStatus status);
    
    List<Activity> findByType(ActivityType type);
    
    List<Activity> findByStatusAndType(ActivityStatus status, ActivityType type);
    
    @Query("SELECT a FROM Activity a WHERE a.status = 'ACTIVE' AND a.startTime <= :now AND a.endTime >= :now ORDER BY a.sortOrder ASC")
    List<Activity> findActiveActivities(@Param("now") LocalDateTime now);
    
    @Query("SELECT a FROM Activity a WHERE a.status = 'ACTIVE' ORDER BY a.sortOrder ASC")
    List<Activity> findActiveActivitiesOrderBySort();
    
    @Query("SELECT a FROM Activity a WHERE a.startTime <= :now AND a.endTime >= :now ORDER BY a.sortOrder ASC")
    List<Activity> findOngoingActivities(@Param("now") LocalDateTime now);
    
    @Query("SELECT a FROM Activity a WHERE a.endTime < :now AND a.status != 'ENDED' AND a.status != 'CANCELLED'")
    List<Activity> findExpiredActivities(@Param("now") LocalDateTime now);
    
    @Query("SELECT COUNT(a) FROM Activity a WHERE a.status = 'ACTIVE'")
    long countActiveActivities();
    
    @Query("SELECT a FROM Activity a WHERE a.participantLimit IS NOT NULL AND a.participantCount >= a.participantLimit AND a.status = 'ACTIVE'")
    List<Activity> findFullActivities();
}