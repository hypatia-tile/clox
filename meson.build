project(
  'clox',
  'c',
  meson_version : '>= 1.10.2',
  version : '0.1',
  default_options : [
    'warning_level=3',
    'werror=true',
    'c_std=c23',
  ],
)

criterion_dep = dependency('criterion', required : true)

deps = [
]

clox_static_lib = static_library(
  'clox_static_lib',
  'src/opcode.c',
  include_directories : ['src'],
  dependencies : deps
)

sources = [
  'src/main.c',
]

exe = executable(
  'clox',
  'src/main.c',
  link_with : clox_static_lib
)

test_sources = [
  'test/test_opcode.c',
]

test_exe = executable(
  'clox_test',
  test_sources,
  include_directories : ['src', 'test'],
  link_with : clox_static_lib,
  dependencies  : [criterion_dep],
)

test('basic', test_exe)
