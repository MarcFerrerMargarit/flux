enum ServiceType {
  appointment('APPOINTMENT'),
  classType('CLASS');

  final String value;
  const ServiceType(this.value);

  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ServiceType.appointment,
    );
  }
}
