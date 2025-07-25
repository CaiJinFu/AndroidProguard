# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
#############################################
#
# 基础混淆配置
#
#############################################


####################基本混淆指令的设置####################
#不混淆指定的包名。有多个包名可以用逗号隔开。包名可以包含 ？、*、** 通配符，还可以在包名前加上 ! 否定符。只有开启混淆时可用。如果你使用了 mypackage.MyCalss.class.getResource(""); 这些代码获取类目录的代码，就会出现问题。需要使用 -keeppackagenames 保留包名。
-keeppackagenames com.yuanxiaocai.androidproguard
#指定类、方法及字段混淆后时用的混淆字典。默认使用 ‘a’，’b’ 等短名称作为混淆后的名称。
-obfuscationdictionary dictionary.txt
# 打印 usage
-printusage ../mapping/usage.txt
# 打印 mapping
-printmapping ../mapping/mapping.txt
# 打印 seeds
-printseeds ../mapping/seeds.txt
# 打印 configuration
-printconfiguration ../mapping/configuration
# If you keep the line number information, uncomment this to
# hide the original source file name.
-renamesourcefileattribute SourceFile
#关闭优化功能。默认情况下启用优化。
-dontoptimize
#关闭压缩功能。默认情况下，会开启压缩;
#-dontshrink
# 代码混淆压缩比，在0~7之间，默认为5，一般不做修改
-optimizationpasses 5
# 混合时不使用大小写混合，混合后的类名为小写
-dontusemixedcaseclassnames
# 优化时允许访问并修改有修饰符的类和类的成员
-allowaccessmodification
# 指定不忽略非公共库的类
-dontskipnonpubliclibraryclasses
# 指定不忽略非公共库的类成员
-dontskipnonpubliclibraryclassmembers
# 记录日志，使我们的项目混淆后产生映射文件（类名->混淆后类名）
-verbose
# 忽略警告，避免打包时某些警告出现，没有这个的话，构建报错
-ignorewarnings
# 不做预校验，preverify是proguard的四个步骤之一，Android不需要preverify，去掉这一步能够加快混淆速度。
-dontpreverify
# 不混淆Annotation(保留注解)
-keepattributes *Annotation*,InnerClasses
# 避免混淆泛型
-keepattributes Signature
# 抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable
# 指定混淆是采用的算法，后面的参数是一个过滤器
# 这个过滤器是谷歌推荐的算法，一般不做更改
-optimizations !code/simplification/cast,!field/*,!class/merging/*
####################Android开发中需要保留的公共部分####################
# 保留support下的所有类及其内部类
-keep class android.support.** {*;}
# 保留继承的support类
-keep public class * extends android.support.v4.**
-keep public class * extends android.support.v7.**
-keep public class * extends android.support.annotation.**
# AndroidX混淆
-keep class com.google.android.material.** {*;}
-keep class androidx.** {*;}
-keep public class * extends androidx.**
-keep interface androidx.** {*;}
-dontwarn com.google.android.material.**
-dontnote com.google.android.material.**
-dontwarn androidx.**
# 保留所有 ViewBinding 类
-keep class * implements androidx.viewbinding.ViewBinding {
    *;
}
-keep class * extends androidx.viewbinding.ViewBinding {
    public static final ** inflate(**);
    public static * bind(android.view.View);
}
# 保留R下面的资源
-keep class **.R$* {*;}
# 保留本地native方法不被混淆
-keepclasseswithmembernames class * {
    native <methods>;
}
# 保留Activity中参数类型为View的所有方法
-keepclassmembers class * extends android.app.Activity{
    public void *(android.view.View);
}
# 保留枚举类不被混淆
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
# 保留Parcelable序列化类不被混淆
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
# 保留Serializable序列化的类不被混淆
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
# 保留我们自定义控件（继承自View）不被混淆
-keep public class * extends android.view.View{
    *** get*();
    void set*(***);
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}
# 对于带有回调函数的onXXEvent、**On*Listener的，不能被混淆
-keepclassmembers class * {
    void *(**On*Event);
    void *(**On*Listener);
}
#############################################
#
# 自定义的混淆配置（根据项目需求进行定义）
#
#############################################
# 不混淆log
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
#############################################
#
# 第三方库的混淆配置（根据第三方库官网添加混淆代码）
#
#############################################
# OkHttp3
-dontwarn okhttp3.logging.**
-keep class okhttp3.internal.**{*;}
-dontwarn okio.**
# Retrofit
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions
# RxJava RxAndroid
-dontwarn sun.misc.**
-keepclassmembers class rx.internal.util.unsafe.*ArrayQueue*Field* {
    long producerIndex;
    long consumerIndex;
}
# Glide图片库
-keep class com.bumptech.glide.**{*;}
#混淆命令 gradlew makeJar
#本库的混淆
#保持BuildConfig不被混淆(因为混淆之后就无法在导出jar时排除该类)
-keep class com.yuanxiaocai.androidproguard.BuildConfig{ *; }
#不混淆某个包所有的类
-keep class com.yuanxiaocai.androidproguard.bean.** { *; }