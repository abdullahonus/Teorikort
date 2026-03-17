class GDPRModel {
  final String title;
  final String subtitle;
  final String h1;
  final String p1;
  final String p1Suffix;
  final String p2;
  final String h2;
  final String p3;
  final String p4;
  final String h3;
  final List<String> listItems;
  final String h4;
  final String p5;
  final String h5;
  final String p6;
  final String contactTitle;
  final String contactP1;
  final String contactCompany;
  final String contactOrgNo;
  final String contactPhone;
  final String contactEmail;
  final String contactAddressTitle;
  final String contactAddress;
  final String contactBtn;
  final String footer;

  GDPRModel({
    required this.title,
    required this.subtitle,
    required this.h1,
    required this.p1,
    required this.p1Suffix,
    required this.p2,
    required this.h2,
    required this.p3,
    required this.p4,
    required this.h3,
    required this.listItems,
    required this.h4,
    required this.p5,
    required this.h5,
    required this.p6,
    required this.contactTitle,
    required this.contactP1,
    required this.contactCompany,
    required this.contactOrgNo,
    required this.contactPhone,
    required this.contactEmail,
    required this.contactAddressTitle,
    required this.contactAddress,
    required this.contactBtn,
    required this.footer,
  });

  factory GDPRModel.fromJson(Map<String, dynamic> json) {
    return GDPRModel(
      title: json['gdpr_title'] ?? '',
      subtitle: json['gdpr_subtitle'] ?? '',
      h1: json['gdpr_h1'] ?? '',
      p1: json['gdpr_p1'] ?? '',
      p1Suffix: json['gdpr_p1_suffix'] ?? '',
      p2: json['gdpr_p2'] ?? '',
      h2: json['gdpr_h2'] ?? '',
      p3: json['gdpr_p3'] ?? '',
      p4: json['gdpr_p4'] ?? '',
      h3: json['gdpr_h3'] ?? '',
      listItems: [
        json['gdpr_li1']?.toString() ?? '',
        json['gdpr_li2']?.toString() ?? '',
        json['gdpr_li3']?.toString() ?? '',
        json['gdpr_li4']?.toString() ?? '',
      ].where((i) => i.isNotEmpty).toList(),
      h4: json['gdpr_h4'] ?? '',
      p5: json['gdpr_p5'] ?? '',
      h5: json['gdpr_h5'] ?? '',
      p6: json['gdpr_p6'] ?? '',
      contactTitle: json['gdpr_contact_title'] ?? '',
      contactP1: json['gdpr_contact_p1'] ?? '',
      contactCompany: json['gdpr_contact_company'] ?? '',
      contactOrgNo: json['gdpr_contact_orgno'] ?? '',
      contactPhone: json['gdpr_contact_phone'] ?? '',
      contactEmail: json['gdpr_contact_email'] ?? '',
      contactAddressTitle: json['gdpr_contact_address_title'] ?? '',
      contactAddress: json['gdpr_contact_address'] ?? '',
      contactBtn: json['gdpr_contact_btn'] ?? '',
      footer: json['gdpr_footer'] ?? '',
    );
  }
}
