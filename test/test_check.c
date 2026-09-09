#include "check.h"
#include <criterion/criterion.h>
#include <signal.h>

Test(check_macros, test_abort, .signal = SIGABRT) { ABORT(); }

Test(check_macros, test_check_fail, .signal = SIGABRT) {
  CHECK(false, "No argument");
}

Test(check_macros, test_check_fail__arg, .signal = SIGABRT) {
  CHECK(false, "Expect %s", "true");
}

Test(check_macros, test_check_pass) { CHECK(true, "No argument"); }

Test(check_macros, test_check_pass_arg) {
  CHECK(true, "Expect %s", "true");
}
