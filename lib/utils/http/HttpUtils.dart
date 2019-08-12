import 'dart:collection';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/utils/toast/ToastUtils.dart';

/// 网络请求工具类
class HttpUtils {
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  Dio _dio; // 使用默认配置
  static HttpUtils _instance;

  static HttpUtils getInstance() {
    if (_instance == null) {
      _instance = new HttpUtils();
    }
    return _instance;
  }

  HttpUtils() {
    BaseOptions options = new BaseOptions(
      baseUrl: "https://www.wanandroid.com/",
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    _dio = new Dio(options);
  }

  get(url, Function success, {Function error}) {
    return netFetch(url, success: success, error: error);
  }

  post(url, Map<String, dynamic> params, Function success, {Function error}) {
    FormData formData = FormData.from(params);
    return netFetch(url,
        params: formData,
        options: Options(method: 'post'),
        error: error,
        success: success);
  }

  /// 网络请求基类
  netFetch(url,
      {params,
      Map<String, dynamic> header,
      Options options,
      Function success,
      Function error}) async {
    Map<String, dynamic> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }
    if (options != null) {
      options.headers = headers;
    } else {
      options = new Options(method: 'get');
      options.headers = headers;
    }

    Response response;
    try {
      response = await _dio.request(url, data: params, options: options);
    } on DioError catch (e) {
      ToastUtils.showTs(e.message);
    }
    if (response != null) {
      if (response.statusCode == 200) {
        //网络请求情况下的成功
        String dataStr = json.encode(response.data);
        Map<String, dynamic> dataMap = json.decode(dataStr);
        int errCode = dataMap['errorCode'];
        String errMsg = dataMap['errorMsg'] ?? '网络不给力';
        if (errCode == 0) {
//          业务上的成功
          success(dataMap);
        } else {
//          业务上的失败
          if (error != null) {
            error(errCode ?? -1);
          }
          ToastUtils.showTs(errMsg);
        }
      } else {
        // 网络请求情况下的失败
        ToastUtils.showTs('网络不给力');
      }
    } else {
      // 网络请求情况下的失败
      ToastUtils.showTs('网络不给力');
    }
  }
}
