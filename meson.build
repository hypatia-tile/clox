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

dependencies = [
]

sources = [
  'src/main.c',
]

exe = executable(
  'clox',
  sources,
  dependencies : dependencies,
  install : true,
)

test_sources = [
  'src/main.c',
]
test_exe = executable(
  'clox_test',
  test_sources,
  dependencies  : [criterion_dep],
)

test('basic', test_exe)
