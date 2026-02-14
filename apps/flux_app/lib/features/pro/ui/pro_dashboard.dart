import 'package:flutter/material.dart';
import '../../../core/models/profile.dart';
import 'agenda/agenda_screen.dart';
import 'clients/clients_screen.dart';
import 'payments/payments_screen.dart';
import 'settings/settings_screen.dart';

class ProDashboard extends StatefulWidget {
  final Profile profile;

  const ProDashboard({super.key, required this.profile});

  @override
  State<ProDashboard> createState() => _ProDashboardState();
}

class _ProDashboardState extends State<ProDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  late final List<_NavItem> _navItems;

  @override
  void initState() {
    super.initState();

    _screens = [
      AgendaScreen(profile: widget.profile),
      ClientsScreen(profile: widget.profile),
      if (widget.profile.role.isOwner) PaymentsScreen(profile: widget.profile),
      if (widget.profile.role.isOwner) SettingsScreen(profile: widget.profile),
    ];

    _navItems = [
      _NavItem(icon: Icons.calendar_today, label: 'Agenda'),
      _NavItem(icon: Icons.people, label: 'Clientes'),
      if (widget.profile.role.isOwner)
        _NavItem(icon: Icons.payments, label: 'Pagos'),
      if (widget.profile.role.isOwner)
        _NavItem(icon: Icons.settings, label: 'Ajustes'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A237E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey[600]),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white70
                                        : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
