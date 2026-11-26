
import 'package:flutter/material.dart';

void main() => runApp(const GoharMarketApp());

const green = Color(0xFF176B45);
const paleGreen = Color(0xFFEAF4EE);

class GoharMarketApp extends StatelessWidget {
  const GoharMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'گهر مارکت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: WelcomePage(),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: paleGreen,
                  child: Icon(Icons.storefront, color: green, size: 42),
                ),
                const SizedBox(height: 18),
                const Text('گهر مارکت',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('مدیریت مشتریان و حساب نسیه',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 32),
                _RoleButton(
                  icon: Icons.admin_panel_settings,
                  title: 'ورود مدیر اصلی',
                  subtitle: 'مدیریت مشتریان، بدهی‌ها و گزارش‌ها',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminPage())),
                ),
                const SizedBox(height: 14),
                _RoleButton(
                  icon: Icons.person,
                  title: 'ورود مشتری',
                  subtitle: 'مشاهده حساب و ثبت اطلاعات',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CustomerPage())),
                ),
                const SizedBox(height: 22),
                const Text(
                  'نسخه نمایشی — ورود و اطلاعات هنوز به سرور متصل نیستند.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: paleGreen,
          child: Icon(icon, color: green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پنل مدیر اصلی')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('خلاصه فروشگاه',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _StatCard(title: 'مشتریان', value: '۰', icon: Icons.people)),
              SizedBox(width: 10),
              Expanded(child: _StatCard(title: 'کل بدهی', value: '۰ تومان', icon: Icons.account_balance_wallet)),
            ],
          ),
          const SizedBox(height: 18),
          _MenuTile(icon: Icons.person_add_alt_1, title: 'ثبت و بررسی مشتریان',
              subtitle: 'تأیید حساب مشتریان پس از بررسی'),
          _MenuTile(icon: Icons.receipt_long, title: 'خریدهای نسیه',
              subtitle: 'ثبت خرید و مشاهده ریز حساب'),
          _MenuTile(icon: Icons.payments, title: 'ثبت پرداخت',
              subtitle: 'کاهش مانده بدهی مشتری'),
          _MenuTile(icon: Icons.badge, title: 'مدارک هویتی',
              subtitle: 'بخش محدودشده برای مدیر اصلی'),
          _MenuTile(icon: Icons.sms, title: 'یادآوری پیامکی',
              subtitle: 'تنظیم یادآوری بدهکاران در اول هر ماه'),
          const SizedBox(height: 12),
          const _Notice(
            text: 'این صفحه فقط پیش‌نمایش است. برای استفاده واقعی، ورود امن، سطح دسترسی مدیر و ذخیره‌سازی رمزنگاری‌شده باید روی سرور پیاده‌سازی شود.',
          ),
        ],
      ),
    );
  }
}

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پنل مشتری')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('حساب مشتری',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const _StatCard(title: 'مانده حساب نمونه', value: '۰ تومان', icon: Icons.account_balance_wallet),
          const SizedBox(height: 14),
          _MenuTile(icon: Icons.phone_android, title: 'ورود با شماره موبایل',
              subtitle: 'اتصال به کد تأیید پیامکی در نسخه واقعی'),
          _MenuTile(icon: Icons.person_outline, title: 'اطلاعات شخصی',
              subtitle: 'ثبت و ویرایش مشخصات حساب'),
          _MenuTile(icon: Icons.history, title: 'ریز خریدها و پرداخت‌ها',
              subtitle: 'نمایش سوابق متعلق به همین مشتری'),
          _MenuTile(icon: Icons.verified_user, title: 'وضعیت تأیید حساب',
              subtitle: 'خرید نسیه پس از تأیید مدیر فعال می‌شود'),
          const SizedBox(height: 12),
          const _Notice(
            text: 'در این نسخه هیچ کد ملی یا تصویری بارگذاری یا ذخیره نمی‌شود. جمع‌آوری مدارک واقعی فقط پس از تعیین ضرورت، رضایت آگاهانه و راه‌اندازی ذخیره‌سازی امن انجام شود.',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: paleGreen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: green),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _MenuTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, height: 1.6)),
    );
  }
}
