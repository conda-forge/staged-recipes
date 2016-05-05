#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/task_scheduler_init.h"
#include <iostream>
#include <vector>

struct mytask {
  mytask(size_t n)
    :_n(n)
  {}
  void operator()() {
    for (int i=0;i<1000000;++i) {}  // Deliberately run slow
    std::cerr << "[" << _n << "]";
  }
  size_t _n;
};

struct executor
{
  executor(std::vector<mytask>& t)
    :_tasks(t)
  {}
  executor(executor& e,tbb::split)
    :_tasks(e._tasks)
  {}

  void operator()(const tbb::blocked_range<size_t>& r) const {
    for (size_t i=r.begin();i!=r.end();++i)
      _tasks[i]();
  }

  std::vector<mytask>& _tasks;
};

int main(int,char**) {

  tbb::task_scheduler_init init;  // Automatic number of threads
  // tbb::task_scheduler_init init(2);  // Explicit number of threads

  std::vector<mytask> tasks;
  for (int i=0;i<1000;++i)
    tasks.push_back(mytask(i));

  executor exec(tasks);
  tbb::parallel_for(tbb::blocked_range<size_t>(0,tasks.size()),exec);
  std::cerr << std::endl;

  return 0;
}