# **ProGuard 工作流程**

ProGuard工作过程包括四个步骤：`shrink`，`optimize`，`obfuscate`，`preverigy`。这四个步骤都是可选，**但是顺序都是不变的**。

![img](https://i-blog.csdnimg.cn/blog_migrate/a36d5ebd90cb1186f6878d100f8508fb.png)

**shrink**：检测并删除项目中未使用到的类，字段，方法以及属性。

**optimize**：优化[字节码](https://so.csdn.net/so/search?q=%E5%AD%97%E8%8A%82%E7%A0%81&spm=1001.2101.3001.7020)，移除无用指令，或者进行指令优化。（R8优化工具不提供关闭优化的选项，同时也不支持对优化行为进行自定义修改。因此，尝试在配置中使用`-dontoptimize`指令是无效的，该指令不会被R8识别或执行。）

**obfuscate**：代码混淆，将代码中的类，字段，方法和属性等名称使用无意义的名称进行表示，减少代码反编译后的可读性。

**preverify**：针对 Java 1.6 及以上版本进行预校验， 校验 StackMap /StackMapTable 属性.**在编译时可以关闭，加快编译速度**。

# R8 工作流程

部分编译流程如下图所示：

* **R8 将脱糖（Desugar）、压缩、优化、混淆和 dex（D8 编译器）整合到一个步骤**
* R8 对 .class 文件执行代码压缩、优化与混淆
* D8 编译器执行脱糖，并将 .class 文件转换为 .dex文件

![img](https://i-blog.csdnimg.cn/blog_migrate/5712383822b40bb831303216525257ab.png)
 对比以下 ProGuard 与 R8 ：

**共同点：**

1. 开源
2. R8 支持所有现有 ProGuard 规则文件
3. 都提供了四大功能：**压缩**、**优化**、**混淆**、**预校验**

**不同点：**

1. ProGuard 可用于 Java 项目，而 R8 专为 Android 项目设计
2. R8 将脱糖（Desugar）、压缩、优化、混淆和 dex（D8 编译器）整合到**一个步骤**中，显著提高了编译性能

# Android编译打包

## 编译打包总体流程

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/877e2d07aef6d6cdb394f1e373562943.png)

## 编译打包主要步骤

![img](https://i-blog.csdnimg.cn/blog_migrate/9194f9b14fd78dfdc9b872111b179327.png)
 整个打包流程，总共分为7个步骤。

1. 打包资源文件，生成R.java文件
2. 处理aidl文件，生成相应的.Java文件
3. 编译项目源代码，生成class文件
4. 转换所有的class文件，生成classes.dex文件
5. 打包生成APK文件
6. 对APK文件进行签名
7. 对签名后的APK文件进行对齐处理

## AAPT2

AAPT2（Android Asset Packaging Tool2）是一种构建工具，Android Studio 和 Android Gradle 插件使用它来编译和打包应用的资源。AAPT2 会解析资源、为资源编制索引，并将资源编译为针对 Android 平台进行过优化的二进制格式。

AGP3.0.0 之后默认通过 AAPT2 来编译资源， 支持通过启用增量编译实现更快的资源编译。这是通过将资源处理拆分为两个步骤来实现的：

1. 编译：将资源文件编译为二进制格式。
    把所有的 Android 资源文件进行解析，生成扩展名为。flat 的二进制文件。比如是 png 图片，那么就会被压缩处理，采用。png.flat 的扩展名。可以在 build/intermediates/merged\_res/文件下查看生成的中间产物。
2. 链接：合并所有已编译的文件并将它们打包到一个软件包中。
    首先，这一步会生成辅助文件，比如 R.java 与 resources.arsc，R 文件大家应该都比较熟悉，就是一个资源索引文件，我们平时引用也都是通过 R。的方式引用资源 id。而 resources.arsc 则是资源索引表，供在程序运行时根据 id 索引到具体的资源。最后会将 R 文件，ressources.arsc 文件和之前的二进制文件进行打包，打包到一个软件包中。

这种拆分方式有助于提高增量编译的性能。例如，如果某个文件中有更改，您只需要重新编译该文件。

**AAPT2 会根据对应用清单中的类、布局及其他应用资源的引用，生成保留规则**。例如，AAPT2 会为您在应用清单中注册为入口点的每个 activity 添加一个保留规则。

# **组件化混淆**

在组件化的项目中，需要注意应用 Module 和 Library Module 的行为差异和组件化的资源汇合规则，总结为以下几个重点：

* 编译时会依次对各层 Library Module进行编译，最底层的 Base Module 会最先被编译为 aar 文件，然后上一层编译时会将依赖 Module 输出的 aar 文件/ jar 文件解压到模块的 build 中相应的文件夹中
* App Module 这一层汇总了全部的 aar 文件后，才真正开始编译操作
* 后编译的 Module 会覆盖之前编译的 Module 中的同名资源

![img](https://i-blog.csdnimg.cn/blog_migrate/98dbd93c4acf1b1b86a82eebfbd81d21.png)

使用较高版本的 Android Gradle Plugin，不会将汇总的资源放置在 `exploded-aar`文件夹。即便如此，Lib Module 的资源汇总到 App Module 的规则是一样的。

混淆开启由 App Module 决定， 与Lib Module 无关。专属的混淆规则设置到 Lib Module 的`proguard-rules.pro`，设置的混淆规则是不生效的。为了让规则生效，还需要在 Lib Module 的`build.gradle`中添加以下配置：

```Groovy
...
android {
    defaultConfig {
        consumerProguardFiles 'consumer-rules.pro'
    }
    buildTypes {
        release {
            // 开启混淆
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

其中`consumer-rules.pro`文件：

```Groovy
-keep class com.xxx.xxx.xxx
```

# **混淆文件说明**

代码混淆是将代码转换成难以阅读和理解的形式，以保护源代码和减少应用体积的过程。以下是Android开发中常用的混淆配置文件及其作用：

* **proguard-android.txt**：这是默认的混淆规则集，位于`ANDROID_SDK\tools\proguard`目录。它提供了基本的代码混淆和优化设置。
* **proguard-android-optimize.txt**：此文件包含进一步压缩代码的混淆规则，虽然能更有效地减小应用体积，但处理时间较长，同样位于`ANDROID_SDK\tools\proguard`目录。
* **proguard-rules.pro**：用户自定义的混淆规则文件，可以根据项目需求进行调整。
* **usage.txt**：记录了在混淆过程中被删除的类、方法和字段。
* **mapping.txt**：存储了混淆前后的类名、方法名和字段名的映射信息，对于错误追踪和调试至关重要。
* **seeds.txt**：包含了被Keep规则保留的类、方法和字段，用于验证Keep规则的正确性。
* **configuration.tx**：配置的所有的混淆规则，在目录`app/build/outputs/mapping/release/configuration.txt`
* **consumer-rules.pro**：用于指定发布AAR（Android Archive）依赖库时所附带的混淆规则文件。
* **aapt_rules.txt**：使用 `minifyEnabled true` 构建项目后会在以下目录生成：`<module-dir>/build/intermediates/proguard-rules/debug/aapt_rules.txt`。AAPT2 会根据对应用清单中的类、布局及其他应用资源的引用，生成保留规则。例如，AAPT2 会为您在应用清单中注册为入口点的每个 activity 添加一个保留规则。

# **示例配置文件内容**

## consumer-rules.pro

**consumerProguardFiles 配置 :**  在 Android 项目的构建配置中，`consumerProguardFiles`是一个关键的配置项，它用于指定发布 AAR（Android Archive）依赖库时所附带的混淆规则文件。以下是对这一配置的详细说明：

1. **AAR** **内嵌混淆规则**：此配置允许开发者在 AAR 库中嵌入专门的 ProGuard 规则文件。这些规则文件将直接包含在发布的 AAR 包内，确保了库的混淆规则与库本身一同分发。
2. **应用程序项目继承规则**：当其他应用程序项目依赖于这个 AAR 时，如果该项目启用了 ProGuard 或 R8 进行代码混淆，它将自动继承并应用这些预设的 ProGuard 规则。这样可以保证 AAR 库在最终的应用中以预期的方式进行混淆。
3. **定制化混淆与排除**：通过`consumerProguardFiles`配置，库开发者可以精确地指定哪些代码应该被保留（例如，公开的 API 或者需要暴露给其他应用的组件），以及哪些代码可以被安全地删除或混淆。这为库的发布提供了更高级别的定制化和控制。
4. **项目类型的适用性**：需要注意的是，`consumerProguardFiles`配置仅适用于库项目（如 AAR 或 JAR），并不适用于普通的应用程序项目。在应用程序项目中，这一配置将被忽略，开发者需要在应用的构建配置中直接管理混淆规则。

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

proguard-android-[optimize](https://so.csdn.net/so/search?q=optimize&spm=1001.2101.3001.7020).txt 与 proguard-android.txt 的差别不大。

```Java
// 删除了关闭优化指令
# -dontoptimize

// 添加以下规则
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify
```

## **ProGuard 映射配置**

映射文件生成在`项目\模块\build\outputs\mapping$debug或release`目录。发布软件时，务必保留`mapping.txt`文件，以便能够将错误报告映射回原始代码。

# 常用的混淆配置

```Java
####################基本混淆指令的设置####################
#不混淆指定的包名。有多个包名可以用逗号隔开。包名可以包含 ？、*、** 通配符，还可以在包名前加上 ! 否定符。只有开启混淆时可用。如果你使用了 mypackage.MyCalss.class.getResource(""); 这些代码获取类目录的代码，就会出现问题。需要使用 -keeppackagenames 保留包名。
-keeppackagenames com.yuanxiaocai.androidproguard
#指定类、方法及字段混淆后时用的混淆字典。默认使用 ‘a’，’b’ 等短名称作为混淆后的名称。
-obfuscationdictionary dictionary.txt
# 这个规则可能用于将混淆工具的使用信息输出到指定的文件 usage.txt 中。这通常是用来帮助用户了解工具的用法和参数选项。
-printusage ../mapping/usage.txt
# 此规则可能用于将混淆后的代码映射输出到指定的文件 mapping.txt 中。代码映射文件通常用于将混淆后的代码与原始代码之间的映射关系，这在调试和排查问题时非常有用。
-printmapping ../mapping/mapping.txt
# 这个规则可能用于将混淆工具生成的种子文件输出到指定的文件 seeds.txt 中。种子文件通常包含一些不需要进行混淆处理的代码或类名，以确保它们保持原样而不被混淆。
-printseeds ../mapping/seeds.txt
# 此规则可能用于将混淆工具的配置信息输出到指定的文件 configuration 中。这个文件可能包含有关混淆工具当前配置的详细信息，可以帮助用户了解混淆过程中使用的参数和设置。
-printconfiguration ../mapping/configuration
# 支持对应用的堆栈轨迹进行轨迹还原
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
# -assumenosideeffects：告诉混淆器这些方法没有副作用，可以删除它们的调用。删除log.d的日志
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int d(...);
}
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
# -keep class com.你的bean.** { *; }
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
#混淆命令 gradlew makeJar
#本库的混淆
#不混淆某个包所有的类
-keep class com.yuanxiaocai.androidproguard.bean.** { *; }
```

# 注意事项

`-allowaccessmodification`：允许混淆器在优化代码时修改类、字段和方法的访问修饰符。这意味着混淆器可以将类的访问修饰符从 private 修改为 protected 或 public，或者进行其他必要的修改，以便于进一步优化和缩小代码。

若启用此选项，将会使不具备修饰符的方法或成员变量转变为具有修饰符的方法或变量，具体情况如下：

未添加`-allowaccessmodification`混淆规则：

```Java
void test() {
}
```

添加`-allowaccessmodification` 混淆规则：

```Java
public void test() {
}
```

将会自动添加 `public` 修饰符。

# 参考来源：

[R8 retrace | Android Studio | Android Developers](https://developer.android.google.cn/tools/retrace?hl=en)

[Gradle 系列（9）代码混淆到底做了什么？ - 掘金](https://juejin.cn/post/6930648501311242248)

[Android Apk 编译打包流程，一文带你详细了解](https://mp.weixin.qq.com/s/_orW4HFDYgYSQFrT04Beog)

[【Android 性能优化】:ProGuard，混淆，R8 优化 - 掘金](https://juejin.cn/post/7225511164120891453)