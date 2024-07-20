import 'srt.dart';
import "srt_train.dart";

void main(List<String> arguments) {
  final SRT srt = SRT('010-0000-0000', 'password!');

  String dep = '수서';
  String arr = '대전';
  String arr_date = '20240721';
  String dept_time = '000000';
  final trains = srt.searchTrain(dep = dep, arr = arr, arr_date, dept_time);
  // print(trains);
}
