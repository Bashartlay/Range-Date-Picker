import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:calenderr/custom_painters.dart';

class BookingCalendar extends StatefulWidget {
  List<DateTime> blockedDays = [];
  List<DateTime> reservedDays = [];
  BookingCalendar({required this.reservedDays, required this.blockedDays});

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  Map<DateTime, List<String>> _bookings = {};
  DateTime? _selectedStartDay;
  DateTime? _selectedEndDay;
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _bookingNameController = TextEditingController();
  List<DateTime> _blockedDays = [];
  List<DateTime> _reservedDays = [];
  Set<DateTime> _highlightedDays = {};

  @override
  void initState() {
    super.initState();
    _blockedDays = widget.blockedDays;
    _reservedDays = widget.reservedDays;

    _highlightReservedDays();
  }

  void _highlightReservedDays() {
    setState(() {
      _highlightedDays.addAll(_reservedDays);
    });
  }

  void _addBooking(DateTime startDate, DateTime endDate, String bookingName) {
    DateTime current = startDate.isBefore(endDate) ? startDate : endDate;
    DateTime finish = startDate.isBefore(endDate) ? endDate : startDate;

    bool isConflict = false;
    while (!isSameDay(current, finish.add(Duration(days: 1)))) {
      if (_bookings.containsKey(current) && _bookings[current]!.isNotEmpty) {
        isConflict = true;
        break;
      }
      current = current.add(Duration(days: 1));
    }
    if (isConflict) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('This period includes already booked dates.'),
      ));
      return;
    }

    String bookingPeriod = '$bookingName (${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMd().format(endDate)})';
    setState(() {
      for (DateTime date = startDate;
          date.isBefore(endDate) || isSameDay(date, endDate);
          date = date.add(Duration(days: 1))) {
        if (_bookings[date] != null) {
          _bookings[date]!.add(bookingPeriod);
        } else {
          _bookings[date] = [bookingPeriod];
        }
        _highlightedDays.add(date);
      }
    });
  }

  void _removeAllBookings() {
    setState(() {
      _highlightedDays.clear();
      _bookings.clear();
    });
  }

  void _removeBooking(DateTime startDate, DateTime endDate) {
    setState(() {
      for (DateTime date = startDate;
          date.isBefore(endDate) || isSameDay(date, endDate);
          date = date.add(Duration(days: 1))) {
        if (_bookings[date] != null) {
          _bookings[date]!.clear();
          _bookings.remove(date);
        }
        _highlightedDays.remove(date);
      }
    });
  }

  void _showAddBookingDialog() {
    _bookingNameController.clear();
    DateTime startDate = _selectedStartDay!.isBefore(_selectedEndDay!)
        ? _selectedStartDay!
        : _selectedEndDay!;
    DateTime endDate = _selectedStartDay!.isBefore(_selectedEndDay!)
        ? _selectedEndDay!
        : _selectedStartDay!;
    if (_blockedDays.contains(startDate) ||
        _blockedDays.contains(endDate) ||
        _reservedDays.contains(startDate) ||
        _reservedDays.contains(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('This date is blocked or reserved.'),
      ));
      return;
    }

    DateTime current = startDate;
    bool isConflict = false;
    while (!isSameDay(current, endDate.add(Duration(days: 1)))) {
      if (_bookings.containsKey(current) && _bookings[current]!.isNotEmpty) {
        isConflict = true;
        break;
      }
      current = current.add(Duration(days: 1));
    }
    if (isConflict) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('This period includes already booked dates.'),
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Booking for Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'From ${DateFormat.yMMMd().format(startDate)} to ${DateFormat.yMMMd().format(endDate)}'),
              TextField(
                controller: _bookingNameController,
                decoration: InputDecoration(labelText: 'Booking Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_bookingNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter a booking name.'),
                  ));
                  return;
                }
                _addBooking(startDate, endDate, _bookingNameController.text);
                Navigator.of(context).pop();
                _printBookings();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  bool _isWithinRange(DateTime day) {
    if (_selectedStartDay == null || _selectedEndDay == null) {
      return false;
    }
    return (day.isAfter(_selectedStartDay!) ||
            isSameDay(day, _selectedStartDay!)) &&
        (day.isBefore(_selectedEndDay!) || isSameDay(day, _selectedEndDay!));
  }

  bool _isDateLocked(DateTime day) {
    return day.isBefore(DateTime.now());
  }

  bool _isBlockedDay(DateTime day) {
    DateTime localDateTime = day.toLocal();
    DateTime correctedLocalDate = localDateTime
        .subtract(Duration(hours: localDateTime.timeZoneOffset.inHours));
    return _blockedDays.contains(correctedLocalDate);
  }

  bool _isReservedDay(DateTime day) {
    DateTime localDateTime = day.toLocal();
    DateTime correctedLocalDate = localDateTime
        .subtract(Duration(hours: localDateTime.timeZoneOffset.inHours));
    return _reservedDays.contains(correctedLocalDate);
  }

  bool _isBookedDay(DateTime day) {
    return _bookings.containsKey(day) && _bookings[day]!.isNotEmpty;
  }

  void _printBookings() {
    print('Booked dates:');
    for (var date in _highlightedDays) {
      print(DateFormat.yMMMd().format(date));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Booking'),
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedStartDay, day) ||
                  isSameDay(_selectedEndDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
  if ((_isDateLocked(selectedDay) && _isDateLocked(selectedDay.add(Duration(days: 1))) && _isDateLocked(selectedDay.subtract(Duration(days: 1)))) ||
      (_isBlockedDay(selectedDay) && _isBlockedDay(selectedDay.add(Duration(days: 1))) && _isBlockedDay(selectedDay.subtract(Duration(days: 1)))) ||
      (_isBookedDay(selectedDay) && _isBookedDay(selectedDay.add(Duration(days: 1))) && _isBookedDay(selectedDay.subtract(Duration(days: 1)))) ||
      (_isReservedDay(selectedDay) && _isReservedDay(selectedDay.add(Duration(days: 1))) && _isReservedDay(selectedDay.subtract(Duration(days: 1))))
    ) {
    setState(() {
      _selectedStartDay = null;
      _selectedEndDay = null;
    });
    return;
  }
  setState(() {
    if (_selectedStartDay == null || (_selectedStartDay != null && _selectedEndDay != null)) {
      _selectedStartDay = selectedDay;
      _selectedEndDay = null;
      _removeAllBookings();
    } else if (_selectedStartDay != null && _selectedEndDay == null) {
      DateTime start = _selectedStartDay!;
      DateTime end = selectedDay;
      
      DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
          start.isBefore(end) ? start.millisecondsSinceEpoch : end.millisecondsSinceEpoch);
      DateTime endDate = DateTime.fromMillisecondsSinceEpoch(
          start.isBefore(end) ? end.millisecondsSinceEpoch : start.millisecondsSinceEpoch);

      bool isConflict = false;
      DateTime current = startDate;
      while (!isSameDay(current, endDate.add(Duration(days: 1)))) {
        if ((_isBlockedDay(current)) ||
            (_isReservedDay(current) && _isReservedDay(current.add(Duration(days: 1))) && _isReservedDay(current.subtract(Duration(days: 1)))) ||
            (_bookings.containsKey(current) && _bookings[current]!.isNotEmpty)) {
          isConflict = true;
          break;
        }
        current = current.add(Duration(days: 1));
      }

      if (isConflict) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('This period includes blocked or reserved dates.'),
        ));
        _selectedStartDay = null; // Clear the start day
        return;
      } else {
        _selectedStartDay = startDate;
        _selectedEndDay = endDate;
        _showAddBookingDialog();
      }
    }
    _focusedDay = focusedDay;
  });
},


            eventLoader: (day) {
              return _bookings[day] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_isDateLocked(day)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 212, 212, 212),
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else if (_isBlockedDay(day)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 212, 212, 212),
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                } else if (_isReservedDay(day)) {
                   DateTime previousDay = day.subtract(Duration(days: 1));
                   DateTime nextDay = day.add(Duration(days: 1));
                   if(!_isReservedDay(previousDay)){
                     return CustomPaint(
                      painter: StartDayPainter(color: Colors.red),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                   }
                   else  if(! _isReservedDay(nextDay)){
                     return CustomPaint(
                      painter: EndDayPainter(color: Colors.red),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                   }
                   
                   else{
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.rectangle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                   }
                } else if (_isBookedDay(day)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else if (_highlightedDays.contains(day)) {
                  if (isSameDay(day, _selectedStartDay)) {
                    return CustomPaint(
                      painter: StartDayPainter(color: Colors.blue),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else if (isSameDay(day, _selectedEndDay)) {
                    return CustomPaint(
                      painter: EndDayPainter(color: Colors.blue),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.rectangle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                } else if (_isWithinRange(day)) {
                  var secondary = Colors.white;
                  if(_isReservedDay(day) || _isReservedDay(day))
                    secondary = Colors.red;
                  return CustomPaint(
                    painter: DayRangePainter(
                      isStart: isSameDay(day, _selectedStartDay),
                      isEnd: isSameDay(day, _selectedEndDay),
                      isMiddle: true,
                      mainColor: Colors.blue,
                      secondaryColor: secondary,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    '${day.day}',
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 250, 197, 117),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                if (_highlightedDays.contains(day)) {
                  if (isSameDay(day, _selectedStartDay)) {
                    return CustomPaint(
                      painter: StartDayPainter(color: Colors.blue),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else if (isSameDay(day, _selectedEndDay)) {
                    return CustomPaint(
                      painter: EndDayPainter(color: Colors.blue),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else {
                    return Container(
          
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                } else if (_isWithinRange(day)) {
                  var secondary = Colors.white;
                  if(_isReservedDay(day) || _isReservedDay(day))
                    secondary = Colors.red;
                  return CustomPaint(
                    painter: DayRangePainter(
                      isStart: isSameDay(day, _selectedStartDay),
                      isEnd: isSameDay(day, _selectedEndDay),
                      isMiddle: true,
                      mainColor: Colors.blue,
                      secondaryColor: secondary,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
              },
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,  // Hide days from previous and next months
              todayDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
              outsideDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: _bookings.entries.map((entry) {
                DateTime startDate = entry.key;
                DateTime endDate = startDate;
                while (
                    _highlightedDays.contains(endDate.add(Duration(days: 1)))) {
                  endDate = endDate.add(Duration(days: 1));
                }
                return ListTile(
                  title: Text(DateFormat.yMMMd().format(entry.key)),
                  subtitle: Text(entry.value.join(', ')),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      _showRemoveBookingDialog(startDate, endDate);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: _printBookings,
            child: Text('Print Booked Dates'),
          ),
        ],
      ),
    );
  }

  void _showRemoveBookingDialog(DateTime startDate, DateTime endDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Booking for Period'),
          content: Text(
              'From ${DateFormat.yMMMd().format(startDate)} to ${DateFormat.yMMMd().format(endDate)}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _removeBooking(startDate, endDate);
                Navigator.of(context).pop();
              },
              child: Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
