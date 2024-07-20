import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'srt_train.dart';
import 'srt_res_data.dart';
import 'constants.dart';

class SRT {
  final String srtId;
  final String srtPw;
  final bool verbose;
  bool isLogin = false;
  String? membershipNumber;
  http.Client _client = http.Client();
  // var _client = HttpClient();

  static final RegExp emailRegex = RegExp(r"[^@]+@[^@]+\.[^@]+");
  static final RegExp phoneNumberRegex = RegExp(r"(\d{3})-(\d{3,4})-(\d{4})");

  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 5.1.1; LGM-V300K Build/N2G47H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/39.0.0.0 Mobile Safari/537.36SRT-APP-Android V.1.0.6',
    'Accept': 'application/json',
  };

  static const String resultSuccess = "SUCC";
  static const String resultFail = "FAIL";

  static const Map<String, String> reserveJobId = {
    "PERSONAL": "1101",
    "STANDBY": "1102",
  };

  SRT(this.srtId, this.srtPw, {this.verbose = false, bool autoLogin = true}) {
    if (autoLogin) {
      login();
    }
  }

  void _log(String msg) {
    if (verbose) {
      print("[*] $msg");
    }
  }

  Future<bool> login({String? srtId, String? srtPw}) async {
    srtId ??= this.srtId;
    srtPw ??= this.srtPw;

    String loginType;
    if (emailRegex.hasMatch(srtId)) {
      loginType = "2";
    } else if (phoneNumberRegex.hasMatch(srtId)) {
      loginType = "3";
      srtId = srtId.replaceAll("-", "");
    } else {
      loginType = "1";
    }

    final url = API_ENDPOINTS['login'];

    final data = {
      "auto": "Y",
      "check": "Y",
      "page": "menu",
      "deviceKey": "-",
      "customerYn": "",
      "login_referer": API_ENDPOINTS['main'],
      "srchDvCd": loginType,
      "srchDvNm": srtId,
      "hmpgPwdCphd": srtPw,
    };

    final response = await _client.post(Uri.parse(url!),
        headers: defaultHeaders, body: data);
    // print(response.body);
    _log(response.body);

    if (response.body.contains("존재하지않는 회원입니다")) {
      isLogin = false;
      // throw SRTLoginError(json.decode(response.body)["MSG"]);
    }

    if (response.body.contains("비밀번호 오류")) {
      isLogin = false;
      // throw SRTLoginError(json.decode(response.body)["MSG"]);
    }

    if (response.body
        .contains("Your IP Address Blocked due to abnormal access.")) {
      isLogin = false;
      // throw SRTLoginError(response.body.trim());
    }

    if (response.body.contains("정상적으로 로그인되었습니다.")) {
      isLogin = true;
    }
    // isLogin = true;
    final responseJson = json.decode(response.body);
    membershipNumber = responseJson["userMap"]["MB_CRD_NO"];

    return true;
  }

  Future<bool> logout() async {
    if (!isLogin) {
      return true;
    }

    final url = API_ENDPOINTS['logout'];
    final response = await _client.post(Uri.parse(url!));
    _log(response.body);

    // if (response.statusCode != 200) {
    //   throw SRTResponseError(response.body);
    // }

    isLogin = false;
    membershipNumber = null;

    return true;
  }

  Future<List<SRTTrain>> searchTrain(
    String dep,
    String arr,
    String? date,
    String? time, {
    String? timeLimit,
    bool availableOnly = true,
  }) async {
    if (!STATION_CODE.containsKey(dep)) {
      throw ArgumentError('Station "$dep" not exists');
    }
    if (!STATION_CODE.containsKey(arr)) {
      throw ArgumentError('Station "$arr" not exists');
    }

    final depCode = STATION_CODE[dep]!;
    final arrCode = STATION_CODE[arr]!;

    date ??= DateFormat('yyyyMMdd').format(DateTime.now());
    time ??= "000000";

    final url = API_ENDPOINTS['search_schedule'];
    final data = {
      // course (1: 직통, 2: 환승, 3: 왕복)
      // TODO: support 환승, 왕복
      "chtnDvCd": "1",
      "arriveTime": "N",
      "seatAttCd": "015",
      // 검색 시에는 1명 기준으로 검색
      "psgNum": '1',
      "trnGpCd": '109',
      // train type (05: 전체, 17: SRT)
      "stlbTrnClsfCd": "05",
      // departure date
      "dptDt": date,
      // departure time
      "dptTm": time,
      // arrival station code
      "arvRsStnCd": arrCode,
      // departure station code
      "dptRsStnCd": depCode,
    };

    final response = await _client.post(Uri.parse(url!),
        headers: defaultHeaders, body: data);
    final parser = SRTResponseData(response.body);

    // if (!parser.success()) {
    //   throw SRTResponseError(parser.message());
    // }

    // _log(parser.message());

    // print(parser.getAll());

    final allTrains = parser.getAll()["outDataSets"]["dsOutput1"];
    List<SRTTrain> trains =
        allTrains.map<SRTTrain>((train) => SRTTrain(train)).toList();
    // // Note: Implement the retry logic for getting all trains here

    trains = trains.where((t) => t.trainName == "SRT").toList(); // SRT만 가져오기

    if (availableOnly) {
      trains = trains.where((t) => t.seatAvailable()).toList();
    }

    if (timeLimit != null) {
      trains =
          trains.where((t) => t.depTime!.compareTo(timeLimit) <= 0).toList();
    }
    print(trains);

    return trains;
  }

  // Implement other methods like reserve, reserveStandby, etc.
}

// class SRTReservation {
//   // Implement SRTReservation class
// }

// class SRTTicket {
//   // Implement SRTTicket class
// }

// class APIEndpoints {
//   static const String login =
//       "https://app.srail.or.kr/apb/selectListApb01080_n.do";
//   static const String main = "https://app.srail.or.kr/main.do";
//   static const String logout =
//       "https://app.srail.or.kr/apb/selectListApb01081_n.do";
//   static const String searchSchedule =
//       "https://app.srail.or.kr/arc/selectListArc05013_n.do";
//   // Add other API endpoints
// }
