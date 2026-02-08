// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holding_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HoldingDto _$HoldingDtoFromJson(Map<String, dynamic> json) => HoldingDto(
      symbol: json['symbol'] as String,
      quantity: HoldingDto._numFromJson(json['quantity']),
      price: HoldingDto._numFromJson(json['price']),
      currency: json['currency'] as String,
      valueUsd: HoldingDto._numFromJson(json['value_usd']),
      valueJpy: HoldingDto._numFromJson(json['value_jpy']),
      ratio: HoldingDto._numFromJson(json['ratio']),
    );

Map<String, dynamic> _$HoldingDtoToJson(HoldingDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'quantity': instance.quantity,
      'price': instance.price,
      'currency': instance.currency,
      'value_usd': instance.valueUsd,
      'value_jpy': instance.valueJpy,
      'ratio': instance.ratio,
    };
