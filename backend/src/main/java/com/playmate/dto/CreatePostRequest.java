package com.playmate.dto;

import com.playmate.entity.PostType;
import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;

@Data
public class CreatePostRequest {
    @NotBlank(message = "动态内容不能为空")
    @Size(max = 2000, message = "动态内容不能超过2000个字符")
    private String content;
    
    private List<String> images;
    private List<String> tags;
    private PostType type;
    private String location;
    private String gameName;
    private String videoUrl;
}