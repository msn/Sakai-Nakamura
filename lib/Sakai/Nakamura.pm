#!/usr/bin/perl -w
package Sakai::Nakamura;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Apache::Sling);
use Sakai::Nakamura::Authn;
require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.12';

1;
__END__

=head1 NAME

Sakai::Nakamura - Perl library for interacting with the sakai nakamura web framework

=head1 SYNOPSIS

  use Sakai::Nakamura

=head1 DESCRIPTION

The Sakai::Nakamura perl library is designed to provide a perl based interface on
to the Sakai::Nakamura web framework. 

=head2 EXPORT

None by default.

=head1 SEE ALSO

http://groups.google.co.uk/group/sakai-kernel

=head1 AUTHOR

D. D. Parry, E<lt>perl@ddp.me.ukE<gt>

=head1 LICENSE AND COPYRIGHT

LICENSE: http://dev.perl.org/licenses/artistic.html

COPYRIGHT: Daniel David Parry <perl@ddp.me.uk>
