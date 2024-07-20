import 'constants.dart';

class SRTTrain {
  String? trainCode;
  String? trainName;
  String? trainNumber;
  String? depDate;
  String? depTime;
  String? depStationCode;
  String? depStationName;
  String? arrDate;
  String? arrTime;
  String? arrStationCode;
  String? arrStationName;
  String? generalSeatState;
  String? specialSeatState;
  String? reserveWaitPossibleCode;
  String? arrStationRunOrder;
  String? arrStationConstitutionOrder;
  String? depStationRunOrder;
  String? depStationConstitutionOrder;

  SRTTrain(Map<String, dynamic> data) {
    trainCode = data["stlbTrnClsfCd"];
    trainName = TRAIN_NAME[trainCode]!;
    trainNumber = data["trnNo"];
    depDate = data["dptDt"];
    depTime = data["dptTm"];
    depStationCode = data["dptRsStnCd"];
    depStationName = STATION_NAME[depStationCode]!;
    arrDate = data["arvDt"];
    arrTime = data["arvTm"];
    arrStationCode = data["arvRsStnCd"];
    arrStationName = STATION_NAME[arrStationCode]!;
    generalSeatState = data["gnrmRsvPsbStr"];
    specialSeatState = data["sprmRsvPsbStr"];
    reserveWaitPossibleCode = data["rsvWaitPsbCd"];
    arrStationRunOrder = data["arvStnRunOrdr"];
    arrStationConstitutionOrder = data["arvStnConsOrdr"];
    depStationRunOrder = data["dptStnRunOrdr"];
    depStationConstitutionOrder = data["dptStnConsOrdr"];
  }

  @override
  String toString() => dump();

  String dump() {
    return "[${trainName} ${trainNumber}] "
        "${depDate!.substring(4, 6)}월 ${depDate!.substring(6, 8)}일, "
        "${depStationName}~${arrStationName}"
        "(${depTime!.substring(0, 2)}:${depTime!.substring(2, 4)}~${arrTime!.substring(0, 2)}:${arrTime!.substring(2, 4)}) "
        "특실 ${specialSeatState}, 일반실 ${generalSeatState}, 예약대기 ${reserveStandbyAvailable() ? '가능' : '불가능'}";
  }

  bool generalSeatAvailable() {
    return generalSeatState!.contains("예약가능");
  }

  bool specialSeatAvailable() {
    return specialSeatState!.contains("예약가능");
  }

  bool reserveStandbyAvailable() {
    return reserveWaitPossibleCode!.contains("9"); // 9인 경우, 예약대기 가능한 상태임
  }

  bool seatAvailable() {
    return generalSeatAvailable() || specialSeatAvailable();
  }
}
