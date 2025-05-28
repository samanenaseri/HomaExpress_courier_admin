import 'package:get/get.dart';

class PickupResponse {
  final bool status;
  final PickupData data;

  PickupResponse({required this.status, required this.data});

  factory PickupResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing PickupResponse: $json');
    return PickupResponse(
      status: json['status'] ?? false,
      data: PickupData.fromJson(json['data'] ?? {}),
    );
  }
}

class PickupData {
  final int currentPage;
  final List<PickupOrder> data;
  final int lastPage;
  final int total;

  PickupData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory PickupData.fromJson(Map<String, dynamic> json) {
    print('Parsing PickupData: $json');
    return PickupData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => PickupOrder.fromJson(item))
              .toList() ??
          [],
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class PickupOrder {
  final int id;
  final String orderNumber;
  final double totalPrice;
  final double totalCosts;
  final String? courierName;
  final String? numberBillOfLading;
  final String? consoleCost;
  final String? flightNumber;
  final String? flightDate;
  final int? airlineId;
  final int? nonDistributionStatusId;
  final String? paymentTransitionCode;
  final int paymentMethodId;
  final int pickupPersonId;
  final int latestTrackingId;
  final int productTypeId;
  final String typeOfPackaging;
  final String orderType;
  final int coordinatorId;
  final int salesPersonId;
  final int carryingTermId;
  final String status;
  final String? otpCode;
  final String? manifestId;
  final String codAmount;
  final String? bagNumber;
  final int createdBy;
  final String? cancellationReason;
  final int needClearance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int senderId;
  final int receiverId;
  final String? originAddress;
  final int originCityId;
  final String? destinationAddress;
  final int destinationCityId;
  final String? originPostalCode;
  final String? destinationPostalCode;
  final String? senderCompanyName;
  final String? receiverCompanyName;
  final int serviceId;
  final CustomerInfo? sender;
  final CustomerInfo? receiver;
  final City? origin;
  final City? destination;
  final AddressInfo? senderAddress;
  final AddressInfo? receiverAddress;

  PickupOrder({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.totalCosts,
    this.courierName,
    this.numberBillOfLading,
    this.consoleCost,
    this.flightNumber,
    this.flightDate,
    this.airlineId,
    this.nonDistributionStatusId,
    this.paymentTransitionCode,
    required this.paymentMethodId,
    required this.pickupPersonId,
    required this.latestTrackingId,
    required this.productTypeId,
    required this.typeOfPackaging,
    required this.orderType,
    required this.coordinatorId,
    required this.salesPersonId,
    required this.carryingTermId,
    required this.status,
    this.otpCode,
    this.manifestId,
    required this.codAmount,
    this.bagNumber,
    required this.createdBy,
    this.cancellationReason,
    required this.needClearance,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.senderId,
    required this.receiverId,
    this.originAddress,
    required this.originCityId,
    this.destinationAddress,
    required this.destinationCityId,
    this.originPostalCode,
    this.destinationPostalCode,
    this.senderCompanyName,
    this.receiverCompanyName,
    required this.serviceId,
    this.sender,
    this.receiver,
    this.origin,
    this.destination,
    this.senderAddress,
    this.receiverAddress,
  });

  factory PickupOrder.fromJson(Map<String, dynamic> json) {
    print('\n=== Parsing PickupOrder ===');
    print('Raw pickup data: $json');
    
    try {
      final senderAddressData = json['senderAddress'] ?? json['sender_address'];
      print('Sender address data: $senderAddressData');
      
      final receiverAddressData = json['receiverAddress'] ?? json['receiver_address'];
      print('Receiver address data: $receiverAddressData');
      
      final senderData = json['sender'];
      print('Sender data: $senderData');
      
      final receiverData = json['receiver'];
      print('Receiver data: $receiverData');
      
      final originData = json['origin'];
      print('Origin data: $originData');
      
      final destinationData = json['destination'];
      print('Destination data: $destinationData');

      return PickupOrder(
        id: json['id'] ?? 0,
        orderNumber: json['order_number'] ?? '',
        totalPrice: (json['total_price'] ?? 0).toDouble(),
        totalCosts: (json['total_costs'] ?? 0).toDouble(),
        courierName: json['courier_name'],
        numberBillOfLading: json['number_bill_of_lading'],
        consoleCost: json['console_cost'],
        flightNumber: json['flight_number'],
        flightDate: json['flight_date'],
        airlineId: json['airline_id'],
        nonDistributionStatusId: json['non_distribution_status_id'],
        paymentTransitionCode: json['payment_transition_code'],
        paymentMethodId: json['payment_method_id'] ?? 0,
        pickupPersonId: json['pickup_person_id'] ?? 0,
        latestTrackingId: json['latest_tracking_id'] ?? 0,
        productTypeId: json['product_type_id'] ?? 0,
        typeOfPackaging: json['type_of_packaging'] ?? '',
        orderType: json['order_type'] ?? '',
        coordinatorId: json['coordinator_id'] ?? 0,
        salesPersonId: json['sales_person_id'] ?? 0,
        carryingTermId: json['carrying_term_id'] ?? 0,
        status: json['status'] ?? '',
        otpCode: json['otp_code'],
        manifestId: json['manifest_id'],
        codAmount: json['cod_amount'] ?? '0',
        bagNumber: json['bag_number'],
        createdBy: json['created_by'] ?? 0,
        cancellationReason: json['cancellation_reason'],
        needClearance: json['need_clearance'] ?? 0,
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
        deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
        senderId: json['sender_id'] ?? 0,
        receiverId: json['receiver_id'] ?? 0,
        originAddress: json['origin_address'],
        originCityId: json['origin_city_id'] ?? 0,
        destinationAddress: json['destination_address'],
        destinationCityId: json['destination_city_id'] ?? 0,
        originPostalCode: json['origin_postal_code'],
        destinationPostalCode: json['destination_postal_code'],
        senderCompanyName: json['sender_company_name'],
        receiverCompanyName: json['receiver_company_name'],
        serviceId: json['service_id'] ?? 0,
        sender: senderData != null ? CustomerInfo.fromJson(senderData) : null,
        receiver: receiverData != null ? CustomerInfo.fromJson(receiverData) : null,
        origin: originData != null ? City.fromJson(originData) : null,
        destination: destinationData != null ? City.fromJson(destinationData) : null,
        senderAddress: senderAddressData != null ? AddressInfo.fromJson(senderAddressData) : null,
        receiverAddress: receiverAddressData != null ? AddressInfo.fromJson(receiverAddressData) : null,
      );
    } catch (e) {
      print('Error parsing PickupOrder: $e');
      rethrow;
    }
  }
}

class CustomerInfo {
  final int id;
  final String? fullName;
  final String? companyName;
  final String? name;
  final String? phone;
  final String legalType;

  CustomerInfo({
    required this.id,
    this.fullName,
    this.companyName,
    this.name,
    this.phone,
    required this.legalType,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    print('\n=== Parsing CustomerInfo ===');
    print('Raw customer data: $json');
    return CustomerInfo(
      id: json['id'] ?? 0,
      fullName: json['full_name'],
      companyName: json['company_name'],
      name: json['name'] ?? json['full_name'] ?? json['company_name'],
      phone: json['phone'] ?? json['mobile'],
      legalType: json['legal_type'] ?? 'person',
    );
  }
}

class City {
  final int id;
  final int countryId;
  final String faName;
  final String enName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final Country? country;

  City({
    required this.id,
    required this.countryId,
    required this.faName,
    required this.enName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    print('\n=== Parsing City ===');
    print('Raw city data: $json');
    
    final countryData = json['country'];
    print('Country data: $countryData');
    
    return City(
      id: json['id'] ?? 0,
      countryId: json['country_id'] ?? 0,
      faName: json['fa_name'] ?? '',
      enName: json['en_name'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      country: countryData != null ? Country.fromJson(countryData) : null,
    );
  }
}

class AddressInfo {
  final int id;
  final int orderId;
  final String type;
  final String address;
  final int cityId;
  final String name;
  final String mobile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? sectionId;
  final int addressId;
  final City? city;

  AddressInfo({
    required this.id,
    required this.orderId,
    required this.type,
    required this.address,
    required this.cityId,
    required this.name,
    required this.mobile,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.sectionId,
    required this.addressId,
    this.city,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    print('\n=== Parsing AddressInfo ===');
    print('Raw address data: $json');
    print('Data type: ${json.runtimeType}');
    
    try {
      final cityData = json['city'];
      print('City data: $cityData');
      print('City data type: ${cityData?.runtimeType}');
      
      final addressInfo = AddressInfo(
        id: json['id'] ?? 0,
        orderId: json['order_id'] ?? json['orderId'] ?? 0,
        type: json['type'] ?? '',
        address: json['address'] ?? '',
        cityId: json['city_id'] ?? json['cityId'] ?? 0,
        name: json['name'] ?? '',
        mobile: json['mobile'] ?? '',
        createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
        deletedAt: json['deleted_at'] != null || json['deletedAt'] != null 
            ? DateTime.parse(json['deleted_at'] ?? json['deletedAt']) 
            : null,
        sectionId: json['section_id'] ?? json['sectionId'],
        addressId: json['address_id'] ?? json['addressId'] ?? 0,
        city: cityData != null ? City.fromJson(cityData) : null,
      );
      
      print('\nCreated AddressInfo:');
      print('ID: ${addressInfo.id}');
      print('Address: ${addressInfo.address}');
      print('Name: ${addressInfo.name}');
      print('Mobile: ${addressInfo.mobile}');
      print('City: ${addressInfo.city?.enName}');
      
      return addressInfo;
    } catch (e) {
      print('Error parsing AddressInfo: $e');
      rethrow;
    }
  }
}

class Country {
  final int id;
  final String faName;
  final String enName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Country({
    required this.id,
    required this.faName,
    required this.enName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    print('\n=== Parsing Country ===');
    print('Raw country data: $json');
    return Country(
      id: json['id'] ?? 0,
      faName: json['fa_name'] ?? '',
      enName: json['en_name'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
} 