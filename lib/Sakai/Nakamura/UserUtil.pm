#!/usr/bin/perl -w

package Sakai::Nakamura::UserUtil;

use 5.008008;
use strict;
use warnings;
use Carp;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.04';

#{{{sub me_setup

sub me_setup {
    my ($base_url) = @_;
    if ( !defined $base_url ) {
        croak 'No base url to check existence against!';
    }
    return "get $base_url/system/me";
}

#}}}

#{{{sub me_eval

sub me_eval {
    my ($res) = @_;
    return ( ${$res}->code eq '200' );
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::UserUtil - Methods to generate and check HTTP requests required for manipulating users.

=head1 ABSTRACT

Utility library returning strings representing Rest queries that perform
user related actions in the system.

=head1 METHODS

=head2 me_setup

Returns a textual representation of the request needed to return information
about the current user.

=head2 me_eval

Inspects the result returned from issuing the request generated in me_setup
returning true if the result indicates information was returned successfully,
else false.

=head1 USAGE

use Sakai::Nakamura::UserUtil;

=head1 DESCRIPTION

UserUtil perl library essentially provides the request strings needed to
interact with user functionality exposed over the system rest interfaces.

Each interaction has a setup and eval method. setup provides the request,
whilst eval interprets the response to give further information about the
result of performing the request.

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

COPYRIGHT: (c) 2010 Daniel David Parry <perl@ddp.me.uk>

