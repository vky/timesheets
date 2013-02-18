package Day;
use Moo;

has start => (
    is => 'rw',
);

has end => (
    is => 'rw',
);

has lunch_start => (
    is => 'rw',
);

has lunch_end => (
    is => 'rw',
);


sub report {
    my $self = shift;
    my $sum = $self->start +
    $self->lunch_start +
    $self->lunch_end +
    $self->end;

    print "Start: " 	. $self->start . "\n" .
    "Lunch start: " . $self->lunch_start . "\n" .
    "Lunch end: " 	. $self->lunch_end . "\n" .
    "End: " 	. $self->end . "\n" .
    "Hours worked: " . $sum . "\n ";
}

1;



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
history
    n-days
    stack like

day
    start
    end
    lunch
        start
        end
    holiday
    pto
=cut




my ($date, $start, $end, $report, @holidays);

GetOptions (
    'start=s'	=> \$start,
'end=s'		=> \$end,
    'date'		=> \$date,
'holidays=s{15}'=> \@holidays,
    'report' 	=> \$report,
);

my %day_obj = ();
my $dt = DateTime->now;

if ($start) {
    print "Start: ";
    my $sdt = parse_time($start);
    $day_obj{$dt->ymd}{start} = $sdt;
    print $start."\n";
    print $day_obj{$dt->ymd}{start}."\n";
}
if ($end) {
    print "End: ";
    my $edt = parse_time($end);
    $day_obj{$dt->ymd}{end} = $edt;
    print $end."\n";
    print $day_obj{$dt->ymd}{end}."\n";
}
if ($date) {
    print "date!\n";
}


my $test_obj = Day->new (
    start => 1,
    end => 2,
    lunch_start => 3,
    lunch_end => 4,
);

$test_obj->report;

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

sub parse_time {
    my ($t1) = @_;
    my $parser = DateTime::Format::Strptime->new(
        pattern => '%I:%M%p',
        on_error => 'croak',
    );

    my $temp_time = $parser->parse_datetime($t1);
    my $now = DateTime->now;
    $now->set(hour => $temp_time->hour);
    $now->set(minute => $temp_time->minute);
    $now->set(second => 0);
    return $now;
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

