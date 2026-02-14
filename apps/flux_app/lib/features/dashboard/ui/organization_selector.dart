import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/organization.dart';
import '../../../core/models/user_organization.dart';
import '../../../core/repositories/organization_repository.dart';

class OrganizationSelector extends ConsumerStatefulWidget {
  const OrganizationSelector({super.key});

  @override
  ConsumerState<OrganizationSelector> createState() =>
      _OrganizationSelectorState();
}

class _OrganizationSelectorState extends ConsumerState<OrganizationSelector> {
  List<UserOrganization> _userOrgs = [];
  Map<String, Organization> _organizations = {};
  bool _isLoading = true;
  UserOrganization? _primaryOrg;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final orgRepo = ref.read(organizationRepositoryProvider);

      // Get user's organizations
      final userOrgs = await orgRepo.getUserOrganizations(user.id);

      // Get organization details for each
      final orgDetails = <String, Organization>{};
      for (final userOrg in userOrgs) {
        final org = await orgRepo.getOrganizationById(userOrg.organizationId);
        if (org != null) {
          orgDetails[userOrg.organizationId] = org;
        }
        if (userOrg.isPrimary) {
          _primaryOrg = userOrg;
        }
      }

      setState(() {
        _userOrgs = userOrgs;
        _organizations = orgDetails;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading organizations: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setPrimaryOrganization(String organizationId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final orgRepo = ref.read(organizationRepositoryProvider);
      await orgRepo.setPrimaryOrganization(
        userId: user.id,
        organizationId: organizationId,
      );

      // Reload organizations
      await _loadOrganizations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primary organization updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userOrgs.isEmpty) {
      return const SizedBox.shrink();
    }

    final primaryOrgName = _primaryOrg != null
        ? _organizations[_primaryOrg!.organizationId]?.name ?? 'Unknown'
        : 'Select Organization';

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              primaryOrgName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        // Add organization list
        for (final userOrg in _userOrgs) {
          final org = _organizations[userOrg.organizationId];
          if (org != null) {
            items.add(
              PopupMenuItem<String>(
                value: 'select_${userOrg.organizationId}',
                child: Row(
                  children: [
                    Icon(
                      userOrg.isPrimary
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20,
                      color: userOrg.isPrimary ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            org.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (org.inviteCode != null)
                            Text(
                              'Code: ${org.inviteCode}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        // Add divider
        items.add(const PopupMenuDivider());

        // Add "Join Another Organization" option
        items.add(
          const PopupMenuItem<String>(
            value: 'add_new',
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, size: 20, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Join Another Organization',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

        return items;
      },
      onSelected: (value) {
        if (value == 'add_new') {
          // Navigate to invite code screen
          context.push('/invite-code');
        } else if (value.startsWith('select_')) {
          final orgId = value.substring(7);
          _setPrimaryOrganization(orgId);
        }
      },
    );
  }
}
