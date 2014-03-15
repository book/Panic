package Panic::RunLoop;

use Carp;
use Module::Find ();

use Moo;

has max_events => (
    is        => 'ro',
    predicate => 1,
);

has sources => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        [ map { my $s = $_->new; [ $s, $s->next_event ] }
                Module::Find::useall('Panic::Source') ];
    }
);

has dispatch => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        my %dispatch;
        for my $consumer ( map $_->new,
            Module::Find::useall('Panic::Consumer') )
        {
            for my $type ( $consumer->event_types ) {
                push @{ $dispatch{"Panic::Event::$type"} }, $consumer;
            }
        }
        \%dispatch;
    },
);

sub run {
    my ($self) = @_;
    my $processed = 0;

    my $sources  = $self->sources;
    my $dispatch = $self->dispatch;
    while (@$sources) {

        # sort sources by next event
        $sources = [ sort { $a->[1]->timestamp <=> $b->[1]->timestamp }
                @$sources ];

        # get the next event and process it
        my $event = $sources->[0][1];
        $_->process($event) for @{ $dispatch->{ ref $event } };
        $processed++;

        # drop the source if it dried out
        shift @$sources
            if not $sources->[0][1] = $sources->[0][0]->next_event;

        # are we done?
        last if $self->has_max_events && $processed >= $self->max_events;
    }
}

1;
