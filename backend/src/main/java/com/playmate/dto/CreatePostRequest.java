package com.playmate.dto;

import com.playmate.entity.PostType;
import lombok.Data;
import java.util.List;

public class CreatePostRequest {
    private String content;
    private List<String> images;
    private List<String> tags;
    private PostType type;
    private String location;
    private String gameName;
    private String videoUrl;

    // Manual getters and setters
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public List<String> getImages() { return images; }
    public void setImages(List<String> images) { this.images = images; }
    
    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }
    
    public PostType getType() { return type; }
    public void setType(PostType type) { this.type = type; }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public String getGameName() { return gameName; }
    public void setGameName(String gameName) { this.gameName = gameName; }
    
    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }
}