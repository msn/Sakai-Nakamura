#!/usr/bin/perl -w

package Sakai::Nakamura::Content;

use 5.008008;
use strict;
use warnings;
use Carp;
use Sakai::Nakamura::ContentUtil;

use base qw(Apache::Sling::Content);

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.10';

#{{{sub new
sub new {
    my ( $class, @args ) = @_;
    my $content = $class->SUPER::new(@args);
    # Add a class variable to track the last content path seen:
    $content->{'Path'} = q{};
    bless $content, $class;
    return $content;
}

#}}}

#{{{sub upload_file
sub upload_file {
    my ( $content, $local_path ) = @_;
    my $filename = q{};
    my $res = Apache::Sling::Request::request(
        \$content,
        Apache::Sling::ContentUtil::upload_file_setup(
            $content->{'BaseURL'}, $local_path, 'system/pool/createfile', $filename
        )
    );
    my $success  = Apache::Sling::ContentUtil::upload_file_eval($res);
    # Check whether initial upload succeeded:
    if ( ! $success ) {
        croak "Content: \"$local_path\" upload to /system/pool/createfile failed!";
    }
    # Obtain path from POST response body:
    my $content_path = ( ${$res}->content =~ m/"_path":"([^"]*)"/ )[0];
    if ( ! defined $content_path ) {
        croak 'Content path not found in JSON response to file upload';
    }
    $content_path = "/p/$content_path";
    my $content_filename = ( ${$res}->content =~ m/"sakai:pooled-content-file-name":"([^"]*)"/ )[0];
    if ( ! $content_filename =~ /.*\..*/ ) {
        croak "Content filename: '$content_filename' has no file extension";
    }
    my $content_fileextension = ($content_filename =~ m/([^.]+)$/)[0];
    # Add Meta data for file:
    $res = Apache::Sling::Request::request(
        \$content,
        Sakai::Nakamura::ContentUtil::add_file_metadata_setup(
            $content->{'BaseURL'}, "$content_path", $content_filename, $content_fileextension
        )
    );
    $success  = Sakai::Nakamura::ContentUtil::add_file_metadata_eval($res);

    # Check whether adding metadata succeeded:
    if ( ! $success ) {
        croak "Adding metadata for \"$content_path\" failed!";
    }
    # Add permissions on file:
    $res = Apache::Sling::Request::request(
        \$content,
        Sakai::Nakamura::ContentUtil::add_file_perms_setup(
            $content->{'BaseURL'}, "$content_path"
        )
    );
    $success  = Sakai::Nakamura::ContentUtil::add_file_perms_eval($res);
    # Check whether setting file permissions succeeded:
    if ( ! $success ) {
        croak "Adding file perms for \"$content_path\" failed!";
    }
    my $message = "File upload of \"$local_path\" to \"$content_path\" succeeded";
    $content->set_results( "$message", $res );
    return $success;
}

#}}}

#{{{sub upload_from_file
sub upload_from_file {
    my ( $content, $file, $fork_id, $number_of_forks ) = @_;
    $fork_id = defined $fork_id ? $fork_id : 0;
    $number_of_forks = defined $number_of_forks ? $number_of_forks : 1;
    my $count = 0;
    if ( !defined $file ) {
        croak 'File to upload from not defined';
    }
    if ( open my ($input), '<', $file ) {
        while (<$input>) {
            if ( $fork_id == ( $count++ % $number_of_forks ) ) {
                chomp;
                $_ =~ /^\s*(\S.*?)\s*$/msx
                  or croak "/Problem parsing content to add: '$_'";
                my $local_path = $1;
                $content->upload_file( $local_path );
                Apache::Sling::Print::print_result($content);
            }
        }
        close $input or croak 'Problem closing input!';
    }
    else {
        croak "Problem opening file: '$file'";
    }
    return 1;
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::Content - Manipulate Content in a Sakai Nakamura instance.

=head1 ABSTRACT

content related functionality for Sling implemented over rest APIs.

=head1 METHODS

=head2 new

Create, set up, and return a Content object.

=head1 USAGE

=head1 DESCRIPTION

Perl library providing a layer of abstraction to the REST content methods

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
