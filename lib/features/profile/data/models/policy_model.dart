class PolicyModel {
  final String title;
  final String subtitle;
  final String p1;
  final String p1Suffix;
  final String h1;
  final String desc1;
  final String h2;
  final String desc2;
  final String h3;
  final String desc3;
  final String h4;
  final String desc4;
  final String desc4Suffix;
  final List<String> listItems;
  final String h5;
  final String desc5;
  final String contactTitle;
  final String contactOrgNo;
  final String contactPhone;
  final String contactWeb;
  final String contactAddressTitle;
  final String contactAddress;
  final String contactBtn;

  PolicyModel({
    required this.title,
    required this.subtitle,
    required this.p1,
    required this.p1Suffix,
    required this.h1,
    required this.desc1,
    required this.h2,
    required this.desc2,
    required this.h3,
    required this.desc3,
    required this.h4,
    required this.desc4,
    required this.desc4Suffix,
    required this.listItems,
    required this.h5,
    required this.desc5,
    required this.contactTitle,
    required this.contactOrgNo,
    required this.contactPhone,
    required this.contactWeb,
    required this.contactAddressTitle,
    required this.contactAddress,
    required this.contactBtn,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      title: json['policy_title'] ?? '',
      subtitle: json['policy_subtitle'] ?? '',
      p1: json['policy_p1'] ?? '',
      p1Suffix: json['policy_p1_suffix'] ?? '',
      h1: json['policy_h1'] ?? '',
      desc1: json['policy_desc1'] ?? '',
      h2: json['policy_h2'] ?? '',
      desc2: json['policy_desc2'] ?? '',
      h3: json['policy_h3'] ?? '',
      desc3: json['policy_desc3'] ?? '',
      h4: json['policy_h4'] ?? '',
      desc4: json['policy_desc4'] ?? '',
      desc4Suffix: json['policy_desc4_suffix'] ?? '',
      listItems: [
        json['policy_li1']?.toString() ?? '',
        json['policy_li2']?.toString() ?? '',
        json['policy_li3']?.toString() ?? '',
        json['policy_li3_suffix']?.toString() ?? '',
        json['policy_li4']?.toString() ?? '',
      ].where((i) => i.isNotEmpty).toList(),
      h5: json['policy_h5'] ?? '',
      desc5: json['policy_desc5'] ?? '',
      contactTitle: json['policy_contact_title'] ?? '',
      contactOrgNo: json['policy_contact_orgno'] ?? '',
      contactPhone: json['policy_contact_phone'] ?? '',
      contactWeb: json['policy_contact_web'] ?? '',
      contactAddressTitle: json['policy_contact_address_title'] ?? '',
      contactAddress: json['policy_contact_address'] ?? '',
      contactBtn: json['policy_contact_btn'] ?? '',
    );
  }
}
