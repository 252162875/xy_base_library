import 'package:dio/dio.dart';

class BaseResponse<T> {
  String status;
  int code;
  String msg;
  T data;

  BaseResponse(this.status, this.code, this.msg, this.data);

  @override
  String toString() {
    StringBuffer sb = StringBuffer("{");
    sb.write("\"status\":\"$status\"");
    sb.write("\"code\":$code");
    sb.write("\"msg\":\"$msg\"");
    sb.write("\"data\":\"$data\"");
    sb.write("}");
    return sb.toString();
  }
}

class BaseResponseR<T> {
  String status;
  int code;
  String msg;
  T data;
  Response response;

  BaseResponseR(this.status, this.code, this.msg, this.data, this.response);

  @override
  String toString() {
    StringBuffer sb = StringBuffer("{");
    sb.write("\"status\":\"$status\"");
    sb.write("\"code\":$code");
    sb.write("\"msg\":\"$msg\"");
    sb.write("\"data\":\"$data\"");
    sb.write("}");
    return sb.toString();
  }
}
