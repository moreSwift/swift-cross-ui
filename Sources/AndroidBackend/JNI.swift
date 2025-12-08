import Android

struct JNIError: Error {
    var message: String
}

struct JNIEnvWrapper {
    var env: UnsafeMutablePointer<JNIEnv?>

    private func check<T>(_ value: T?, _ message: String) throws(JNIError) -> T {
        if let value {
            return value
        } else {
            throw JNIError(message: message)
        }
    }

    func getObjectClass(_ object: jobject) throws(JNIError) -> jclass {
        try check(
            env.pointee!.pointee.GetObjectClass(env, object),
            "Failed to get object class"
        )
    }

    func findClass(_ name: String) throws(JNIError) -> jclass {
        try check(
            env.pointee!.pointee.FindClass(env, name),
            "Failed to find class named \(name)"
        )
    }

    func getMethodID(_ cls: jclass, _ name: String, _ signature: String) throws(JNIError) -> jmethodID {
        try check(
            env.pointee!.pointee.GetMethodID(env, cls, name, signature),
            "Failed to get method id of \(name) with signature \(signature)"
        )
    }

    func getStaticMethodID(_ cls: jclass, _ name: String, _ signature: String) throws(JNIError) -> jmethodID {
        try check(
            env.pointee!.pointee.GetStaticMethodID(env, cls, name, signature),
            "Failed to get static method id of \(name) with signature \(signature)"
        )
    }

    func getFieldID(_ cls: jclass, _ name: String, _ signature: String) throws(JNIError) -> jfieldID {
        try check(
            env.pointee!.pointee.GetFieldID(env, cls, name, signature),
            "Failed to get field id of \(name) with signature \(signature)"
        )
    }

    func getIntField(_ cls: jclass, _ field: jfieldID) -> Int32 {
        env.pointee!.pointee.GetIntField(env, cls, field)
    }

    func setIntField(_ cls: jclass, _ field: jfieldID, _ value: Int32) {
        env.pointee!.pointee.SetIntField(env, cls, field, value)
    }

    func callVoidMethod(_ object: jobject, _ method: jmethodID, _ arguments: [jvalue]) {
        env.pointee!.pointee.CallVoidMethodA(env, object, method, arguments)
    }

    func callIntMethod(_ object: jobject, _ method: jmethodID, _ arguments: [jvalue]) -> Int32 {
        env.pointee!.pointee.CallIntMethodA(env, object, method, arguments)
    }

    func callObjectMethod(_ object: jobject, _ method: jmethodID, _ arguments: [jvalue]) throws(JNIError) -> jobject {
        try check(
            env.pointee!.pointee.CallObjectMethodA(env, object, method, arguments),
            "Failed to call object method"
        )
    }

    func newObject(_ cls: jclass, _ ctorID: jmethodID, _ arguments: [jvalue]) throws(JNIError) -> jobject {
        try check(
            env.pointee!.pointee.NewObjectA(env, cls, ctorID, arguments),
            "Failed to initialize object"
        )
    }

    func newStringUTF(_ string: String) throws(JNIError) -> jstring {
        try check(
            env.pointee!.pointee.NewStringUTF(env, string),
            "Failed to convert '\(string)' to java string"
        )
    }
}
