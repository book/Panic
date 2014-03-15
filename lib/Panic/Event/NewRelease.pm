package Panic::Event::NewRelease;

use Moo;

# isa => 'CPAN::ReleaseHistory::Release',
has release => (
    is      => 'ro',
    handles => [qw( path timestamp size distinfo )],
);

with 'Panic::Role::Event';

1;
