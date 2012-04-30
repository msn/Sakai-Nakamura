#!/usr/bin/perl -w

package Sakai::Nakamura::SearchUtil;

use 5.008001;
use strict;
use warnings;
use Carp;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.13';

#{{{sub search_all_setup

sub search_all_setup {
    my ( $base_url, $query, $sort_on, $sort_order, $page, $items ) = @_;
    if ( !defined $base_url ) {
        croak 'No base url defined to search against!';
    }
    if ( !defined $query ) {
        croak 'No query defined to search for!';
    }
    $sort_on    = defined $sort_on    ? $sort_on    : '_lastModified';
    $sort_order = defined $sort_order ? $sort_order : 'desc';
    $page       = defined $page       ? $page       : '0';
    $items      = defined $items      ? $items      : '18';
    return
"get $base_url/var/search/general.json?q=$query&sortOn=$sort_on&sortOrder=$sort_order&page=$page&items=$items";
}

#}}}

#{{{sub search_all_eval

sub search_all_eval {
    my ($res) = @_;
    return ( ${$res}->code eq '200' );
}

#}}}

#{{{sub search_people_setup

sub search_people_setup {
    my ( $base_url, $query, $sort_on, $sort_order, $page, $items ) = @_;
    if ( !defined $base_url ) {
        croak 'No base url defined to search against!';
    }
    if ( !defined $query ) {
        croak 'No query defined to search for!';
    }
    $sort_on    = defined $sort_on    ? $sort_on    : '_lastModified';
    $sort_order = defined $sort_order ? $sort_order : 'desc';
    $page       = defined $page       ? $page       : '0';
    $items      = defined $items      ? $items      : '18';
    return
"get $base_url/var/search/users.infinity.json?q=$query&sortOn=$sort_on&sortOrder=$sort_order&page=$page&items=$items";
}

#}}}

#{{{sub search_people_eval

sub search_people_eval {
    my ($res) = @_;
    return ( ${$res}->code eq '200' );
}

#}}}

#{{{sub search_content_setup

sub search_content_setup {
    my ( $base_url, $query, $sort_on, $sort_order, $page, $items ) = @_;
    if ( !defined $base_url ) {
        croak 'No base url defined to search against!';
    }
    if ( !defined $query ) {
        croak 'No query defined to search for!';
    }
    $sort_on    = defined $sort_on    ? $sort_on    : '_lastModified';
    $sort_order = defined $sort_order ? $sort_order : 'desc';
    $page       = defined $page       ? $page       : '0';
    $items      = defined $items      ? $items      : '18';
    return
"get $base_url/var/search/pool/all.infinity.json?q=$query&sortOn=$sort_on&sortOrder=$sort_order&page=$page&items=$items";
}

#}}}

#{{{sub search_content_eval

sub search_content_eval {
    my ($res) = @_;
    return ( ${$res}->code eq '200' );
}

#}}}

#{{{sub search_world_setup

sub search_world_setup {
    my ( $base_url, $query, $world, $sort_on, $sort_order, $page, $items ) = @_;
    if ( !defined $base_url ) {
        croak 'No base url defined to search against!';
    }
    if ( !defined $query ) {
        croak 'No query defined to search for!';
    }
    $sort_on    = defined $sort_on    ? $sort_on    : '_lastModified';
    $sort_order = defined $sort_order ? $sort_order : 'desc';
    $page       = defined $page       ? $page       : '0';
    $items      = defined $items      ? $items      : '18';
    return "get
$base_url/var/search/groups.infinity.json?q=$query&sortOn=$sort_on&sortOrder=$sort_order&category=$world&page=$page&items=$items";
}

#}}}

#{{{sub search_world_eval

sub search_world_eval {
    my ($res) = @_;
    return ( ${$res}->code eq '200' );
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::SearchUtil Methods to generate and check HTTP requests required
for running searches.

=head1 ABSTRACT

Utility library returning strings representing Rest queries that perform
search related actions in the system.

=head1 METHODS

=head2 search_all_setup

Returns a textual representation of the request needed to search across all
types of data.

=head2 search_all_eval

Verify whether the attempt to search across all types of data succeeded.

=head2 search_people_setup

Returns a textual representation of the request needed to search across people.

=head2 search_people_eval

Verify whether the attempt to search across people succeeded.

=head2 search_content_setup

Returns a textual representation of the request needed to search across content.

=head2 search_content_eval

Verify whether the attempt to search across content succeeded.

=head2 search_world_setup

Returns a textual representation of the request needed to search across worlds.

=head2 search_world_eval

Verify whether the attempt to search across worlds succeeded.

=head1 USAGE

use Sakai::Nakamura::SearchUtil;

=head1 DESCRIPTION

SearchUtil perl library essentially provides the request strings needed to
interact with search functionality exposed over the system rest interfaces.

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

COPYRIGHT: (c) 2012 Daniel David Parry <perl@ddp.me.uk>
