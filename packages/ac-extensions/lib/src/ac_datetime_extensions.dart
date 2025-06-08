import 'dart:core';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
extension AcDateTimeExtensions on DateTime {

  DateTime fromFormatted(String dateString,{String format=""}){
    if(format.isNotEmpty){
      DateFormat inputFormat=DateFormat(format);
      return inputFormat.parse(dateString);
    }
    else{
      return Moment.parse(dateString);
    }
  }

  DateTime addTime({int years=0,int months=0,int days=0,int hours=0,int minutes=0,int seconds=0,int microseconds=0}){
    Moment dateTime=Moment(this);
    if(years!=0){
      dateTime=Moment(DateTime(dateTime.year+years,dateTime.month,dateTime.day,dateTime.hour,dateTime.minute,dateTime.second,dateTime.millisecond,dateTime.microsecond));
    }
    if(months!=0){
      int year=dateTime.year;
      int addMonths=(months/12) as int;
      year+=addMonths;
      months=months%12;
      int month=dateTime.month+months;
      if(month>12){
        year++;
        month=month-12;
      }
      dateTime=dateTime=Moment(DateTime(year,month,dateTime.day,dateTime.hour,dateTime.minute,dateTime.second,dateTime.millisecond,dateTime.microsecond));
    }
    if(days!=0){
      dateTime=dateTime.add(Duration(days: days));
    }
    if(hours!=0){
      dateTime=dateTime.add(Duration(hours: hours));
    }
    if(minutes!=0){
      dateTime=dateTime.add(Duration(minutes: minutes));
    }
    if(seconds!=0){
      dateTime=dateTime.add(Duration(seconds: seconds));
    }
    if(microseconds!=0){
      dateTime=dateTime.add(Duration(microseconds: microseconds));
    }
    return dateTime;
  }

  String format(String format){
    Moment moment=Moment(this);
    return moment.format(format);
  }

  bool isSame(DateTime contraDate){
    Moment current=Moment(this);
    return current.compareTo(contraDate)==0;
  }

  DateTime subtractTime({int years=0,int months=0,int days=0,int hours=0,int minutes=0,int seconds=0,int microseconds=0}){
    Moment dateTime=Moment(this);
    if(years!=0){
      dateTime=Moment(DateTime(dateTime.year+years,dateTime.month,dateTime.day,dateTime.hour,dateTime.minute,dateTime.second,dateTime.millisecond,dateTime.microsecond));
    }
    if(months!=0){
      int year=dateTime.year;
      int addMonths=(months/12) as int;
      year-=addMonths;
      months=months%12;
      int month=dateTime.month-months;
      if(month<1){
        year--;
        month=month+12;
      }
      dateTime=Moment(DateTime(year,month,dateTime.day,dateTime.hour,dateTime.minute,dateTime.second,dateTime.millisecond,dateTime.microsecond));
    }
    if(days!=0){
      dateTime=dateTime.subtract(Duration(days: days));
    }
    if(hours!=0){
      dateTime=dateTime.subtract(Duration(hours: hours));
    }
    if(minutes!=0){
      dateTime=dateTime.subtract(Duration(minutes: minutes));
    }
    if(seconds!=0){
      dateTime=dateTime.subtract(Duration(seconds: seconds));
    }
    if(microseconds!=0){
      dateTime=dateTime.subtract(Duration(microseconds: microseconds));
    }
    return dateTime;
  }

}