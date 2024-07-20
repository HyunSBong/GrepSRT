import 'dart:convert';

class SRTResponseData {
  static const String STATUS_SUCCESS = "SUCC";
  static const String STATUS_FAIL = "FAIL";

  late Map<String, dynamic> _json;
  late Map<String, dynamic> _status;

  SRTResponseData(String response) {
    _json = json.decode(response);
    _status = {};

    // parse response data
    _parse();
  }

  @override
  String toString() {
    return dump();
  }

  String dump() {
    return json.encode(_json);
  }

  void _parse() {
    if (_json.containsKey("resultMap")) {
      _status = _json["resultMap"][0];
      return;
    }

    if (_json.containsKey("ErrorCode") && _json.containsKey("ErrorMsg")) {
      throw SRTResponseError(
          'Undefined result status "[${_json["ErrorCode"]}]: ${_json["ErrorMsg"]}"');
    }
    throw SRTError("Unexpected case [$_json]");
  }

  bool success() {
    String? result = _status["strResult"];
    if (result == null) {
      throw SRTResponseError("Response status is not given");
    }
    if (result == STATUS_SUCCESS) {
      return true;
    } else if (result == STATUS_FAIL) {
      return false;
    } else {
      throw SRTResponseError('Undefined result status "$result"');
    }
  }

  String message() {
    return _status["msgTxt"] ?? "";
  }

  Map<String, dynamic> getAll() {
    return Map<String, dynamic>.from(_json);
  }

  Map<String, dynamic> getStatus() {
    return Map<String, dynamic>.from(_status);
  }
}

class SRTError implements Exception {
  final String msg;
  SRTError(this.msg);

  @override
  String toString() => "SRTError: $msg";
}

class SRTLoginError extends SRTError {
  SRTLoginError([String msg = "Login failed, please check ID/PW"]) : super(msg);
}

class SRTResponseError extends SRTError {
  SRTResponseError(String msg) : super(msg);
}

class SRTDuplicateError extends SRTResponseError {
  SRTDuplicateError(String msg) : super(msg);
}

class SRTNotLoggedInError extends SRTError {
  SRTNotLoggedInError() : super("Not logged in");
}
