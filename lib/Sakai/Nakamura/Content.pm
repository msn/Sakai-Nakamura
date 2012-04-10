#!/usr/bin/perl -w

package Sakai::Nakamura::Content;

use 5.008008;
use strict;
use warnings;
use Carp;
use JSON;
use Getopt::Long qw(:config bundling);
use Pod::Usage;
use Sakai::Nakamura::ContentUtil;
use Sakai::Nakamura;

use base qw(Apache::Sling::Content);

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = qw(run);

our $VERSION = '0.11';

#{{{sub new
sub new {
    my ( $class, @args ) = @_;
    my $content = $class->SUPER::new(@args);

    # Add a class variable to track the last content path seen:
    $content->{'Path'} = q{};
    # Add a class variable to track the last comment made:
    $content->{'Comment'} = q{};
    bless $content, $class;
    return $content;
}

#}}}

#{{{sub command_line
sub command_line {
  my @ARGV = @_;
  # options parsing
  my $nakamura = Sakai::Nakamura->new;
  my $config   = config($nakamura);

  GetOptions(
    $config,              'auth=s',
    'help|?',             'log|L=s',
    'man|M',              'pass|p=s',
    'threads|t=s',        'url|U=s',
    'user|u=s',           'verbose|v+',
    'add|a',              'additions|A=s',
    'copy|c',             'delete|d',
    'exists|e',           'filename|n=s',
    'local|l=s',          'move|m',
    'property|P=s',       'remote|r=s',
    'remote-source|S=s',  'replace|R',
    'view|V',             'view-copyright=s',
    'view-description=s', 'view-tags=s',
    'view-title=s',       'view-visibility=s'
  ) or help();

  if ( $nakamura->{'Help'} ) { help(); }
  if ( $nakamura->{'Man'} )  { pod2usage( -exitstatus => 0, -verbose => 2 ); }

  run($nakamura,$config);
    return 1;
}

#}}}

#{{{sub comment_add
sub comment_add {
    my ( $content, $comment, $remote_dest ) = @_;
    $remote_dest =
      defined $remote_dest
      ? Apache::Sling::URL::strip_leading_slash($remote_dest)
      : $content->{'Path'};

    my $res      = Apache::Sling::Request::request(
        \$content,
        Sakai::Nakamura::ContentUtil::comment_add_setup(
            $content->{'BaseURL'},    $remote_dest,
            $comment
        )
    );
    my $success = Sakai::Nakamura::ContentUtil::comment_add_eval($res);
    my $message = (
        $success
        ? 'Comment added'
        : 'Problem adding comment to content'
    );
    $content->set_results( "$message", $res );
    return $success;
}

#}}}

#{{{sub config

sub config {
    my ($class) = @_;
    my $view_copyright;
    my $view_description;
    my $view_tags;
    my $view_title;
    my $view_visibility;
    my $content_config = $class->SUPER::content_config();
    $content_config->{'view-copyright'}   = \$view_copyright;
    $content_config->{'view-description'} = \$view_description;
    $content_config->{'view-tags'}        = \$view_tags;
    $content_config->{'view-title'}       = \$view_title;
    $content_config->{'view-visibility'}  = \$view_visibility;
    return $content_config;
}

#}}}

#{{{ sub help
sub help {

  print "Usage: perl $0 [-OPTIONS [-MORE_OPTIONS]] [--] [PROGRAM_ARG1 ...]\n";
  print "The following options are accepted:\n";

  print " --additions or -A (file)          - File containing list of content to be uploaded.\n";
  print " --add or -a                       - Add content.\n";
  print " --auth (type)                     - Specify auth type. If ommitted, default is used.\n";
  print " --copy or -c                      - Copy content.\n";
  print " --delete or -d                    - Delete content.\n";
  print " --filename or -n (filename)       - Specify file name to use for content upload.\n";
  print " --help or -?                      - view the script synopsis and options.\n";
  print " --local or -l (localPath)         - Local path to content to upload.\n";
  print " --log or -L (log)                 - Log script output to specified log file.\n";
  print " --man or -M                       - view the full script documentation.\n";
  print " --move or -m                      - Move content.\n";
  print " --pass or -p (password)           - Password of user performing content manipulations.\n";
  print " --property or -P (property)       - Specify property to set on node.\n";
  print " --remote or -r (remoteNode)       - specify remote destination under JCR root to act on.\n";
  print " --remote-source or -S (remoteSrc) - specify remote source node under JCR root to act on.\n";
  print " --replace or -R                   - when copying or moving, overwrite remote destination if it exists.\n";
  print " --threads or -t (threads)         - Used with -A, defines number of parallel\n";
  print "                                     processes to have running through file.\n";
  print " --url or -U (URL)                 - URL for system being tested against.\n";
  print " --user or -u (username)           - Name of user to perform content manipulations as.\n";
  print " --verbose or -v or -vv or -vvv    - Increase verbosity of output.\n";
  print " --view or -V (actOnContent)       - view details for specified content in json format.\n";
  print " --view-copyright (remoteNode)     - view copyright for specified remote content.\n";
  print " --view-description (remoteNode)   - view description for specified remote content.\n";
  print " --view-tags (remoteNode)          - view tags for specified remote content.\n";
  print " --view-title (remoteNode)         - view title for specified remote content.\n";
  print " --view-visibility (remoteNode)    - view visibility setting for specified remote content.\n\n";

  print "Options may be merged together. -- stops processing of options.\n";
  print "Space is not required between options and their arguments.\n";
  print "For full details run: perl $0 --man\n";

#content perl script. Provides a means of uploading content into sling from the
#command line. The script also acts as a reference implementation for the
#Content perl library.

=head1 Example Usage

=over

=item Authenticate and add a node at /test:

 perl content.pl -U http://localhost:8080 -a -r /test -u admin -p admin

=item Authenticate and add a node at /test with property p1 set to v1:

 perl content.pl -U http://localhost:8080 -a -r /test -P p1=v1 -u admin -p admin

=item Authenticate and add a node at /test with property p1 set to v1, and p2 set to v2:

 perl content.pl -U http://localhost:8080 -a -r /test -P p1=v1 -P p2=v2 -u admin -p admin

=item View json for node at /test:

 perl content.pl -U http://localhost:8080 -V -r /test

=item Check whether node at /test exists:

 perl content.pl -U http://localhost:8080 -V -r /test

=item Authenticate and copy content at /test to /test2

 perl content.pl -U http://localhost:8080 -c -S /test -r /test2 -u admin -p admin

=item Authenticate and move content at /test to /test2, replacing test2 if it already exists

 perl content.pl -U http://localhost:8080 -m -S /test -r /test2 -R -u admin -p admin

=item Authenticate and delete content at /test

 perl content.pl -U http://localhost:8080 -d -r /test -u admin -p admin

=back

=cut

}
#}}}

#{{{sub run
sub run {
    my ( $nakamura, $config ) = @_;
    if ( !defined $config ) {
        croak 'No content config supplied!';
    }
    $nakamura->check_forks;
    ${ $config->{'remote'} } =
      Apache::Sling::URL::strip_leading_slash( ${ $config->{'remote'} } );
    ${ $config->{'remote-source'} } = Apache::Sling::URL::strip_leading_slash(
        ${ $config->{'remote-source'} } );
    my $authn =
      defined $nakamura->{'Authn'}
      ? ${ $nakamura->{'Authn'} }
      : new Sakai::Nakamura::Authn( \$nakamura );

    my $success = 1;

    if ( defined ${ $config->{'additions'} } ) {
        my $message =
          "Adding content from file \"" . ${ $config->{'additions'} } . "\":\n";
        Apache::Sling::Print::print_with_lock( "$message", $nakamura->{'Log'} );
        my @childs = ();
        for my $i ( 0 .. $nakamura->{'Threads'} ) {
            my $pid = fork;
            if ($pid) { push @childs, $pid; }    # parent
            elsif ( $pid == 0 ) {                # child
                    # Create a new separate user agent per fork in order to
                    # ensure cookie stores are separate, then log the user in:
                $authn->{'LWP'} = $authn->user_agent($nakamura->{'Referer'});
                $authn->login_user();
                my $content =
                  new Sakai::Nakamura::Content( \$authn, $nakamura->{'Verbose'},
                    $nakamura->{'Log'} );
                $content->upload_from_file( ${ $config->{'additions'} },
                    $i, $nakamura->{'Threads'} );
                exit 0;
            }
            else {
                croak "Could not fork $i!";
            }
        }
        foreach (@childs) { waitpid $_, 0; }
    }
    else {
        my $content =
          new Sakai::Nakamura::Content( \$authn, $nakamura->{'Verbose'},
            $nakamura->{'Log'} );
        if ( defined ${ $config->{'local'} } ) {
            $authn->login_user();
            $success = $content->upload_file( ${ $config->{'local'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-copyright'} } ) {
            $authn->login_user();
            $success = $content->view_copyright( ${ $config->{'view-copyright'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-description'} } ) {
            $authn->login_user();
            $success = $content->view_description( ${ $config->{'view-description'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-tags'} } ) {
            $authn->login_user();
            $success = $content->view_tags( ${ $config->{'view-tags'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-title'} } ) {
            $authn->login_user();
            $success = $content->view_title( ${ $config->{'view-title'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-visibility'} } ) {
            $authn->login_user();
            $success = $content->view_visibility( ${ $config->{'view-visibility'} } );
            Apache::Sling::Print::print_result($content);
        }
        else {
            $success = $content->SUPER::run($nakamura,$config);
        }
    }
    return $success;
}

#}}}

#{{{sub upload_file
sub upload_file {
    my ( $content, $local_path ) = @_;
    my $filename = q{};
    my $res      = Apache::Sling::Request::request(
        \$content,
        Apache::Sling::ContentUtil::upload_file_setup(
            $content->{'BaseURL'},    $local_path,
            'system/pool/createfile', $filename
        )
    );
    my $success = Apache::Sling::ContentUtil::upload_file_eval($res);

    # Check whether initial upload succeeded:
    if ( !$success ) {
        croak
          "Content: \"$local_path\" upload to /system/pool/createfile failed!";
    }

    # Obtain path from POST response body:
    my $content_path = ( ${$res}->content =~ m/"_path":"([^"]*)"/x )[0];
    if ( !defined $content_path ) {
        croak 'Content path not found in JSON response to file upload';
    }
    $content_path = "p/$content_path";
    my $content_filename =
      ( ${$res}->content =~ m/"sakai:pooled-content-file-name":"([^"]*)"/x )[0];
    if ( !$content_filename =~ /.*\..*/x ) {
        croak "Content filename: '$content_filename' has no file extension";
    }
    my $content_fileextension = ( $content_filename =~ m/([^.]+)$/x )[0];

    # Add Meta data for file:
    $res = Apache::Sling::Request::request(
        \$content,
        Sakai::Nakamura::ContentUtil::add_file_metadata_setup(
            $content->{'BaseURL'}, "$content_path",
            $content_filename,     $content_fileextension
        )
    );
    $success = Sakai::Nakamura::ContentUtil::add_file_metadata_eval($res);

    # Check whether adding metadata succeeded:
    if ( !$success ) {
        croak "Adding metadata for \"$content_path\" failed!";
    }

    # Add permissions on file:
    $res = Apache::Sling::Request::request(
        \$content,
        Sakai::Nakamura::ContentUtil::add_file_perms_setup(
            $content->{'BaseURL'}, "$content_path"
        )
    );
    $success = Sakai::Nakamura::ContentUtil::add_file_perms_eval($res);

    # Check whether setting file permissions succeeded:
    if ( !$success ) {
        croak "Adding file perms for \"$content_path\" failed!";
    }
    my $message =
      "File upload of \"$local_path\" to \"$content_path\" succeeded";
    $content->set_results( "$message", $res );
    $content->{'Path'} = $content_path;
    return $success;
}

#}}}

#{{{sub upload_from_file
sub upload_from_file {
    my ( $content, $file, $fork_id, $number_of_forks ) = @_;
    $fork_id         = defined $fork_id         ? $fork_id         : 0;
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
                $content->upload_file($local_path);
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

#{{{sub view_attribute
sub view_attribute {
    my ( $content, $remote_dest, $attribute_name, $nakamura_name, $missing_ok )
      = @_;
    $remote_dest =
      defined $remote_dest
      ? Apache::Sling::URL::strip_leading_slash($remote_dest)
      : $content->{'Path'};

    # By default the attribute must be present in the full JSON:
    $missing_ok = defined $missing_ok ? $missing_ok : 0;
    my $json_success = $content->view_full_json($remote_dest);
    if ( !$json_success ) {
        return $json_success;
    }
    my $content_json = from_json( $content->{'Message'} );
    my $attribute    = $content_json->{$nakamura_name};

    # merge an array attribute into a string:
    if ( ref($attribute) eq 'ARRAY' ) {
        $attribute = join( ',', @{$attribute} );
    }

    # If the attribute is undefined but allowed to be
    # missing then set it to an empty string:
    if ( !defined $attribute && $missing_ok ) {
        $attribute = q{};
    }
    my $success = defined $attribute;
    $content->{'Message'} =
      $success ? $attribute : "Problem viewing $attribute_name";
    return $success;
}

#}}}

#{{{sub view_copyright
sub view_copyright {
    my ( $content, $remote_dest ) = @_;
    my $success =
      $content->view_attribute( $remote_dest, 'copyright', 'sakai:copyright' );
    return $success;
}

#}}}

#{{{sub view_description
sub view_description {
    my ( $content, $remote_dest ) = @_;
    my $success = $content->view_attribute( $remote_dest, 'description',
        'sakai:description', 1 );
    return $success;
}

#}}}

#{{{sub view_tags
sub view_tags {
    my ( $content, $remote_dest ) = @_;
    my $success =
      $content->view_attribute( $remote_dest, 'tags', 'sakai:tags', 1 );
    return $success;
}

#}}}

#{{{sub view_title
sub view_title {
    my ( $content, $remote_dest ) = @_;
    my $success = $content->view_attribute( $remote_dest, 'title',
        'sakai:pooled-content-file-name' );
    return $success;
}

#}}}

#{{{sub view_visibility
sub view_visibility {
    my ( $content, $remote_dest ) = @_;
    my $success = $content->view_attribute( $remote_dest, 'visibility',
        'sakai:permissions' );
    return $success;
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

=head2 upload_file

Upload a file in to the system.

=head2 upload_from_file

Upload content listed in a file in to the system.

=head2 view_copyright

View the copyright of a content item.

=head2 view_description

View the description of a content item.

=head2 view_tags

View 1 or more tags for a content item.

=head2 view_title

View the title of a content item.

=head2 view_visibility

View the visibility of a content item.

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
