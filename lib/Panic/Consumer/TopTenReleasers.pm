package Panic::Consumer::TopTenReleasers;

use Moo;

has board => (
    is      => 'ro',
    default => sub { {} },
);

sub event_types {'NewRelease'}

sub process {
    my ( $self, $event ) = @_;
    $self->board->{ $event->distinfo->cpanid }{releases}++;
    $self->board->{ $event->distinfo->cpanid }{dists}
        { $event->distinfo->dist }++;
}

sub teardown {
    my ($self) = @_;
    my $board = $self->board;
    printf "%7d $_\n", $board->{$_}{releases}
        for sort {
        $board->{$b}{releases} <=> $board->{$a}{releases}
     || keys %{ $board->{$b}{dists} } <=> keys %{ $board->{$a}{dists} }
        } keys %$board;
}

with 'Panic::Role::Consumer';

1;
