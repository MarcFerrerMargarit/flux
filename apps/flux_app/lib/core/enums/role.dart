enum Role {
  owner('OWNER'),
  staff('STAFF'),
  client('CLIENT');

  final String value;
  const Role(this.value);

  static Role fromString(String value) {
    return Role.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Role.client,
    );
  }

  bool get isOwner => this == Role.owner;
  bool get isStaff => this == Role.staff;
  bool get isClient => this == Role.client;
  bool get isPro => isOwner || isStaff;
}
