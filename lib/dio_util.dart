library xy_base_library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:xy_base_library/base_response.dart';

/// 请求方法.
class Method {
  static final String get = "GET";
  static final String post = "POST";
  static final String put = "PUT";
  static final String head = "HEAD";
  static final String delete = "DELETE";
  static final String patch = "PATCH";
}

///Http配置.
class HttpConfig {
  /// constructor.
  HttpConfig({
    this.status,
    this.code,
    this.msg,
    this.data,
    this.options,
    this.pem,
    this.pKCSPath,
    this.pKCSPwd,
  });

  /// BaseResp [String status]字段 key, 默认：status.
  String status;

  /// BaseResp [int code]字段 key, 默认：errorCode.
  String code;

  /// BaseResp [String msg]字段 key, 默认：errorMsg.
  String msg;

  /// BaseResp [T data]字段 key, 默认：data.
  String data;

  /// Options.
  BaseOptions options;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PEM证书内容.
  String pem;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书路径.
  String pKCSPath;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书密码.
  String pKCSPwd;
}

///
class DioUtil {
  static final DioUtil _singleton = DioUtil._init();
  static Dio _dio;

  /// BaseResp [String status]字段 key, 默认：status.
  String _statusKey = "status";

  /// BaseResp [int code]字段 key, 默认：errorCode.
  String _codeKey = "errorCode";
  BaseOptions _options = getDefOptions();

  /// BaseResp [String msg]字段 key, 默认：errorMsg.
  String _msgKey = "errorMsg";

  /// BaseResp [T data]字段 key, 默认：data.
  String _dataKey = "data";

  /// PEM证书内容.
  String _pem;

  /// PKCS12 证书路径.
  String _pKCSPath;

  /// PKCS12 证书密码.
  String _pKCSPwd;

  /// 是否是debug模式.,默认不是debug
  static bool _isDebug = false;

  factory DioUtil() {
    return _singleton;
  }

  static DioUtil getInstance() {
    return _singleton;
  }

  static openDebug() {
    _isDebug = true;
  }

  //命名构造函数,简单来说，是因为 Dart 不支持构建方法的重载（overloading），我们无法像Java语言一样使用不同的构建参数来实现构建方法
  DioUtil._init() {
    _dio = Dio(_options);
  }

  void setCookie(String cookie) {
    Map<String, dynamic> _headers = new Map();
    _headers["Cookie"] = cookie;
    _dio.options.headers.addAll(_headers);
  }

  void setConfig(HttpConfig httpConfig) {
    _statusKey = httpConfig.status ?? _statusKey;
    _codeKey = httpConfig.code ?? _codeKey;
    _msgKey = httpConfig.msg ?? _msgKey;
    _dataKey = httpConfig.data ?? _dataKey;
    _mergeOption(httpConfig.options);
    _pem = httpConfig.pem ?? _pem;
    if (_dio != null) {
      _dio.options = _options;
      if (_pem != null) {
        (_dio.httpClientAdapter as DefaultHttpClientAdapter)
            .onHttpClientCreate = (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            if (cert.pem == _pem) {
              //证书一直，放行
              return true;
            }
            return false;
          };
        };
      }
      if (_pKCSPath != null) {
        (_dio.httpClientAdapter as DefaultHttpClientAdapter)
            .onHttpClientCreate = (HttpClient httpClient) {
          SecurityContext securityContext = SecurityContext();
          //第一个参数file是证书路径
          securityContext.setTrustedCertificates(_pKCSPath, password: _pKCSPwd);
          HttpClient httpClient = HttpClient(context: securityContext);
          return httpClient;
        };
      }
    }
  }

  static BaseOptions getDefOptions() {
    BaseOptions options = BaseOptions();
    options.contentType = "application/x-www-form-urlencoded";
    options.connectTimeout = 1000 * 30;
    options.receiveTimeout = 1000 * 30;
    return options;
  }

  void _mergeOption(BaseOptions options) {
    _options.method = options.method ?? _options.method;
    _options.headers = (Map.from(_options.headers))..addAll(options.headers);
    _options.baseUrl = options.baseUrl ?? _options.baseUrl;
    _options.connectTimeout = options.connectTimeout ?? _options.connectTimeout;
    _options.receiveTimeout = options.receiveTimeout ?? _options.receiveTimeout;
    _options.responseType = options.responseType ?? _options.responseType;
    _options.extra = (Map.from(_options.extra))..addAll(options.extra);
    _options.contentType = options.contentType ?? _options.contentType;
    _options.validateStatus = options.validateStatus ?? _options.validateStatus;
    _options.followRedirects =
        options.followRedirects ?? _options.followRedirects;
  }

  String _getOptionsStr(RequestOptions request) {
    return "method:" +
        request.method +
        "            baseUrl:" +
        request.baseUrl +
        "            path:" +
        request.path;
  }

  void _printDataStr(String tag, String data) {
    String str = data;
//    String str = data.toString();
//循环取str前512位数据，直到所有数据打印完
    while (str.isNotEmpty) {
      if (str.length > 512) {
        print("[$tag]:" + str.substring(0, 512));
        //str重新赋值走下个循环
        str = str.substring(512, str.length);
      } else {
        print("[$tag]:" + str);
        //所有数据打印完后str取空，让循环结束
        str = "";
      }
    }
  }

  void _printResponse(Response response) {
    if (!_isDebug) {
      //debug直接返回，不作任何处理
      return;
    }
    try {
      print(
          "-------------------------- Response Log --------------------------\n" +
              "[statusCode]:" +
              response.statusCode.toString() +
              "\n" +
              "[request]:" +
              _getOptionsStr(response.request));
      if (response.request.data is FormData) {
        //Post请求就全部用FormData就OK了
        FormData formData = response.request.data as FormData;
        Map<String, dynamic> map = Map();
        map["fields"] = formData.fields;
        map["files"] = formData.files;
        map["isFinalized"] = formData.isFinalized;
//        String jsonStr = json.encode(map);//fields是个List，它的item是MapEntry，MapEntry没有tojson方法，如果用这个去解析的话会报错
        String jsonStr = map.toString();
        _printDataStr("HTTP-REQUEST", jsonStr);
      } else {
        _printDataStr("HTTP-REQUEST", response.request.data.toString());
      }
      if (response.data is ResponseBody) {
        //测试download请求返回了ResponseBody
        ResponseBody responseBody = response.data as ResponseBody;
        Map<String, dynamic> map = Map();
        map["statusCode"] = responseBody.statusCode;
        map["extra"] = responseBody.extra;
        map["statusMessage"] = responseBody.statusMessage;
        map["headers"] = responseBody.headers;
        map["isRedirect"] = responseBody.isRedirect;
        map["redirects"] = responseBody.redirects;
        String jsonStr = json.encode(map);
        _printDataStr("HTTP-RESPONSE", jsonStr);
      } else if (response.data is Map) {
        //测试POST、Get都请求返回了Map
        _printDataStr("HTTP-RESPONSE", json.encode(response.data));
      } else {
        _printDataStr("HTTP-RESPONSE", response.data.toString());
      }
    } catch (ex) {
      print("Http Log" + " error......");
    }
  }

  Map<String, dynamic> _decodeData(Response response) {
    if (response == null ||
        response.data == null ||
        response.data.toString().isEmpty) {
      return Map();
    } else {
      return json.decode(response.data.toString());
    }
  }

  Options _checkOptions(String method, Options options) {
    if (options == null) {
      options = Options();
    }
    options.method = method;
    return options;
  }

  Future<BaseResponse<T>> request<T>(String method, String path,
      {dynamic data,
      Options options,
      CancelToken cancelToken,
      ProgressCallback onSendProgress,
      ProgressCallback onReceiveProgress}) async {
    try {
      Response response = await _dio.request(path,
          data: data,
          options: _checkOptions(method, options),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      _printResponse(response);
      String _status;
      int _code;
      String _msg;
      T _data;
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        try {
          if (response.data is Map) {
            _status = (response.data[_statusKey] is int)
                ? response.data[_statusKey].toString()
                : response.data[_statusKey];
            _code = (response.data[_codeKey] is int)
                ? response.data[_codeKey]
                : int.tryParse(response.data[_codeKey].toString());
            _msg = response.data[_msgKey];
            _data = response.data[_dataKey];
          } else {
            Map<String, dynamic> _dataMap = _decodeData(response);
            _status = (data[_statusKey] is String)
                ? _dataMap[_statusKey]
                : _dataMap[_statusKey].toString();
            _code = (_dataMap[_codeKey] is int)
                ? _dataMap[_codeKey]
                : int.tryParse(_dataMap[_codeKey].toString());
            _msg = data[_msgKey];
            data = _dataMap[_dataKey];
          }
          return BaseResponse(_status, _code, _msg, _data);
        } catch (e) {
          return Future.error(DioError(
            response: response,
            error: "data parsing exception ..",
            type: DioErrorType.RESPONSE,
          ));
        }
      }
      return Future.error(DioError(
        //如果进了ok或者created就return response了，没进上面if的话就在这里抛异常
        response: response,
        error: "statusCode: $response.statusCode,service error",
        type: DioErrorType.RESPONSE,
      ));
    } catch (e) {
      //请求出错在这抛异常，让调用者去捕获处理
      return Future.error(e);
    }
  }

  Future<BaseResponseR<T>> requestR<T>(String method, String path,
      {dynamic data, Options options, CancelToken cancelToken}) async {
    try {
      Response response = await _dio.request(path,
          data: data,
          options: _checkOptions(method, options),
          cancelToken: cancelToken);
      _printResponse(response);
      String _status;
      int _code;
      String _msg;
      T _data;
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        try {
          if (response.data is Map) {
            _status = (response.data[_statusKey] is int)
                ? response.data[_statusKey].toString()
                : response.data[_statusKey];
            _code = (response.data[_codeKey] is int)
                ? response.data[_codeKey]
                : int.tryParse(response.data[_codeKey].toString());
            _msg = response.data[_msgKey];
            _data = response.data[_dataKey];
          } else {
            Map<String, dynamic> _dataMap = _decodeData(response);
            _status = (data[_statusKey] is String)
                ? _dataMap[_statusKey]
                : _dataMap[_statusKey].toString();
            _code = (_dataMap[_codeKey] is int)
                ? _dataMap[_codeKey]
                : int.tryParse(_dataMap[_codeKey].toString());
            _msg = data[_msgKey];
            data = _dataMap[_dataKey];
          }
          return BaseResponseR(_status, _code, _msg, _data, response);
        } catch (e) {
          return Future.error(DioError(
            response: response,
            error: "data parsing exception ..",
            type: DioErrorType.RESPONSE,
          ));
        }
      }
      return Future.error(DioError(
        //如果进了ok或者created就return response了，没进上面if的话就在这里抛异常
        response: response,
        error: "statusCode: $response.statusCode,service error",
        type: DioErrorType.RESPONSE,
      ));
    } catch (e) {
      //请求出错在这抛异常，让调用者去捕获处理
      return Future.error(e);
    }
  }

  Future<Response> download(String urlPath, savePath,
      {ProgressCallback onProgress,
      CancelToken cancelToken,
      data,
      Options options}) async {
    try {
      Response response = await _dio.download(urlPath, savePath,
          onReceiveProgress: onProgress,
          cancelToken: cancelToken,
          data: data,
          options: options);
      _printResponse(response);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// get dio.
  Dio getDio() {
    return _dio;
  }

  /// create new dio.
  static Dio createNewDio([BaseOptions options]) {
    options = options ?? getDefOptions();
    Dio dio = new Dio(options);
    return dio;
  }
}
