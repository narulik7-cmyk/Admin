import 'package:flutter/material.dart';

void main() => runApp(const FoodBite8App());

const green = Color(0xFF176B3A);
const orange = Color(0xFFE2683D);

class FoodEvent {
  const FoodEvent(this.id, this.title, this.city, this.date, this.time, this.address, this.price, this.type, this.emoji, {this.registration = false});
  final String id, title, city, date, time, address, price, type, emoji;
  final bool registration;
}

const events = [
  FoodEvent('bite-club', 'Bite Club at the Spree', 'Berlin', '19 Aug', '17:00–23:00', 'Eichenstraße 4', 'Free entry', 'Street food', '🌮'),
  FoodEvent('burger-fest', 'Berlin Burger Festival', 'Berlin', '22 Aug', '12:00–22:00', 'Gleisdreieck Park', '€6 entry', 'Festival', '🍔'),
  FoodEvent('wine-walk', 'Vienna Wine & Food Walk', 'Vienna', '23 Aug', '14:00–21:00', 'Naschmarkt', '€12', 'Gastronomy', '🍷', registration: true),
  FoodEvent('market', 'Westergas Food Market', 'Amsterdam', '12 Sep', '11:00–20:00', 'Westergasfabriek', 'Free entry', 'Market', '🧇'),
  FoodEvent('night-market', 'Asian Night Market', 'Berlin', '19 Aug', '18:00–00:00', 'Markthalle Neun', '€4 entry', 'Market', '🥟'),
];

class FoodBite8App extends StatelessWidget {
  const FoodBite8App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FoodBite8',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: green),
      scaffoldBackgroundColor: const Color(0xFFFFFEFA),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFFFEFA), surfaceTintColor: Colors.transparent),
    ),
    home: const HomeShell(),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int page = 0;
  String city = 'Berlin';
  final saved = <String>{'wine-walk'};

  void open(FoodEvent event) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetail(
      event: event,
      saved: saved.contains(event.id),
      onSaved: () => setState(() => saved.contains(event.id) ? saved.remove(event.id) : saved.add(event.id)),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      Discover(city: city, onCity: (v) => setState(() => city = v), onEvent: open),
      Calendar(city: city, onEvent: open),
      MapScreen(city: city, onEvent: open),
      Saved(saved: saved, onEvent: open),
    ];
    return Scaffold(
      body: SafeArea(child: screens[page]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (v) => setState(() => page = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }
}

class Discover extends StatefulWidget {
  const Discover({super.key, required this.city, required this.onCity, required this.onEvent});
  final String city;
  final ValueChanged<String> onCity;
  final ValueChanged<FoodEvent> onEvent;
  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  String type = 'All';
  final search = TextEditingController();
  final types = const ['All', 'Street food', 'Festival', 'Market', 'Free'];
  @override
  Widget build(BuildContext context) {
    final list = events.where((e) {
      final matchType = type == 'All' || (type == 'Free' ? e.price == 'Free entry' : e.type == type);
      return e.city == widget.city && matchType && (search.text.isEmpty || e.title.toLowerCase().contains(search.text.toLowerCase()));
    }).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('FoodBite8', style: TextStyle(color: green, fontSize: 20, fontWeight: FontWeight.w800)),
          const Spacer(),
          DropdownButton<String>(value: widget.city, underline: const SizedBox(), items: const ['Berlin', 'Vienna', 'Amsterdam'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => widget.onCity(v!)),
        ]),
        const SizedBox(height: 12),
        const Text('Good food is happening.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const Text('Find a reason to go out today.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        SearchBar(controller: search, leading: const Icon(Icons.search), hintText: 'Search food events', onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        SizedBox(height: 38, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: types.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(types[i]), selected: type == types[i], onSelected: (_) => setState(() => type = types[i])))),
        const SizedBox(height: 18),
        Text('Upcoming in ' + widget.city, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Expanded(child: list.isEmpty ? const Center(child: Text('No events match these filters.')) : ListView(children: list.map((e) => EventCard(event: e, onTap: () => widget.onEvent(e))).toList())),
      ]),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onTap});
  final FoodEvent event;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFF5F7F1),
    margin: const EdgeInsets.symmetric(vertical: 7),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(width: 64, height: 64, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFFFE5D8), borderRadius: BorderRadius.circular(12)), child: Text(event.emoji, style: const TextStyle(fontSize: 32))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(event.date + ' · ' + event.time, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 5),
            Row(children: [_Tag(event.price, green), const SizedBox(width: 6), const _Tag('Verified', orange)]),
          ])),
          const Icon(Icons.chevron_right),
        ]),
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)));
}

class Calendar extends StatelessWidget {
  const Calendar({super.key, required this.city, required this.onEvent});
  final String city;
  final ValueChanged<FoodEvent> onEvent;
  @override
  Widget build(BuildContext context) {
    final list = events.where((e) => e.city == city).toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('August 2026', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text(city + ' · select a day to browse', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        GridView.builder(shrinkWrap: true, itemCount: 31, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6), itemBuilder: (_, i) {
          final marked = [19, 22, 23].contains(i + 1);
          return Container(alignment: Alignment.center, decoration: BoxDecoration(color: marked ? const Color(0xFFDFF0DF) : const Color(0xFFF3F4F0), borderRadius: BorderRadius.circular(10)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text((i + 1).toString(), style: TextStyle(fontWeight: marked ? FontWeight.w800 : FontWeight.w400)), if (marked) const Icon(Icons.circle, color: orange, size: 6)]));
        }),
        const SizedBox(height: 18),
        const Text('Selected day', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Expanded(child: ListView(children: list.map((e) => EventCard(event: e, onTap: () => onEvent(e))).toList())),
      ]),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key, required this.city, required this.onEvent});
  final String city;
  final ValueChanged<FoodEvent> onEvent;
  @override
  Widget build(BuildContext context) {
    final list = events.where((e) => e.city == city).toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('Explore ' + city, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)), const Spacer(), const Icon(Icons.tune)]),
        const SizedBox(height: 16),
        Expanded(child: Stack(children: [
          Container(decoration: BoxDecoration(color: const Color(0xFFE6EFE4), borderRadius: BorderRadius.circular(20)), child: CustomPaint(painter: _MapPainter(), child: const SizedBox.expand())),
          ...List.generate(list.length, (i) => Positioned(left: 55.0 + i * 82, top: 95.0 + (i % 2) * 135, child: GestureDetector(onTap: () => onEvent(list[i]), child: const CircleAvatar(backgroundColor: orange, foregroundColor: Colors.white, child: Icon(Icons.restaurant))))),
          Positioned(left: 12, right: 12, bottom: 12, child: EventCard(event: list.first, onTap: () => onEvent(list.first))),
        ])),
      ]),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: .75)..strokeWidth = 12..style = PaintingStyle.stroke;
    final a = Path()..moveTo(-20, size.height * .25)..quadraticBezierTo(size.width * .35, size.height * .12, size.width + 20, size.height * .28);
    final b = Path()..moveTo(size.width * .1, -20)..quadraticBezierTo(size.width * .45, size.height * .52, size.width * .9, size.height + 20);
    canvas.drawPath(a, p); canvas.drawPath(b, p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Saved extends StatelessWidget {
  const Saved({super.key, required this.saved, required this.onEvent});
  final Set<String> saved;
  final ValueChanged<FoodEvent> onEvent;
  @override
  Widget build(BuildContext context) {
    final list = events.where((e) => saved.contains(e.id)).toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Saved plans', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const Text('Your food-filled itinerary.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        Expanded(child: list.isEmpty ? const Center(child: Text('Save an event to plan your next bite.')) : ListView(children: list.map((e) => EventCard(event: e, onTap: () => onEvent(e))).toList())),
      ]),
    );
  }
}

class EventDetail extends StatelessWidget {
  const EventDetail({super.key, required this.event, required this.saved, required this.onSaved});
  final FoodEvent event;
  final bool saved;
  final VoidCallback onSaved;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(actions: [IconButton(onPressed: onSaved, icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline))]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(height: 190, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFFFE4D6), borderRadius: BorderRadius.circular(24)), child: Text(event.emoji, style: const TextStyle(fontSize: 96))),
      const SizedBox(height: 18),
      const _Tag('Verified by organiser', green),
      const SizedBox(height: 10),
      Text(event.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(event.date + ' · ' + event.time + '\n' + event.address + ', ' + event.city, style: const TextStyle(fontSize: 16, height: 1.5)),
      const SizedBox(height: 18),
      Wrap(spacing: 8, runSpacing: 8, children: [_Tag(event.price, orange), _Tag(event.registration ? 'Registration required' : 'No registration', green), const _Tag('Public transport nearby', green)]),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.directions), label: const Text('Get directions')),
      const SizedBox(height: 14),
      const Text('About this event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      const Text('Discover local makers, seasonal flavours and food worth sharing. Check the official source before travelling; event information was recently verified.'),
      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.flag_outlined), label: const Text('Report an issue')),
    ]),
  );
}

