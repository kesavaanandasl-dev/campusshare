import 'package:flutter/material.dart';

class SetMeetupSheet extends StatefulWidget {
  const SetMeetupSheet({super.key});

  @override
  State<SetMeetupSheet> createState() => _SetMeetupSheetState();
}

class _SetMeetupSheetState extends State<SetMeetupSheet> {
  final locations = [
    'Library Block',
    'Main Gate',
    'Canteen',
    'Admin Block',
    'Hostel Entrance',
  ];

  String selectedLocation = 'Library Block';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Meetup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // LOCATION
            const Text('Location'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedLocation,
              items: locations
                  .map(
                    (l) => DropdownMenuItem(
                      value: l,
                      child: Text(l),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedLocation = v!),
            ),

            const SizedBox(height: 16),

            // DATE
            const Text('Date'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDate: selectedDate,
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),

            // TIME
            const Text('Time'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
            ),

            const SizedBox(height: 20),

            // CONFIRM
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final meetupDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  Navigator.pop(context, {
                    'location': selectedLocation,
                    'time': meetupDateTime,
                  });
                },
                child: const Text('Confirm Meetup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
