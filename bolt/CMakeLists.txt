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

add_subdirectory(buffer)
add_subdirectory(common)
add_subdirectory(core)
add_subdirectory(serializers)
add_subdirectory(type)
add_subdirectory(vector)
add_subdirectory(row)
add_subdirectory(version)
add_subdirectory(flag_definitions)

if(${BOLT_ENABLE_SPARK_COMPATIBLE})
  add_subdirectory(shuffle)
endif()

if(${ENABLE_BOLT_JIT})
  add_subdirectory(jit)
endif()

if(NOT BOLT_ENABLE_BYTEDANCE_INTERNAL)
  add_subdirectory(external/hdfs)
  include_directories(SYSTEM external)
endif()

# examples depend on expression
if(${BOLT_ENABLE_EXAMPLES} AND ${BOLT_ENABLE_EXPRESSION})
  add_subdirectory(examples)
endif()

if(${BOLT_ENABLE_BENCHMARKS} OR ${BOLT_ENABLE_BENCHMARKS_BASIC})
  add_subdirectory(benchmarks)
endif()

if(${BOLT_ENABLE_EXPRESSION})
  add_subdirectory(expression)
endif()

if(${BOLT_ENABLE_PARSE})
  add_subdirectory(parse)
endif()

# hive connector depends on dwio
if(${BOLT_ENABLE_HIVE_CONNECTOR})
  add_subdirectory(dwio)
endif()

if(${BOLT_ENABLE_TPCH_CONNECTOR})
  add_subdirectory(tpch/gen)
endif()

add_subdirectory(functions) # depends on md5 (postgresql)
add_subdirectory(connectors)

if(${BOLT_ENABLE_EXEC})
  add_subdirectory(exec)
endif()

if(${BOLT_ENABLE_DUCKDB})
  add_subdirectory(duckdb)
endif()

# substrait converter
if(${BOLT_ENABLE_SUBSTRAIT})
  add_subdirectory(substrait)
endif()

if(${BOLT_BUILD_TESTING})
  add_subdirectory(tool)
endif()

if(${BOLT_ENABLE_TORCH})
  add_subdirectory(torch)
endif()

if(${BOLT_ENABLE_CUDF})
  add_subdirectory(cudf)
endif()

if(${BOLT_BUILD_PYTHON_PACKAGE})
  add_subdirectory(python)
endif()
