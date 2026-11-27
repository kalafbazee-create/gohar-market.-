import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GoharMarketApp());
}

class Product {
  final String barcode;
  String name;
  int price;
  Product({required this.barcode, required this.name, required this.price});
  Map<String, dynamic> toJson() => {'barcode': barcode, 'name': name, 'price': price};
  factory Product.fromJson(Map<String, dynamic> j) =>
      Product(barcode: j['barcode'], name: j['name'], price: j['price']);
}

class Store {
  static List<Product> products = [];
  static final ValueNotifier<int> changed = ValueNotifier(0);

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('products');
    if (raw != null) {
      products = (jsonDecode(raw) as List)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
    }
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('products', jsonEncode(products.map((e) => e.toJson()).toList()));
    changed.value++;
  }

  static Product? find(String barcode) {
    for (final p in products) {
      if (p.barcode == barcode) return p;
    }
    return null;
  }
}

class GoharMarketApp extends StatelessWidget {
  const GoharMarketApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'گهر مارکت',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'sans',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
      scaffoldBackgroundColor: const Color(0xFFF5F7F9),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = const [Dashboard(), InvoicePage(), ProductsPage()];
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'فاکتور'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'کالاها'),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Store.changed,
      builder: (_, __, ___) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            const Text('گهر مارکت', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('مدیریت سریع فروشگاه', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 22),
            Card(
              color: const Color(0xFF176B5B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(children: [
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('آماده فروش هستی؟', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 7),
                    Text('اسکن کن، کالا را پیدا کن و فاکتور بساز.', style: TextStyle(color: Colors.white70)),
                  ])),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF176B5B)),
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicePage())),
                  )
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _Stat(title: 'تعداد کالا', value: '${Store.products.length}', icon: Icons.inventory_2)),
              const SizedBox(width: 12),
              const Expanded(child: _Stat(title: 'فاکتور جدید', value: 'شروع', icon: Icons.receipt_long)),
            ]),
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())),
              icon: const Icon(Icons.add),
              label: const Text('افزودن کالای جدید', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title, value; final IconData icon;
  const _Stat({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF176B5B)),
      const SizedBox(height: 10),
      Text(title, style: TextStyle(color: Colors.grey.shade600)),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
    ])),
  );
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});
  @override State<AddProductPage> createState() => _AddProductPageState();
}
class _AddProductPageState extends State<AddProductPage> {
  final barcode = TextEditingController();
  final name = TextEditingController();
  final price = TextEditingController();
  bool scanning = false;

  Future<void> saveProduct() async {
    if (barcode.text.trim().isEmpty || name.text.trim().isEmpty || int.tryParse(price.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بارکد، نام و قیمت را کامل وارد کنید.')));
      return;
    }
    final existing = Store.find(barcode.text.trim());
    if (existing != null) {
      existing.name = name.text.trim();
      existing.price = int.parse(price.text.trim());
    } else {
      Store.products.add(Product(barcode: barcode.text.trim(), name: name.text.trim(), price: int.parse(price.text.trim())));
    }
    await Store.save();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا با موفقیت ذخیره شد.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('افزودن کالا')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(children: [
        _Field(controller: barcode, label: 'بارکد', icon: Icons.barcode_reader),
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: () => setState(() => scanning = true), icon: const Icon(Icons.qr_code_scanner), label: const Text('اسکن بارکد')),
        if (scanning) ...[
          const SizedBox(height: 16),
          ScannerBox(onCode: (code) {
            barcode.text = code;
            setState(() => scanning = false);
          }),
        ],
        const SizedBox(height: 18),
        _Field(controller: name, label: 'نام کالا', icon: Icons.shopping_bag_outlined),
        const SizedBox(height: 14),
        _Field(controller: price, label: 'قیمت (تومان)', icon: Icons.payments_outlined, keyboard: TextInputType.number),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
          onPressed: saveProduct, child: const Text('ذخیره کالا', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ),
      ]),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller; final String label; final IconData icon; final TextInputType? keyboard;
  const _Field({required this.controller, required this.label, required this.icon, this.keyboard});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: keyboard,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
  );
}

class ScannerBox extends StatefulWidget {
  final ValueChanged<String> onCode;
  const ScannerBox({super.key, required this.onCode});
  @override State<ScannerBox> createState() => _ScannerBoxState();
}
class _ScannerBoxState extends State<ScannerBox> {
  final controller = MobileScannerController();
  final player = AudioPlayer();
  bool locked = false;
  @override
  void dispose() { controller.dispose(); player.dispose(); super.dispose(); }

  Future<void> beep() async {
    await player.play(AssetSource('ding.wav')).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(
      height: 270,
      child: Stack(fit: StackFit.expand, children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) async {
            if (locked || capture.barcodes.isEmpty) return;
            final code = capture.barcodes.first.rawValue;
            if (code == null || code.isEmpty) return;
            locked = true;
            await beep();
            widget.onCode(code);
            Future.delayed(const Duration(milliseconds: 350), () => locked = false);
          },
        ),
        Center(child: Container(
          width: 290, height: 105,
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(18)),
        )),
        const Positioned(bottom: 12, left: 0, right: 0, child: Text('بارکد را داخل کادر قرار دهید', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ]),
    ),
  );
}

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});
  @override State<InvoicePage> createState() => _InvoicePageState();
}
class _InvoicePageState extends State<InvoicePage> {
  final scannerKey = GlobalKey<_InvoiceScannerState>();
  final Map<String, int> qty = {};
  bool scanning = false;

  void addCode(String code) {
    final p = Store.find(code);
    if (p == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('این بارکد در کالاها ثبت نشده است.')));
      return;
    }
    setState(() => qty[code] = (qty[code] ?? 0) + 1);
  }

  int total() => qty.entries.fold(0, (s, e) => s + (Store.find(e.key)?.price ?? 0) * e.value);

  @override
  Widget build(BuildContext context) {
    final entries = qty.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت فاکتور')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(children: [
          if (scanning) InvoiceScanner(key: scannerKey, onCode: addCode),
          if (!scanning) FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            onPressed: () => setState(() => scanning = true),
            icon: const Icon(Icons.qr_code_scanner), label: const Text('شروع اسکن کالاها', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 14),
          Expanded(child: entries.isEmpty
            ? const Center(child: Text('هنوز کالایی به فاکتور اضافه نشده است.'))
            : ListView.builder(itemCount: entries.length, itemBuilder: (_, i) {
                final e = entries[i]; final p = Store.find(e.key)!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p.price} تومان × ${e.value}'),
                    trailing: Text('${p.price * e.value} تومان', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              })),
          if (entries.isNotEmpty) Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Padding(padding: const EdgeInsets.all(18), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('جمع کل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${total()} تومان', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))],
            )),
          ),
        ]),
      ),
    );
  }
}

class InvoiceScanner extends StatefulWidget {
  final ValueChanged<String> onCode;
  const InvoiceScanner({super.key, required this.onCode});
  @override State<InvoiceScanner> createState() => _InvoiceScannerState();
}
class _InvoiceScannerState extends State<InvoiceScanner> {
  final controller = MobileScannerController();
  final player = AudioPlayer();
  String? lastCode; DateTime lastAt = DateTime.fromMillisecondsSinceEpoch(0);
  @override void dispose() { controller.dispose(); player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(height: 270, child: Stack(fit: StackFit.expand, children: [
      MobileScanner(controller: controller, onDetect: (capture) async {
        if (capture.barcodes.isEmpty) return;
        final code = capture.barcodes.first.rawValue;
        if (code == null || code.isEmpty) return;
        final now = DateTime.now();
        if (code == lastCode && now.difference(lastAt).inMilliseconds < 700) return;
        lastCode = code; lastAt = now;
        await player.play(AssetSource('ding.wav')).catchError((_) {});
        widget.onCode(code);
      }),
      Center(child: Container(width: 300, height: 110, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(18)))),
      const Positioned(bottom: 12, left: 0, right: 0, child: Text('اسکن پشت‌سرهم فعال است', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ])),
  );
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override State<ProductsPage> createState() => _ProductsPageState();
}
class _ProductsPageState extends State<ProductsPage> {
  final search = TextEditingController();
  @override Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: Store.changed,
    builder: (_, __, ___) {
      final q = search.text.trim();
      final list = Store.products.where((p) => p.name.contains(q) || p.barcode.contains(q)).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('کالاها')),
        body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          TextField(controller: search, onChanged: (_) => setState(() {}), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'جستجوی نام یا بارکد', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
          const SizedBox(height: 14),
          Expanded(child: list.isEmpty ? const Center(child: Text('کالایی پیدا نشد.')) : ListView.builder(
            itemCount: list.length, itemBuilder: (_, i) {
              final p = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(p.barcode), trailing: Text('${p.price} تومان')),
              );
            },
          )),
          FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())), icon: const Icon(Icons.add), label: const Text('افزودن کالا'))
        ])),
      );
    },
  );
}
