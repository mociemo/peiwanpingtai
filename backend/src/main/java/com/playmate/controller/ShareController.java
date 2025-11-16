package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.ShareRequest;
import com.playmate.dto.ShareResponse;
import com.playmate.service.ShareService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/share")
public class ShareController {

    @Autowired
    private ShareService shareService;

    @PostMapping
    public ResponseEntity<ApiResponse> createShare(@RequestBody ShareRequest request) {
        ShareResponse response = shareService.createShare(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse> getUserShares(@PathVariable String userId,
                                                     @RequestParam(defaultValue = "0") int page,
                                                     @RequestParam(defaultValue = "10") int size) {
        List<ShareResponse> shares = shareService.getUserShares(userId, page, size);
        return ResponseEntity.ok(ApiResponse.success(shares));
    }

    @GetMapping("/stats/{userId}")
    public ResponseEntity<ApiResponse> getShareStats(@PathVariable String userId) {
        return ResponseEntity.ok(ApiResponse.success(shareService.getShareStats(Long.valueOf(userId))));
    }
}