#include "check.h"
#include <criterion/criterion.h>
#include <signal.h>

Test(check_macros, check_abort, .signal = SIGABRT) { ABORT(); }
