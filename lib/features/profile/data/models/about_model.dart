class AboutModel {
  final String title;
  final String subtitle;
  final String heading1;
  final String desc1;
  final String heading2;
  final String desc2;
  final String p1;
  final String p2;
  final String qaTitle;
  final String p3;
  final String p4;
  final String p5;
  final String btn;
  final String footer;
  final String homeLink;

  AboutModel({
    required this.title,
    required this.subtitle,
    required this.heading1,
    required this.desc1,
    required this.heading2,
    required this.desc2,
    required this.p1,
    required this.p2,
    required this.qaTitle,
    required this.p3,
    required this.p4,
    required this.p5,
    required this.btn,
    required this.footer,
    required this.homeLink,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      title: json['om_oss_title'] ?? '',
      subtitle: json['om_oss_subtitle'] ?? '',
      heading1: json['om_oss_heading1'] ?? '',
      desc1: json['om_oss_desc1'] ?? '',
      heading2: json['om_oss_heading2'] ?? '',
      desc2: json['om_oss_desc2'] ?? '',
      p1: json['om_oss_p1'] ?? '',
      p2: json['om_oss_p2'] ?? '',
      qaTitle: json['om_oss_qa_title'] ?? '',
      p3: json['om_oss_p3'] ?? '',
      p4: json['om_oss_p4'] ?? '',
      p5: json['om_oss_p5'] ?? '',
      btn: json['om_oss_btn'] ?? '',
      footer: json['om_oss_footer'] ?? '',
      homeLink: json['om_oss_home_link'] ?? '',
    );
  }
}
