#!/usr/bin/perl -w

package Sakai::Nakamura::Authz;

use 5.008008;
use strict;
use warnings;
use Carp;

use base qw(Apache::Sling::Authz);

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.08';

#{{{sub new
sub new {
    my ( $class, @args ) = @_;
    my $authz = $class->SUPER::new(@args);
    bless $authz, $class;
    return $authz;
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::Authz - Manipulate Authz in a Sakai Nakamura instance.

=head1 ABSTRACT

authz related functionality for Sling implemented over rest APIs.

=head1 METHODS

=head2 new

Create, set up, and return an Authz object.

=head1 USAGE

=head1 DESCRIPTION

Perl library providing a layer of abstraction to the REST authz methods

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

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

None known.

=head1 AUTHOR

Daniel David Parry <perl@ddp.me.uk>

=head1 LICENSE AND COPYRIGHT

LICENSE: http://dev.perl.org/licenses/artistic.html

COPYRIGHT: (c) 2011 Daniel David Parry <perl@ddp.me.uk>
