import 'package:driving_license_exam/core/services/json_service.dart';
import '../models/exam_data.dart';

class ExamService {
  Future<ExamData> getExamData() async {
    final json = await JsonService.getExamsData();
    return ExamData.fromJson(json);
  }
}
