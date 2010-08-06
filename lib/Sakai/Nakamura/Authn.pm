#!/usr/bin/perl -w

package Sakai::Nakamura::Authn;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Apache::Sling::Authn);

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.02';

#{{{sub new
sub new {
    my ( $class, @args ) = @_;
    my $authn = $class->SUPER::new(@args);
    bless $authn, $class;
    return $authn;
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::Authn - Authenticate to a Sakai::Nakamura instance.

=head1 ABSTRACT

Useful utility functions for general Authn functionality.

=head1 USAGE

use Sakai::Nakamura::Authn;

=head1 DESCRIPTION

Library providing useful utility functions for general Authn functionality.

=head1 REQUIRED ARGUMENTS

None required.

=head1 OPTIONS

n/a

=head1 DIAGNOSTICS

n/a

=head1 EXIT STATUS

0 on success.

=head1 CONFIGURATION

None required.

=head1 DEPENDENCIES

LWP::UserAgent

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

None known.

=head1 AUTHOR

Daniel David Parry <perl@ddp.me.uk>

=head1 LICENSE AND COPYRIGHT

LICENSE: http://dev.perl.org/licenses/artistic.html

COPYRIGHT: (c) 2010 Daniel David Parry <perl@ddp.me.uk>
