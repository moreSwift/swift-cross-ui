package dev.swiftcrossui.androidbackend

import android.graphics.RadialGradient
import android.graphics.Shader

class CustomRadialGradient(
    centerX: Float,
    centerY: Float,
    radius: Float,
    colors: IntArray,
    stops: FloatArray?,
    tileMode: Shader.TileMode
) : RadialGradient(centerX, centerY, radius, colors, stops, tileMode)
