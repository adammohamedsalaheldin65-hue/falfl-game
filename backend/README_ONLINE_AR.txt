المحقق فلفل — Online Backend (Supabase)
=========================================

النسخة دي مجهزة للحسابات Online + Cloud Save.

مرة واحدة فقط:
1) اعمل Project على Supabase.
2) افتح SQL Editor وشغّل backend/supabase_setup.sql.
3) من Connect في Supabase هات:
   - Project URL
   - Publishable key (sb_publishable_...)
4) افتح اللعبة واضغط Online Setup.
5) الصق Project URL وPublishable key واضغط حفظ.

مهم جدًا:
- ما تحطش Secret key أو Service Role key داخل اللعبة.
- Publishable key مصمم للاستخدام في تطبيق العميل، والحماية الفعلية لبيانات الحفظ معمولة بـ RLS.
- لو Email Confirmation مفعّل، اللاعب لازم يفتح رسالة التفعيل قبل أول Log In.
- أثناء التطوير تقدر تقفل Confirm Email من إعدادات Auth لو عايز التسجيل يدخل مباشرة.

الملفات:
- scripts/OnlineBackend.gd: اتصال Auth وCloud Save.
- backend/supabase_setup.sql: جدول الحفظ وسياسات RLS.
- user://felfel_online.cfg: بيتعمل على جهاز اللاعب بعد Online Setup.
