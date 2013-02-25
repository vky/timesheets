Take note: In the interest of getting things working and not losing interest, good practices are being ignored totally. When the script has all the desired features implemented, rewriting will occur.

To run:

perl ts.pl
perl ts.pl -r
perl ts.pl --date|-d mm/dd/yy -s hh:mm(am|pm) -e hh:mm(am|pm) -ls hh:mm(am|pm) -le hh:mm(am|pm)
perl ts.pl --date|-d mm/dd/yy --start|-s hh:mm(am|pm) --end|-e hh:mm(am|pm)

The first command will automatically record the time to the appropriate field (start or end). To denote lunch, -ls must be given with some value. At the moment, the given value is ignored and the current time will be taken instead.

The -r argument will print out a report, or at least that's what it's intended to do. Currently it'll print out some stuff related to what's is in the history. In flux until some other stuff is implemented.

Using the --date argument expects a date, a start, and an end time. This is for filling days that were forgotten, or for entering old history. 
