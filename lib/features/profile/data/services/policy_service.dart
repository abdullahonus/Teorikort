import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/policy_model.dart';

class PolicyService extends BaseApiService {
  Future<ApiResponse<PolicyModel>> getPolicy() async {
    return await handleResponse<PolicyModel>(
      get(ApiConstants.policy),
      PolicyModel.fromJson,
    );
  }
}
