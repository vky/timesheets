package Day;
use Moo;
use DateTime;
use DateTime::Duration;
use DateTime::Format::Strptime;

has date => (
    is => 'rw',
);

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

sub make_time {
    my $t1 = shift;
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

sub hours {
    my $self = shift;

    my $start        = make_time($self->start) if defined $self->start;
    my $end          = make_time($self->end) if defined $self->end;
    my $lunch_start  = make_time($self->lunch_start) if defined $self->lunch_start;
    my $lunch_end    = make_time($self->lunch_end) if defined $self->lunch_end;

    my $hours;

    if ( defined $start && defined $end ) {
        if ( defined $lunch_start && defined $lunch_end ) {
            $hours = ($lunch_start - $start) + ($end - $lunch_end);
            return $hours->hours . " hours and " . $hours->minutes . " minutes.\n";
        }

        #else {
        #    # Figure out whether lunch_start or lunch_end is missing.
        #    return "Error: Lunch_start or lunch_end is not defined.\n";
        #}

        $hours = $end - $start;
        return $hours->hours . " hours and " . $hours->minutes . " minutes.\n";
    }
    else {
        # Figure out whether start or end is missing.
        return "Error: Start or end is not defined.\n";
    }
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
use Storable;

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




my ($date, $start, $end, $lunch_start, $lunch_end, $report, @holidays);

my $test = Day->new();

GetOptions (
    'start=s'       => \$start,
    'end=s'         => \$end,
    'lunch_start|ls=s' => \$lunch_start,
    'lunch_end|le=s'   => \$lunch_end,
    'date'          => \$date,
    'holidays=s{15}'=> \@holidays,
    'report'        => \$report,
);

if ($start) {
    $test->start($start);
}
if ($lunch_start) {
    $test->lunch_start($lunch_start);
}
if ($end) {
    $test->end($end);
}
if ($lunch_end) {
    $test->lunch_end($lunch_end);
}
if ($date) {
    print "date!\n";
}

print $test->hours;

# my $historyref;
# my $history_file = 'history_file';
# 
# if ( -e $history_file ) {
#     $historyref = retrieve($history_file);
# }
# else {
#     open my $fh, '>>', $history_file;
#     close $fh;
# }
# 
# my $test_obj = Day->new (
#     start => $start,
#     end => $end,
# );
# 
# $test_obj->report;
# 
# push @$historyref, $test_obj;
# 
# store \@$historyref, 'history_file';
# 
# print Dumper ($historyref);
# 
# foreach my $day (@$historyref) {
#     $day->report;
# }

# my @array;
# push @array, day_hours( '02/11/13 9:00 am', '02/11/13 3:30 pm' );
# push @array, day_hours( '02/12/13 9:00 am', '02/12/13 3:30 pm' );
# push @array, day_hours( '02/13/13 9:00 am', '02/13/13 3:30 pm' );
# push @array, day_hours( '02/14/13 9:00 am', '02/14/13 3:30 pm' );
# push @array, day_hours( '02/15/13 9:00 am', '02/15/13 3:30 pm' );
# my $week = reduce { no warnings qw(once); $a + $b } @array;
# 
# pretty_hours($week);
# 
# sub pretty_hours {
#     my ($hours) = @_;
#     print $hours->hours.":".$hours->minutes."\n";
# }
# 
# sub day_hours {
#     my ($t1, $t2) = @_;
#     my $parser = DateTime::Format::Strptime->new(
#         pattern => '%D %I:%M %p',
#         on_error => 'croak',
#     );
# 
#     $t1 = $parser->parse_datetime($t1);
#     $t2 = $parser->parse_datetime($t2);
#     return $t2 - $t1;
# 
# }


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

