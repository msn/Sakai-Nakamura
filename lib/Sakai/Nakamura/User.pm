#!/usr/bin/perl -w

package Sakai::Nakamura::User;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Apache::Sling::User);
use Sakai::Nakamura::UserUtil;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.05';

#{{{sub new

sub new {
    my ( $class, @args ) = @_;
    my $user = $class->SUPER::new(@args);
    bless $user, $class;
    return $user;
}

#}}}

#{{{sub me
sub me {
    my ($user) = @_;
    my $res =
      Apache::Sling::Request::request( \$user,
        Sakai::Nakamura::UserUtil::me_setup( $user->{'BaseURL'} ) );
    my $success = Sakai::Nakamura::UserUtil::me_eval($res);
    my $message = (
        $success
        ? ${$res}->content
        : 'Problem fetching details for current user'
    );
    $user->set_results( "$message", $res );
    return $success;
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::User - Methods for manipulating users in a Sakai Nakamura system.

=head1 ABSTRACT

user related functionality for Sling implemented over rest APIs.

=head1 METHODS

=head2 new

Create, set up, and return a User Agent.

=head1 USAGE

use Sakai::Nakamura::User;

=head1 DESCRIPTION

Perl library providing a layer of abstraction to the REST user methods

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
