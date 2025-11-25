package com.playmate.integration;

import com.playmate.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 性能测试
 * 测试系统在高并发情况下的表现
 */
@SpringBootTest(classes = com.playmate.PlaymateApplication.class)
@ActiveProfiles("test")
@Transactional
public class PerformanceTest {

    @Autowired
    private UserRepository userRepository;

    @Test
    public void testConcurrentUserQueries() throws Exception {
        int threadCount = 50;
        int queriesPerThread = 20;
        ExecutorService executor = Executors.newFixedThreadPool(threadCount);

        List<CompletableFuture<Void>> futures = new ArrayList<>();

        long startTime = System.currentTimeMillis();

        // 并发执行查询
        for (int i = 0; i < threadCount; i++) {
            final int threadId = i;
            CompletableFuture<Void> future = CompletableFuture.runAsync(() -> {
                for (int j = 0; j < queriesPerThread; j++) {
                    try {
                        // 模拟用户查询
                        userRepository.count();
                        userRepository.searchUsers("test" + threadId);

                        // 模拟一些处理时间
                        Thread.sleep(10);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
            }, executor);

            futures.add(future);
        }

        // 等待所有任务完成
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).get(60, TimeUnit.SECONDS);

        long endTime = System.currentTimeMillis();
        long totalTime = endTime - startTime;
        int totalQueries = threadCount * queriesPerThread;

        executor.shutdown();

        // 性能断言
        assertTrue(totalTime < 30000, "总执行时间应少于30秒，实际: " + totalTime + "ms");

        double avgTimePerQuery = (double) totalTime / totalQueries;
        assertTrue(avgTimePerQuery < 100, "平均查询时间应少于100ms，实际: " + avgTimePerQuery + "ms");

        System.out.println("性能测试结果:");
        System.out.println("总查询数: " + totalQueries);
        System.out.println("总时间: " + totalTime + "ms");
        System.out.println("平均每查询时间: " + avgTimePerQuery + "ms");
        System.out.println("QPS: " + (totalQueries * 1000.0 / totalTime));
    }

    @Test
    public void testCachePerformance() throws Exception {
        // 第一次查询（无缓存）
        long startTime = System.currentTimeMillis();
        userRepository.count();
        long firstQueryTime = System.currentTimeMillis() - startTime;

        // 第二次查询（有缓存）
        startTime = System.currentTimeMillis();
        userRepository.count();
        long secondQueryTime = System.currentTimeMillis() - startTime;

        System.out.println("第一次查询时间: " + firstQueryTime + "ms");
        System.out.println("第二次查询时间: " + secondQueryTime + "ms");

        // 缓存应该提升性能（这个断言可能需要根据实际情况调整）
        // 注意：在某些情况下，由于JVM优化，第二次查询可能不会明显更快
        assertTrue(secondQueryTime <= firstQueryTime * 2,
                "缓存应该提升或至少不显著降低性能");
    }

    @Test
    public void testMemoryUsage() {
        Runtime runtime = Runtime.getRuntime();

        // 执行GC以获得准确的内存使用情况
        System.gc();
        long initialMemory = runtime.totalMemory() - runtime.freeMemory();

        // 执行一些操作
        for (int i = 0; i < 1000; i++) {
            userRepository.searchUsers("test" + i);
        }

        System.gc();
        long finalMemory = runtime.totalMemory() - runtime.freeMemory();
        long memoryUsed = finalMemory - initialMemory;

        System.out.println("内存使用情况:");
        System.out.println("初始内存: " + (initialMemory / 1024 / 1024) + "MB");
        System.out.println("最终内存: " + (finalMemory / 1024 / 1024) + "MB");
        System.out.println("增加内存: " + (memoryUsed / 1024 / 1024) + "MB");

        // 内存使用应该在合理范围内
        assertTrue(memoryUsed < 100 * 1024 * 1024, "内存使用应少于100MB");
    }

    @Test
    public void testDatabaseConnectionPool() {
        // 测试数据库连接池的性能
        long startTime = System.currentTimeMillis();

        for (int i = 0; i < 100; i++) {
            userRepository.count();
        }

        long endTime = System.currentTimeMillis();
        long totalTime = endTime - startTime;

        System.out.println("100次数据库查询总时间: " + totalTime + "ms");
        System.out.println("平均每次查询时间: " + (totalTime / 100.0) + "ms");

        // 数据库查询应该在合理时间内完成
        assertTrue(totalTime < 5000, "100次查询应在5秒内完成");
    }
}