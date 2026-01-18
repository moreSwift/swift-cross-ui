#include <android/log.h>

// We use this forward declaration to call the app's main function without ever
// being given a handle to it.
int main(void);

void android_log(int priority, const char *namespace, const char *message);
