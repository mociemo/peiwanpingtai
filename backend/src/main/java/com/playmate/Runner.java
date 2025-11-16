package com.playmate;

import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;
import java.util.List;

public class Runner {
    public static void main(String[] args) throws Exception {
        // 获取target目录
        File targetDir = new File("target");
        
        // 获取所有依赖的jar文件
        File libDir = new File(targetDir, "lib");
        List<URL> urls = new ArrayList<>();
        
        // 添加classes目录
        urls.add(new File(targetDir, "classes").toURI().toURL());
        
        // 如果lib目录存在，添加所有jar文件
        if (libDir.exists()) {
            File[] jars = libDir.listFiles((dir, name) -> name.endsWith(".jar"));
            if (jars != null) {
                for (File jar : jars) {
                    urls.add(jar.toURI().toURL());
                }
            }
        }
        
        // 创建类加载器
        URLClassLoader classLoader = new URLClassLoader(urls.toArray(new URL[0]), Runner.class.getClassLoader());
        
        // 设置当前线程的上下文类加载器
        Thread.currentThread().setContextClassLoader(classLoader);
        
        // 加载并运行主应用类
        Class<?> appClass = classLoader.loadClass("com.playmate.PlaymateApplication");
        appClass.getMethod("main", String[].class).invoke(null, (Object) new String[]{});
    }
}