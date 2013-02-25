=notes
Day
    attributes
        date
            Format: MM/DD/YYYY
        start
            DateTime object. Initially had the idea of just having the time here, but a DateTime object is simpler.
        lunch_start
            DateTime object. 
        lunch_end
            DateTime object.
        end
            DateTime object.
    methods
        make_time
            Should technically be a private method, but not figuring that out now.
        hours
            Returns string. String is in format '$hours hours and $minutes minutes.'.
=cut
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


sub report {
    my $self = shift;

    my $start        = $self->start if defined $self->start;
    my $end          = $self->end if defined $self->end;
    my $lunch_start  = $self->lunch_start if defined $self->lunch_start;
    my $lunch_end    = $self->lunch_end if defined $self->lunch_end;

    my $hours;

    if ( defined $start && defined $end ) {
        if ( defined $lunch_start && defined $lunch_end ) {
            $hours = ($lunch_start - $start) + ($end - $lunch_end);
            print "Start: " . $start."\n";
            print "Lunch start: " . $lunch_start."\n";
            print "Lunch end: " . $lunch_end."\n";
            print "End: " . $end."\n";
            return $hours->hours . " hours and " . $hours->minutes . " minutes.\n";
        }

        #else {
        #    # Figure out whether lunch_start or lunch_end is missing.
        #    return "Error: Lunch_start or lunch_end is not defined.\n";
        #}

        $hours = $end - $start;
        print "Start: " . $start."\n";
        print "Lunch start: " . $lunch_start."\n" if defined $lunch_start;
        print "Lunch end: " . $lunch_end."\n" if defined $lunch_end;
        print "End: " . $end."\n";
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

Simplest flow desired:

perl ts.pl

Using Storable to store things. Will store days in an array.

If last entered element in array is not today,
    alert to what last day was
    alert if last day was incomplete
    alert number of days passed
    alert to fill in any missed work days (Monday to Friday, ignoring holidays)
        
    if last day entered has start and end, begin new day

new day determined, no arguments given:
    fill in start automatically
    ask if lunch
        if lunch yes, lunch end automatically
    fill in end automatically


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

my $current = DateTime->now();
print "The current date/time is: " . $current . "\n\n";

GetOptions (
    'start=s'           => \$start,
    'end=s'             => \$end,
    'lunch_start|ls=s'  => \$lunch_start,
    'lunch_end|le=s'    => \$lunch_end,
    'date=s'            => \$date,
    'holidays=s{15}'    => \@holidays,
    'report'            => \$report,
);

my $historyref;
my $history_file = 'history_file';
my @history;

# Check if the history file exists.
# If it exists, retrieve data from it.
# Otherwise, create it.
if ( -e $history_file and -s $history_file) {
    $historyref = retrieve($history_file);
    @history = @$historyref;
}
else {
    open my $fh, '>>', $history_file;
    close $fh;
}

### Assume there is no previous entry
if (scalar @history < 1) {
    my $test_obj = Day->new (
        date => $current->mdy('/'),
        start => $current,
    );
    
    print "No history.\n";
    print "Start reached.\n";
    print $test_obj->report;
    push @history, $test_obj;
    store \@history, 'history_file';
}
else {
    if ($date) {
        print "Sorry, I'm not checking if this day that you've entered exists yet. If it does, you just overwrote it.\n";
        $date = make_date($date);
        print $date."\n";
        my $some_day = Day->new (
            date => $date->mdy('/'),
        );

        if ( defined $start && defined $end ) {
            $some_day->start(make_time($start, $date));
            $some_day->end(make_time($end, $date));
            if ( defined $lunch_start && defined $lunch_end ) {
                $some_day->lunch_start(make_time($lunch_start, $date));
                $some_day->lunch_end(make_time($lunch_end, $date));
            }
            elsif ( defined $lunch_start or defined $lunch_end) {
                print "You're missing either lunch start or lunch end, that's no good!\n";
            }
            else {
            }

            print "Date given.\n";
            print $some_day->report;
            push @history, $some_day;
            # sort array by date before storing.
            # sort order should be greatest first, want the most recent date
            # at the top.
            @history = sort date_sort @history;
            store \@history, 'history_file';
        }
        else {
            print "You're missing either start or end, that's no good!\n";
        }
        
    }
    else {
        my $last_entry = pop @history;
        if ($last_entry->date eq $current->mdy('/')) {
            if (defined $last_entry->start) {
                if (defined $last_entry->lunch_start) {
                    if (defined $last_entry->lunch_end) {
                        if (defined $last_entry->end) {
                            print "You have already ended the day at " . $last_entry->end . ". Would you like to change your end time?";
                            # request input, accept y/yes, or n/no
                        }
                        else {
                            $last_entry->end($current);
                            print "End reached.\n";
                            print $last_entry->report;
                            push @history, $last_entry;
                            store \@history, 'history_file';
                        }
                    }
                    else {
                        $last_entry->lunch_end($current);
                        print "Lunch end reached.\n";
                        print $last_entry->report;
                        push @history, $last_entry;
                        store \@history, 'history_file';
                    }
                }
                else {
                    if ($lunch_start) {
                        # $lunch_start requires a value but,
                        # I don't really care what $lunch_start is in this scenario 
                        $last_entry->lunch_start($current);
                        print "Lunch start reached.\n";
                        print $last_entry->report;
                        push @history, $last_entry;
                        store \@history, 'history_file';
                    }
                    elsif (defined $last_entry->lunch_end) {
                        if (defined $last_entry->end) {
                            print "You have already ended the day at " . $last_entry->end . ". Would you like to change your end time?";
                            # request input, accept y/yes, or n/no
                        }
                        else {
                            $last_entry->end($current);
                            print "End reached.\n";
                            print $last_entry->report;
                            push @history, $last_entry;
                            store \@history, 'history_file';
                        }
                    }
                    else {
                        $last_entry->end($current);
                        print "End reached.\n";
                        print $last_entry->report;
                        push @history, $last_entry;
                        store \@history, 'history_file';
                    }
                }
            }
            else {
                print "Start is not defined, and yet there is an entry for the current day. This is a bug. Assigning current time to start.";
                $last_entry->start($current);
                print "Buggy Start reached.\n";
                print $last_entry->report;
                push @history, $last_entry;
                store \@history, 'history_file';
            }
        }
        else {
            print "date is note today's date! wtf!\n";
        }
    }
}
### Do this later, it requires thought.
#elsif (previous_work_day($last_entry)) {
#}


if ($report) {
    print "There are " . scalar @history . "days stored.\n";
    foreach my $day (@history) {
        print $day->date."\n";

    }
}

sub make_time {
    my ($t1, $date) = @_;
    my $parser = DateTime::Format::Strptime->new(
        pattern => '%I:%M%p',
        on_error => 'croak',
    );

    my $temp_time = $parser->parse_datetime($t1);
    return DateTime->new(
        year       => $date->year,
        month      => $date->month,
        day        => $date->day,
        hour       => $temp_time->hour,
        minute     => $temp_time->minute,
        second     => 0,
    );
}

sub make_date {
    my $t1 = shift;
    my $parser = DateTime::Format::Strptime->new(
        pattern => '%D',
        on_error => 'croak',
    );

    return $parser->parse_datetime($t1);
}

sub date_sort {
    make_date($a->date) > make_date($b->date);
}






### Test code, was useful, now in use, can probably delete.
# my $test_obj = Day->new (
#     start => $start,
#     end => $end,
# );
# 
# $test_obj->report;
# push @$historyref, $test_obj;
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

