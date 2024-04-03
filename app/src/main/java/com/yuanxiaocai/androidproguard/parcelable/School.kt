package com.yuanxiaocai.androidproguard.parcelable

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

/**
 *
 *
 * @author 猿小蔡
 * @since 2024/4/3
 */
@Parcelize
data class School(
    val street: String,
    val city: String,
) : Parcelable