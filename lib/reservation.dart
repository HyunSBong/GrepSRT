import 'package:intl/intl.dart';
import 'constants.dart';

class SRTTicket {
  static const Map<String, String> SEAT_TYPE = {"1": "일반실", "2": "특실"};
  static const Map<String, String> PASSENGER_TYPE = {
    "1": "어른/청소년",
    "2": "장애 1~3급",
    "3": "장애 4~6급",
    "4": "경로",
    "5": "어린이",
  };

  final String car;
  final String seat;
  final String seatTypeCode;
  final String seatType;
  final String passengerTypeCode;
  final String passengerType;
  final int price;
  final int originalPrice;
  final int discount;

  SRTTicket(Map<String, dynamic> data)
      : car = data['scarNo'],
        seat = data['seatNo'],
        seatTypeCode = data['psrmClCd'],
        seatType = SEAT_TYPE[data['psrmClCd']]!,
        passengerTypeCode = data['psgTpCd'],
        passengerType = PASSENGER_TYPE[data['psgTpCd']]!,
        price = int.parse(data['rcvdAmt']),
        originalPrice = int.parse(data['stdrPrc']),
        discount = int.parse(data['dcntPrc']);

  @override
  String toString() => dump();

  String dump() {
    return '$car호차 $seat ($seatType) $passengerType [${price}원(${discount}원 할인)]';
  }
}

class SRTReservation {
  final String reservationNumber;
  final String totalCost;
  final String seatCount;
  final String trainCode;
  final String trainName;
  final String trainNumber;
  final String depDate;
  final String depTime;
  final String depStationCode;
  final String depStationName;
  final String arrTime;
  final String arrStationCode;
  final String arrStationName;
  final String paymentDate;
  final String paymentTime;
  final bool paid;
  final List<SRTTicket> _tickets;

  SRTReservation(Map<String, dynamic> train, Map<String, dynamic> pay,
      List<SRTTicket> tickets)
      : reservationNumber = train['pnrNo'],
        totalCost = train['rcvdAmt'],
        seatCount = train['tkSpecNum'],
        trainCode = pay['stlbTrnClsfCd'],
        trainName = TRAIN_NAME[pay['stlbTrnClsfCd']]!,
        trainNumber = pay['trnNo'],
        depDate = pay['dptDt'],
        depTime = pay['dptTm'],
        depStationCode = pay['dptRsStnCd'],
        depStationName = STATION_NAME[pay['dptRsStnCd']]!,
        arrTime = pay['arvTm'],
        arrStationCode = pay['arvRsStnCd'],
        arrStationName = STATION_NAME[pay['arvRsStnCd']]!,
        paymentDate = pay['iseLmtDt'],
        paymentTime = pay['iseLmtTm'],
        paid = pay['stlFlg'] == 'Y',
        _tickets = tickets;

  @override
  String toString() => dump();

  String dump() {
    final formatter = DateFormat('MM월 dd일');
    final depDateFormatted = formatter.format(DateTime.parse(depDate));
    final paymentDateFormatted = formatter.format(DateTime.parse(paymentDate));

    var result = '[$trainName] $depDateFormatted, '
        '$depStationName~$arrStationName'
        '(${depTime.substring(0, 2)}:${depTime.substring(2, 4)}~${arrTime.substring(0, 2)}:${arrTime.substring(2, 4)}) '
        '${totalCost}원(${seatCount}석)';

    if (!paid) {
      result +=
          ', 구입기한 $paymentDateFormatted ${paymentTime.substring(0, 2)}:${paymentTime.substring(2, 4)}';
    }

    return result;
  }

  List<SRTTicket> get tickets => _tickets;
}
