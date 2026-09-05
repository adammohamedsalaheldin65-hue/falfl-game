# 🌶️ المحقق فلفل

Prototype Godot 4.7.2 للعبة تحقيق/محاماة مصرية بعالم مفتوح خفيف.

## التحكم

### الكمبيوتر
- `WASD` أو الأسهم: حركة
- `Shift`: جري
- `Space`: قفز / فرامل العربية
- `E`: تفاعل / ركوب ونزول
- `B`: شنطة القضايا
- `Esc`: Pause
- Mouse: الكاميرا

### الموبايل
اللعبة تكتشف الـTouch تلقائيًا:
- Virtual Joystick للحركة
- سحب يمين الشاشة لتحريك الكاميرا
- أزرار تفاعل / جري / قفز-فرامل
- زر شنطة القضايا
- زر Pause

على الموبايل يبدأ وضع الجرافيك Low تلقائيًا لتحسين الأداء.

## Online
Supabase Auth + Cloud Save مربوطين. الـPublishable Key فقط موجود في العميل؛ لا يوجد Secret/Service Role key.

## GitHub Pages
الـworkflow الموجود في `.github/workflows/web-pages.yml` يبني Web Export بـ Godot 4.7.2 وينشره على GitHub Pages تلقائيًا عند الـpush للـmain/master.
