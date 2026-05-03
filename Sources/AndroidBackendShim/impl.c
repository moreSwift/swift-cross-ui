#include "header.h"

void android_log(int priority, const char *namespace, const char *message) {
    __android_log_write(priority, namespace, message);
}
