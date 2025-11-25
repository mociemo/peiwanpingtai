package com.playmate.service;

import com.playmate.dto.CreatePostRequest;
import com.playmate.dto.PostResponse;
import com.playmate.entity.PostType;
import com.playmate.entity.PostStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = com.playmate.PlaymateApplication.class)
public class PostServiceIntegrationTest {

    @Autowired
    private PostService postService;

    @Test
    public void testCreateAndSearchPost() {
        Long userId = 1L;
        CreatePostRequest req = new CreatePostRequest();
        req.setContent("This is a test post about chess");
        req.setGameName("Chess");
        req.setType(PostType.TEXT);

        PostResponse created = postService.createPost(userId, req);
        assertNotNull(created);
        assertEquals("This is a test post about chess", created.getContent());

        Page<PostResponse> searchByKeyword = postService.searchPosts("chess", PostStatus.PUBLISHED,
                PageRequest.of(0, 10));
        assertTrue(searchByKeyword.getTotalElements() >= 1);

        Page<PostResponse> searchByGame = postService.searchPosts(null, "Chess", PageRequest.of(0, 10));
        assertTrue(searchByGame.getTotalElements() >= 1);

        Page<PostResponse> searchBoth = postService.searchPosts("chess", "Chess", PageRequest.of(0, 10));
        assertTrue(searchBoth.getTotalElements() >= 1);
    }
}
