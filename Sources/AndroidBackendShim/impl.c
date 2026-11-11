#include "header.h"

void android_log(int priority, const char *tag, const char *message) {
    __android_log_write(priority, tag, message);
}
