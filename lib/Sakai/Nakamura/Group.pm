#!/usr/bin/perl -w

package Sakai::Nakamura::Group;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Apache::Sling::Group);
use Sakai::Nakamura::GroupUtil;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.08';

#{{{sub new

sub new {
    my ( $class, @args ) = @_;
    my $group = $class->SUPER::new(@args);
    bless $group, $class;
    return $group;
}

#}}}


#{{{sub role_member_add
sub role_member_add {
    my ( $group, $act_on_group, $act_on_role, $add_member ) = @_;
    my $res = Apache::Sling::Request::request(
        \$group,
        Apache::Sling::GroupUtil::member_add_setup(
            $group->{'BaseURL'}, $act_on_group, $act_on_role, $add_member
        )
    );
    my $success = Sakai::Nakamura::GroupUtil::role_member_add_eval($res);
    my $message = "Member: \"$add_member\" ";
    $message .= ( $success ? 'added' : 'was not added' );
    $message .= " to role \"$act_on_role\" in group \"$act_on_group\"!";
    $group->set_results( "$message", $res );
    return $success;
}

#}}}

#{{{sub role_member_add_from_file
sub role_member_add_from_file {
    return 1;
}

#}}}

#{{{sub role_member_delete
sub role_member_delete {
    return 1;
}

#}}}

#{{{sub role_member_exists
sub role_member_exists {
    return 1;
}

#}}}

#{{{sub role_member_view
sub role_member_view {
    return 1;
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::Group - Manipulate Groups in a Sakai Nakamura instance.

=head1 ABSTRACT

group related functionality for Sling implemented over rest APIs.

=head1 METHODS

=head2 new

Create, set up, and return a Group Object.

=head1 USAGE

use Sakai::Nakamura::Group;

=head1 DESCRIPTION

Perl library providing a layer of abstraction to the REST group methods

Sakai Nakamura adds another layer to the traditional
Apache::Sling view of Groups. Rather than just:
Groups -> Members, there now exists:
Groups -> Roles -> Members

Roles are the top level group members, they define what members of
those roles are able to do in the group.

Role members are the actual system users - they get added to a role and
that defines what they are able to do in a group:

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
