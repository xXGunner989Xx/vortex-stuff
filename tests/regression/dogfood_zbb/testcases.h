#pragma once

#include <iostream>
#include <math.h>
#include <limits>

class ITestCase {
public:
  ITestCase() {}
  virtual ~ITestCase() {}

  virtual void setup(int n, void* src1, void* src2)  = 0;  
  virtual int verify(int n, void* dst, const void* src1, const void* src2) = 0;
};

class Test_ROR : public ITestCase {
public:

  void setup(int n, void* src1, void* src2) override {
    auto a = (uint32_t*)src1;
    auto b = (uint32_t*)src2;
  }
  
  int verify(int n, void* dst, const void* src1, const void* src2) override {
    int errors = 0;
    auto a = (uint32_t*)src1;
    auto b = (uint32_t*)src2;
    auto c = (uint32_t*)dst;
    for (int i = 0; i < n; ++i) {
      
      auto ref = ((a[i] >> (b[i] & 0b1111)) | (a[i] << (32 - (b[i] & 0b1111)))); 
      if (c[i] != ref) {
        std::cout << "error at result #" << i << ": expected=" << ref << ", actual=" << c[i] << ", a=" << a[i] << ", b=" << b[i] << std::endl;
        ++errors;
      }
    }
    return errors;
  }
};

class Test_ROL : public ITestCase {
public:

  void setup(int n, void* src1, void* src2) override {
    auto a = (uint32_t*)src1;
    auto b = (uint32_t*)src2;
  }
  
  int verify(int n, void* dst, const void* src1, const void* src2) override {
    int errors = 0;
    auto a = (uint32_t*)src1;
    auto b = (uint32_t*)src2;
    auto c = (uint32_t*)dst;
    for (int i = 0; i < n; ++i) {
      
      auto ref = ((a[i] << (b[i] & 0b1111)) | (a[i] >> (32 - (b[i] & 0b1111)))); 
      if (c[i] != ref) {
        std::cout << "error at result #" << i << ": expected=" << ref << ", actual=" << c[i] << ", a=" << a[i] << ", b=" << b[i] << std::endl;
        ++errors;
      }
    }
    return errors;
  }
};