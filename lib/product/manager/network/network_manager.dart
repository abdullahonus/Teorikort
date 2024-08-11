import 'package:dio/dio.dart';
import 'package:taxi/product/veriable_constant.dart';

abstract class INetworkManager {
  final Dio _dio = NetworkManager.instance.networkManager;
  Dio get dio => _dio;
}

class NetworkManager {
  static NetworkManager? _instance;
  static NetworkManager get instance {
    _instance ??= NetworkManager._init();
    return _instance!;
  }

  NetworkManager._init();

  final networkManager = Dio(BaseOptions(baseUrl: VeriableConstant.BASEURL));
}
