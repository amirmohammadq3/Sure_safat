-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# موتور فلاتر به کلاس‌های Play Core (برای Deferred Components) ارجاع می‌دهد
# که چون این ویژگی در این برنامه استفاده نمی‌شود، آن وابستگی اضافه نشده است؛
# این خط فقط هشدار «کلاس پیدا نشد» را در R8 نادیده می‌گیرد (باگ شناخته‌شده‌ی فلاتر).
-dontwarn com.google.android.play.core.**
