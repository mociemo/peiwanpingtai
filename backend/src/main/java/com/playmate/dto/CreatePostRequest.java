package com.playmate.dto;

import com.playmate.entity.PostType;
import lombok.Data;
import java.util.List;

@Data
public class CreatePostRequest {
    private String content;
    private List<String> images;
    private List<String> tags;
    private PostType type;
    private String location;
    private String gameName;
    private String videoUrl;
}