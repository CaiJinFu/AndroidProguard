# **混淆文件概述**

代码混淆是将代码转换成难以阅读和理解的形式，以保护源代码和减少应用体积的过程。以下是Android开发中常用的混淆配置文件及其作用：

- **proguard-android.txt**: 这是默认的混淆规则集，位于`ANDROID_SDK\tools\proguard`目录。它提供了基本的代码混淆和优化设置。
- **proguard-android-optimize.txt**: 此文件包含进一步压缩代码的混淆规则，虽然能更有效地减小应用体积，但处理时间较长，同样位于`ANDROID_SDK\tools\proguard`目录。
- **proguard-rules.pro**: 用户自定义的混淆规则文件，可以根据项目需求进行调整。
- **usage.txt**: 记录了在混淆过程中被删除的类、方法和字段。
- **mapping.txt**: 存储了混淆前后的类名、方法名和字段名的映射信息，对于错误追踪和调试至关重要。
- **seeds.txt**: 包含了被Keep规则保留的类、方法和字段，用于验证Keep规则的正确性。
- **configuration.txt**：配置的所有的混淆规则，在目录`app/build/outputs/mapping/release/configuration.txt`

# **示例配置文件内容**

## consumer-rules.pro

**consumerProguardFiles配置 :** 在Android项目的构建配置中，`consumerProguardFiles`是一个关键的配置项，它用于指定发布AAR（Android Archive）依赖库时所附带的混淆规则文件。以下是对这一配置的详细说明：

1. **AAR内嵌混淆规则**：此配置允许开发者在AAR库中嵌入专门的ProGuard规则文件。这些规则文件将直接包含在发布的AAR包内，确保了库的混淆规则与库本身一同分发。
2. **应用程序项目继承规则**：当其他应用程序项目依赖于这个AAR时，如果该项目启用了ProGuard或R8进行代码混淆，它将自动继承并应用这些预设的ProGuard规则。这样可以保证AAR库在最终的应用中以预期的方式进行混淆。
3. **定制化混淆与排除**：通过`consumerProguardFiles`配置，库开发者可以精确地指定哪些代码应该被保留（例如，公开的API或者需要暴露给其他应用的组件），以及哪些代码可以被安全地删除或混淆。这为库的发布提供了更高级别的定制化和控制。
4. **项目类型的适用性**：需要注意的是，`consumerProguardFiles`配置仅适用于库项目（如AAR或JAR），并不适用于普通的应用程序项目。在应用程序项目中，这一配置将被忽略，开发者需要在应用的构建配置中直接管理混淆规则。

```Java
defaultConfig {
  minSdk 21

  testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
  consumerProguardFiles "consumer-rules.pro"
}
```

## **proguard-android.txt**

```Java
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

-dontoptimize
-dontpreverify

-keepattributes *Annotation*
-keep public class com.google.vending.licensing.ILicensingService
-keep public class com.android.vending.licensing.ILicensingService

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
}

-keepclassmembers class **.R$* {
    public static <fields>;
}

-dontwarn android.support.**

-keep class android.support.annotation.Keep

-keep @android.support.annotation.Keep class * {*;}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <methods>;
}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <fields>;
}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <init>(...);
}
```

## **proguard-android-optimize.txt**

proguard-android-optimize.txt 与 proguard-android.txt 的差别不大。

```Java
// 删除了关闭优化指令
# -dontoptimize

// 添加以下规则
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify
```

## **ProGuard映射配置**

映射文件生成在`项目\模块\build\outputs\mapping$debug或release)`目录。发布软件时，务必保留`mapping.txt`文件，以便能够将错误报告映射回原始代码。

# 常用的混淆配置

```Java
#############################################
#
# 基础混淆配置
#
#############################################


####################基本混淆指令的设置####################

#不混淆指定的包名。有多个包名可以用逗号隔开。包名可以包含 ？、*、** 通配符，还可以在包名前加上 ! 否定符。只有开启混淆时可用。如果你使用了 mypackage.MyCalss.class.getResource(""); 这些代码获取类目录的代码，就会出现问题。需要使用 -keeppackagenames 保留包名。
-keeppackagenames com.example.testdemo
#指定类、方法及字段混淆后时用的混淆字典。默认使用 ‘a’，’b’ 等短名称作为混淆后的名称。
-obfuscationdictionary dictionary.txt
# 打印 usage
-printusage usage.txt
# 打印 mapping
-printmapping mapping.txt
# 打印 seeds
-printseeds seeds.txt
# If you keep the line number information, uncomment this to
# hide the original source file name.
-renamesourcefileattribute SourceFile
#关闭优化功能。默认情况下启用优化。
-dontoptimize

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

# webView的混淆处理
-keepclassmembers class fqcn.of.javascript.interface.for.webview {
    public *;
}
-keepclassmembers class * extends android.webkit.webViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.webViewClient {
    public void *(android.webkit.webView, jav.lang.String);
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

#本库的混淆
#不混淆某个包所有的类
-keep class com.example.testdemo.bean.** { *; }

#############################################
#
# 第三方库的混淆配置（根据第三方库官网添加混淆代码）
#
#############################################

# Gson
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.idea.fifaalarmclock.entity.***
-keep class com.google.gson.stream.** { *; }
-keep class com.你的bean.** { *; }


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
-keepclassmembers class rx.internal.util.unsafe.BaseLinkedQueueProducerNodeRef {
    rx.internal.util.atomic.LinkedQueueNode producerNode;
}
-keepclassmembers class rx.internal.util.unsafe.BaseLinkedQueueConsumerNodeRef {
    rx.internal.util.atomic.LinkedQueueNode consumerNode;
}

# Glide图片库
-keep class com.bumptech.glide.**{*;}

# You can specify any path and filename.
-printconfiguration ../tmp/full-r8-config.txt
#混淆命令 gradlew makeJar
```