# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# --------------------------------------------------------------------------
# Copyright (c) ByteDance Ltd. and/or its affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# This file has been modified by ByteDance Ltd. and/or its affiliates on
# 2025-11-11.
#
# Original file was released under the Apache License 2.0,
# with the full license text available at:
#     http://www.apache.org/licenses/LICENSE-2.0
#
# This modified file is released under the same license.
# --------------------------------------------------------------------------


add_subdirectory(utils)

add_executable(
  bolt_dwio_common_test
  BitConcatenationTest.cpp
  BitPackDecoderTest.cpp
  ChainedBufferTests.cpp
  ColumnSelectorTests.cpp
  DataBufferTests.cpp
  DecoderUtilTest.cpp
  ExecutorBarrierTest.cpp
  LocalFileSinkTest.cpp
  LoggedExceptionTest.cpp
  ParallelForTest.cpp
  RangeTests.cpp
  ReadFileInputStreamTests.cpp
  ReaderTest.cpp
  RetryTests.cpp
  ScanSpecTest.cpp
  TestBufferedInput.cpp
  TypeTests.cpp
  WriterTest.cpp)
add_test(bolt_dwio_common_test bolt_dwio_common_test)
target_link_libraries(
  bolt_dwio_common_test
  bolt_dwio_common_test_utils
  bolt_temp_path
  bolt_vector_test_lib
  bolt_dwio_common
  ${FOLLY_WITH_DEPENDENCIES}
  arrow::arrow
  ${TEST_LINK_LIBS}
  gflags::gflags
  GTest::gtest
  GTest::gtest_main
  GTest::gmock
  glog::glog
  fmt::fmt)

add_executable(bolt_dwio_common_data_buffer_benchmark DataBufferBenchmark.cpp)

target_link_libraries(
  bolt_dwio_common_data_buffer_benchmark bolt_dwio_common bolt_memory
  bolt_dwio_common_exception
  ${FOLLY}
  ${FOLLY_BENCHMARK}
  arrow::arrow
  )

add_executable(bolt_dwio_common_int_decoder_benchmark IntDecoderBenchmark.cpp)
target_link_libraries(
  bolt_dwio_common_int_decoder_benchmark
  bolt_dwio_common_exception
  bolt_exception
  bolt_dwio_dwrf_common
  ${FOLLY}
  ${FOLLY_BENCHMARK}
  arrow::arrow)

add_library(bolt_e2e_filter_test_base E2EFilterTestBase.cpp)

target_link_libraries(
  bolt_e2e_filter_test_base
  bolt_functions_prestosql
  bolt_parse_parser
  bolt_vector_test_lib
  bolt_dwio_common
  ${FOLLY_WITH_DEPENDENCIES}
  arrow::arrow
  ${FMT}
  ${LZ4}
  ${LZO}
  ${ZSTD}
  ${ZLIB_LIBRARIES}
  ${TEST_LINK_LIBS})

if(BOLT_ENABLE_ARROW AND BOLT_ENABLE_BENCHMARKS)
  add_subdirectory(Lemire/FastPFor)
  add_executable(bolt_dwio_common_bitpack_decoder_benchmark
                 BitPackDecoderBenchmark.cpp)

  target_compile_options(bolt_dwio_common_bitpack_decoder_benchmark
                         PRIVATE -Wno-deprecated-declarations)

  target_link_libraries(
    bolt_dwio_common_bitpack_decoder_benchmark
    bolt_dwio_common
    arrow::arrow
    bolt_fastpforlib
    duckdb::duckdb
    ${FOLLY}
    ${FOLLY_BENCHMARK})
endif()
