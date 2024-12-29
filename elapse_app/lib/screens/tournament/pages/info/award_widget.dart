import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:flutter/material.dart';

class AwardWidget extends StatelessWidget {
  const AwardWidget({super.key, required this.award});
  final Award award;

  @override
  Widget build(BuildContext context) {
    String winnersString;
    if (award.teamWinners != null && award.teamWinners!.isNotEmpty) {
      winnersString = award.teamWinners!.map((e) => e.teamNumber).join(", ");
    } else if (award.individualWinners != null && award.individualWinners!.isNotEmpty) {
      winnersString = award.individualWinners!.join(", ");
    } else {
      winnersString = "N/A";
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 5,
                child: Text(
                  award.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Flexible(
                flex: 1,
                child: Text(
<<<<<<< HEAD
                  "${award.qualifications.join(", ")}",
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7)),
=======
                  award.qualifications.join(", "),
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                ),
              )
            ],
          ),
          Text(
<<<<<<< HEAD
            "$winnersString",
            style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500),
=======
            winnersString,
            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
