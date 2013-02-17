use 5.016;
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use DateTime;
use DateTime::Duration;
use DateTime::Format::Strptime;
use List::Util qw(reduce);

=notes
I need to store the history of a given day. This seems like a good project for 
OOP. Each day should have a start, end, and check for lunch. I want to keep the
history so how to go about this.

Considering two objects, a history object and a day object. The history object
will keep track of the day objects, and the day object is what's operated upon.
The day object will need to round time to closest quarter somehow.
=cut

=flow

if date
	print out info about date (start, lunch start, lunch end, end, total hours)

check previous day
	if not filled out
		prompt info
	else
		continue

if start
	check that day can start
		if day started
			check whether to overwrite
				if overwrite
					if time given
						use given time
					else
						prompt time
					
		else
			continue



=cut

=structure
Monday
	start
	end
Tuesday
	start
	lunch
		start
		end
	end
Wednesday
	start
	end
Thursday
	start
	end
Friday
	start
	end

=cut

my $date;
my $start;
my $end;
my @holidays;
my $holiday_list;

GetOptions (
	'start'	=> \$start,
	'end'	=> \$end,
	'date'	=> \$date,
	'holidays=s{15}'=> \@holidays
);

if ($start) {
	print "Start!\n";
}
if ($date) {
	print "date!\n";
}
if ($end) {
	print "end!\n";
}

print Dumper(@holidays);


my $dt = DateTime->now;
print $dt."\n";
print $dt->ymd."\n";

print "\n";

my @array;
push @array, day_hours( '02/11/13 9:00 am', '02/11/13 3:30 pm' );
push @array, day_hours( '02/12/13 9:00 am', '02/12/13 3:30 pm' );
push @array, day_hours( '02/13/13 9:00 am', '02/13/13 3:30 pm' );
push @array, day_hours( '02/14/13 9:00 am', '02/14/13 3:30 pm' );
push @array, day_hours( '02/15/13 9:00 am', '02/15/13 3:30 pm' );
my $week = reduce { no warnings qw(once); $a + $b } @array;

pretty_hours($week);

sub pretty_hours {
	my ($hours) = @_;
	print $hours->hours.":".$hours->minutes."\n";
}

sub day_hours {
	my ($t1, $t2) = @_;
	my $parser = DateTime::Format::Strptime->new(
		pattern => '%D %I:%M %p',
		on_error => 'croak',
	);

	$t1 = $parser->parse_datetime($t1);
	$t2 = $parser->parse_datetime($t2);
	return $t2 - $t1;

}

__END__

=head1 NAME

timesheets - command line program to track time worked and generate timesheets.

=head1 SYNOPSIS


=head1 DESCRIPTION
date [start][end][lunch]
start (time)
end (time)
lunch start
lunch end
report (will show information for current week)
report start_date end_date (show information for time inbetween given days)
report [start_date end_date] export (will export the last week)

do something about holidays and pto
=cut

