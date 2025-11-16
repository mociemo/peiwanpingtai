package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.ShareRequest;
import com.playmate.dto.ShareResponse;
import com.playmate.service.ShareService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/share")
public class ShareController {

    @Autowired
    private ShareService shareService;

    /**
     * 生成分享链接
     */
    @PostMapping("/generate")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<ShareResponse>> generateShareLink(@RequestBody ShareRequest request) {
        try {
            ShareResponse response = shareService.generateShareLink(request);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取分享内容
     */
    @GetMapping("/{shareId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSharedContent(@PathVariable String shareId) {
        try {
            Map<String, Object> content = shareService.getSharedContent(shareId);
            return ResponseEntity.ok(ApiResponse.success(content));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 记录分享行为
     */
    @PostMapping("/record")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<String>> recordShareAction(@RequestBody ShareRequest request) {
        try {
            shareService.recordShareAction(request);
            return ResponseEntity.ok(ApiResponse.success("记录成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取用户的分享统计
     */
    @GetMapping("/stats/{userId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getShareStats(@PathVariable String userId) {
        try {
            Map<String, Object> stats = shareService.getShareStats(userId);
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}