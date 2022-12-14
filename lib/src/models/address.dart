class Address {
  String id;
  String name;
  String formattedAddress;
  String number;
  double latitude;
  double longitude;
  bool delivered;

  Address({
    this.id = "",
    this.name = "",
    this.formattedAddress = "",
    this.number = "",
    this.latitude = 0,
    this.longitude = 0,
    this.delivered = false,
  });

  Address.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name']?.toString() ?? '',
        formattedAddress = jsonMap['formatted_address']?.toString() ?? '',
        number = jsonMap['number']?.toString() ?? '',
        latitude = jsonMap['geometry']['location']['lat'] ?? 0,
        longitude = jsonMap['geometry']['location']['lng'] ?? 0,
        delivered = jsonMap['delivered'] ?? false;

  Map<String, dynamic> toJSON() {
    return {
      'name': name,
      'number': number,
      'latitude': latitude,
      'longitude': longitude,
      'delivered': delivered,
    };
  }
}
