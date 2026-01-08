/// 결제 수단 Enum
enum PaymentMethod {
  creditCard('credit_card', '신용카드'),
  debitCard('debit_card', '체크카드'),
  bankTransfer('bank_transfer', '계좌이체'),
  virtualAccount('virtual_account', '가상계좌'),
  mobile('mobile', '휴대폰'),
  kakao('kakao', '카카오페이'),
  naver('naver', '네이버페이'),
  toss('toss', '토스'),
  cash('cash', '현금');

  const PaymentMethod(this.code, this.label);

  final String code;
  final String label;

  @override
  String toString() => label;

  static PaymentMethod fromCode(String code) {
    return PaymentMethod.values.firstWhere(
      (e) => e.code == code,
      orElse: () => PaymentMethod.creditCard,
    );
  }
}
