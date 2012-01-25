#!/usr/bin/perl -w

package Sakai::Nakamura::GroupUtil;

use 5.008001;
use strict;
use warnings;
use Carp;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.07';

#{{{sub role_member_add_setup

sub role_member_add_setup {
    my ( $base_url, $act_on_group, $act_on_role, $add_member ) = @_;
    if ( !defined $base_url ) { croak 'No base url defined to add against!'; }
    if ( !defined $act_on_group ) {
        croak 'No group name defined to add member to!';
    }
    if ( !defined $act_on_role ) {
        croak 'No role defined to add member to!';
    }
    if ( !defined $add_member ) { croak 'No member name defined to add!'; }
    my $post_variables =
      "\$post_variables = [':member','$add_member',':viewer','$add_member']";
    return
"post $base_url/system/userManager/group/$act_on_group-$act_on_role.update.json $post_variables";
}

#}}}

#{{{sub role_member_add_eval

sub role_member_add_eval {
    my ($res) = @_;
    return ( ${$res}->code eq '200' );
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::GroupUtil Methods to generate and check HTTP requests required for manipulating groups.

=head1 ABSTRACT

Utility library returning strings representing Rest queries that perform
group related actions in the system.

=head1 METHODS

=head2 add_setup

Returns a textual representation of the request needed to add the group to the
system.

=head2 member_add_setup

Returns a textual representation of the request needed to add add a member to a
group in the system.

=head2 member_add_eval

Check result of adding a member to a group in the system.

=head1 USAGE

use Sakai::Nakamura::GroupUtil;

=head1 DESCRIPTION

GroupUtil perl library essentially provides the request strings needed to
interact with group functionality exposed over the system rest interfaces.

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

COPYRIGHT: (c) 2011 Daniel David Parry <perl@ddp.me.uk>
