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

add_project_arguments('-Wwrite-strings', language : ['c'])

clox_static_lib = static_library(
  'clox_static_lib',
  'src/opcode.c',
)

clox_dep = declare_dependency(
  link_with : clox_static_lib,
  include_directories : ['src'],
)

criterion_dep = dependency('criterion', required : true)

sources = [
  'src/main.c',
]

exe = executable(
  'clox',
  sources,
  dependencies : [clox_dep],
)

test_sources = [
  'test/test_opcode.c',
  'test/test_check.c',
]

test_exe = executable(
  'clox_test',
  test_sources,
  dependencies  : [
    clox_dep,
    criterion_dep
  ],
)

test('basic', test_exe)
