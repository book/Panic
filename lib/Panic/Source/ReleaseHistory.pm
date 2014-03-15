package Panic::Source::ReleaseHistory;

use Moo;

use Panic::Event::NewRelease;
use CPAN::ReleaseHistory;
use File::Spec;

has release_iterator => (
    is      => 'ro',
    default => sub {
        CPAN::ReleaseHistory->new(
            path => File::Spec->catfile(
                File::HomeDir->my_dist_data('CPAN-ReleaseHistory'),
                'release-history.txt'
            ),
        )->release_iterator( well_formed => 1 );
    },
);

sub next_event {
    my ($self) = @_;
    my $release = $self->release_iterator->next_release;
    return $release
        && Panic::Event::NewRelease->new( release => $release );
}

1;
