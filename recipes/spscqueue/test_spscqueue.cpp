#include <rigtorp/SPSCQueue.h>
#include <iostream>
#include <thread>
#include <chrono>
#include <atomic>
#include <cassert>

// Test basic functionality
void test_basic_operations() {
    std::cout << "Testing basic operations..." << std::endl;
    
    rigtorp::SPSCQueue<int> queue(10);
    
    // Test empty queue
    assert(queue.empty());
    assert(queue.size() == 0);
    assert(queue.capacity() == 10);
    assert(queue.front() == nullptr);
    
    // Test push operations
    queue.push(1);
    queue.push(2);
    queue.emplace(3);
    
    assert(!queue.empty());
    assert(queue.size() == 3);
    
    // Test front and pop operations
    auto* front = queue.front();
    assert(front != nullptr);
    assert(*front == 1);
    
    queue.pop();
    assert(queue.size() == 2);
    
    front = queue.front();
    assert(*front == 2);
    queue.pop();
    
    front = queue.front();
    assert(*front == 3);
    queue.pop();
    
    assert(queue.empty());
    assert(queue.front() == nullptr);
    
    std::cout << "Basic operations test passed!" << std::endl;
}

// Test try_push functionality
void test_try_push() {
    std::cout << "Testing try_push operations..." << std::endl;
    
    rigtorp::SPSCQueue<int> queue(3);  // Small queue to test full condition
    
    // Fill the queue
    assert(queue.try_push(1));
    assert(queue.try_push(2));
    assert(queue.try_push(3));
    
    // Queue should be full now
    assert(!queue.try_push(4));  // Should fail
    
    // Pop one item and try again
    queue.pop();
    assert(queue.try_push(4));  // Should succeed now
    
    std::cout << "try_push test passed!" << std::endl;
}

// Test with custom types
struct TestStruct {
    int value;
    std::string name;
    
    TestStruct() : value(0), name("default") {}
    TestStruct(int v, const std::string& n) : value(v), name(n) {}
    
    bool operator==(const TestStruct& other) const {
        return value == other.value && name == other.name;
    }
};

void test_custom_types() {
    std::cout << "Testing custom types..." << std::endl;
    
    rigtorp::SPSCQueue<TestStruct> queue(5);
    
    // Test emplace with custom constructor
    queue.emplace(42, "test");
    
    auto* front = queue.front();
    assert(front != nullptr);
    assert(front->value == 42);
    assert(front->name == "test");
    
    queue.pop();
    
    // Test push with copy
    TestStruct obj(99, "copy");
    queue.push(obj);
    
    front = queue.front();
    assert(*front == obj);
    
    std::cout << "Custom types test passed!" << std::endl;
}

// Test producer-consumer scenario
void test_producer_consumer() {
    std::cout << "Testing producer-consumer scenario..." << std::endl;
    
    rigtorp::SPSCQueue<int> queue(1000);
    std::atomic<bool> done{false};
    std::atomic<int> consumed_count{0};
    const int total_items = 10000;
    
    // Consumer thread
    std::thread consumer([&queue, &done, &consumed_count]() {
        int count = 0;
        while (!done.load() || queue.front() != nullptr) {
            auto* front = queue.front();
            if (front != nullptr) {
                assert(*front == count);
                queue.pop();
                count++;
            } else {
                std::this_thread::yield();
            }
        }
        consumed_count.store(count);
    });
    
    // Producer thread (main thread)
    for (int i = 0; i < total_items; ++i) {
        while (!queue.try_push(i)) {
            std::this_thread::yield();
        }
    }
    
    done.store(true);
    consumer.join();
    
    assert(consumed_count.load() == total_items);
    assert(queue.empty());
    
    std::cout << "Producer-consumer test passed!" << std::endl;
}

// Performance test
void test_performance() {
    std::cout << "Running performance test..." << std::endl;
    
    const int iterations = 1000000;
    rigtorp::SPSCQueue<int> queue(1024);
    
    auto start = std::chrono::high_resolution_clock::now();
    
    // Producer-consumer in tight loop
    std::thread consumer([&queue]() {
        for (int i = 0; i < iterations; ++i) {
            while (queue.front() == nullptr) {
                std::this_thread::yield();
            }
            queue.pop();
        }
    });
    
    for (int i = 0; i < iterations; ++i) {
        while (!queue.try_push(i)) {
            std::this_thread::yield();
        }
    }
    
    consumer.join();
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    double ops_per_sec = (2.0 * iterations * 1000000.0) / duration.count();
    std::cout << "Performance: " << ops_per_sec / 1000000.0 << " million ops/sec" << std::endl;
}

int main() {
    try {
        std::cout << "SPSCQueue Test Suite" << std::endl;
        std::cout << "====================" << std::endl;
        
        test_basic_operations();
        test_try_push();
        test_custom_types();
        test_producer_consumer();
        test_performance();
        
        std::cout << std::endl << "All tests passed successfully!" << std::endl;
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "Test failed with exception: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "Test failed with unknown exception" << std::endl;
        return 1;
    }
}