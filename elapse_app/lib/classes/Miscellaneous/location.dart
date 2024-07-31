class Location {
  String? venue;
  String? city;
  String? region;
  String? country;
  String? address1;
  String? address2;
  String? postalCode;

  Location({
    this.venue,
    this.city,
    this.region,
    this.country,
    this.address1,
    this.address2,
    this.postalCode,
  });

  Map<String, dynamic> toJson() {
    return {
      "venue": venue,
      "city": city,
      "region": region,
      "country": country,
      "address_1": address1,
      "address_2": address2,
      "postcode": postalCode,
    };
  }
}

loadLocation(location) {
  return Location(
    venue: location["venue"],
    city: location["city"],
    region: location["region"],
    country: location["country"],
    address1: location["address_1"],
    address2: location["address_2"],
    postalCode: location["postcode"],
  );
}
