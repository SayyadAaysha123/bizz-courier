class Courier {
  bool active;
  String id;
  String link;
  bool usingAppPricing;
  double? basePrice;
  double? baseDistance;
  double? additionalDistancePricing;
  double? returnDistancePricing;
  double? additionalStopTax;

  Courier({
    this.active = false,
    this.id = "",
    this.link = "",
    this.usingAppPricing = true,
    this.basePrice,
  });

  Courier.fromJSON(Map<String, dynamic> jsonMap)
      : active = jsonMap['active'] == true || jsonMap['active'] == '1',
        id = jsonMap['id']?.toString() ?? '',
        link = jsonMap['link'] ?? '',
        usingAppPricing = jsonMap['using_app_pricing'] == null ||
            jsonMap['using_app_pricing'] == true ||
            jsonMap['using_app_pricing'] == '1',
        basePrice = jsonMap['base_price'] != null
            ? double.parse(jsonMap['base_price'])
            : null,
        baseDistance = jsonMap['base_distance'] != null
            ? double.parse(jsonMap['base_distance'])
            : null,
        additionalDistancePricing =
            jsonMap['additional_distance_pricing'] != null
                ? double.parse(jsonMap['additional_distance_pricing'])
                : null,
        returnDistancePricing = jsonMap['return_distance_pricing'] != null
            ? double.parse(jsonMap['return_distance_pricing'])
            : null,
        additionalStopTax = jsonMap['additional_stop_tax'] != null
            ? double.parse(jsonMap['additional_stop_tax'])
            : null;

  Map<String, String> toJSON() {
    Map<String, String> json = {};
    json = {
      'id': id,
      'active': active ? '1' : '0',
    };
    return json;
  }
}
