use 5.016;
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use DateTime;
use DateTime::Duration;
use DateTime::Format::Strptime;
use List::Util qw(reduce);

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

round time to closest quarter somehow.
=cut

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
my $week = reduce {$a + $b} @array;

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
start (time)
end (time)
lunch start
lunch end
report (will show information for current week)
report start_date end_date (show information for time inbetween given days)
report export (will export the last week)

do something about holidays and pto
=cut

