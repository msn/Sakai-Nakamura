#!/usr/bin/perl -w
package Sakai::Nakamura;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Apache::Sling);
use Sakai::Nakamura::Authn;
use Sakai::Nakamura::Content;
use Sakai::Nakamura::User;
use Sakai::Nakamura::World;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.11';

#{{{sub new
# sub new {
# my ( $class, @args ) = @_;
# my $authn = $class->SUPER::new(@args);

# Set the Referer to /dev/integrationtests in order to be
# allowed to post to the Sakai Nakamura instance:
# $authn->{'Referer'} = "/dev/integrationtests";
# bless $authn, $class;
# return $authn;
# }

#}}}

#{{{sub content_config

sub content_config {
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

#{{{sub content_run
sub content_run {
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
                $authn->{'LWP'} = $authn->user_agent();
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
            $content->upload_file( ${ $config->{'local'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-copyright'} } ) {
            $authn->login_user();
            $content->view_copyright( ${ $config->{'view-copyright'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-description'} } ) {
            $authn->login_user();
            $content->view_description( ${ $config->{'view-description'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-tags'} } ) {
            $authn->login_user();
            $content->view_tags( ${ $config->{'view-tags'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-title'} } ) {
            $authn->login_user();
            $content->view_title( ${ $config->{'view-title'} } );
            Apache::Sling::Print::print_result($content);
        }
        elsif ( defined ${ $config->{'view-visibility'} } ) {
            $authn->login_user();
            $content->view_visibility( ${ $config->{'view-visibility'} } );
            Apache::Sling::Print::print_result($content);
        }
        else {
            $nakamura->SUPER::content_run($config);
        }
    }
    return 1;
}

#}}}

#{{{sub user_config

sub user_config {
    my ($class) = @_;
    my $me;
    my $profile_field;
    my $profile_section;
    my $profile_update;
    my $profile_value;
    my $user_config = $class->SUPER::user_config();
    $user_config->{'me'}              = \$me;
    $user_config->{'profile-field'}   = \$profile_field;
    $user_config->{'profile-section'} = \$profile_section;
    $user_config->{'profile-update'}  = \$profile_update;
    $user_config->{'profile-value'}   = \$profile_value;
    return $user_config;
}

#}}}

#{{{sub user_run
sub user_run {
    my ( $nakamura, $config ) = @_;
    if ( !defined $config ) {
        croak 'No user config supplied!';
    }
    my $authn =
      defined $nakamura->{'Authn'}
      ? ${ $nakamura->{'Authn'} }
      : new Sakai::Nakamura::Authn( \$nakamura );

    if ( defined ${ $config->{'exists'} } ) {
        $authn->login_user();
        my $user = new Sakai::Nakamura::User( \$authn, $nakamura->{'Verbose'},
            $nakamura->{'Log'} );
        $user->check_exists( ${ $config->{'exists'} } );
        Apache::Sling::Print::print_result($user);
    }
    elsif ( defined ${ $config->{'me'} } ) {
        $authn->login_user();
        my $user = new Sakai::Nakamura::User( \$authn, $nakamura->{'Verbose'},
            $nakamura->{'Log'} );
        $user->me();
        Apache::Sling::Print::print_result($user);
    }
    elsif ( defined ${ $config->{'profile-update'} } ) {
        $authn->login_user();
        my $user = new Sakai::Nakamura::User( \$authn, $nakamura->{'Verbose'},
            $nakamura->{'Log'} );
        $user->profile_update(
            ${ $config->{'profile-field'} },
            ${ $config->{'profile-value'} },
            ${ $config->{'profile-update'} },
            ${ $config->{'profile-section'} }
        );
        Apache::Sling::Print::print_result($user);
    }
    else {
        $nakamura->SUPER::user_run($config);
    }
    return 1;
}

#}}}

#{{{sub world_config

sub world_config {
    my ($class) = @_;
    my $add;
    my $additions;
    my $id;
    my $title;
    my $description;
    my $tags;
    my $visibility;
    my $joinability;
    my $world_template;
    my %world_config = (
        'auth'           => \$class->{'Auth'},
        'help'           => \$class->{'Help'},
        'log'            => \$class->{'Log'},
        'man'            => \$class->{'Man'},
        'pass'           => \$class->{'Pass'},
        'threads'        => \$class->{'Threads'},
        'url'            => \$class->{'URL'},
        'user'           => \$class->{'User'},
        'verbose'        => \$class->{'Verbose'},
        'add'            => \$add,
        'additions'      => \$additions,
        'title'          => \$title,
        'description'    => \$description,
        'tags'           => \$tags,
        'visibility'     => \$visibility,
        'joinability'    => \$joinability,
        'world_template' => \$world_template
    );

    return \%world_config;
}

#}}}

#{{{sub world_run
sub world_run {
    my ( $nakamura, $config ) = @_;
    if ( !defined $config ) {
        croak 'No world config supplied!';
    }
    $nakamura->SUPER::check_forks;
    my $authn =
      defined $nakamura->{'Authn'}
      ? ${ $nakamura->{'Authn'} }
      : new Sakai::Nakamura::Authn( \$nakamura );

    if ( defined ${ $config->{'additions'} } ) {
        my $message =
          "Adding worlds from file \"" . ${ $config->{'additions'} } . "\":\n";
        Apache::Sling::Print::print_with_lock( "$message", $nakamura->{'Log'} );
        my @childs = ();
        for my $i ( 0 .. $nakamura->{'Threads'} ) {
            my $pid = fork;
            if ($pid) { push @childs, $pid; }    # parent
            elsif ( $pid == 0 ) {                # child
                    # Create a new separate user agent per fork in order to
                    # ensure cookie stores are separate, then log the user in:
                $authn->{'LWP'} = $authn->user_agent();
                $authn->login_user();
                my $user =
                  new Sakai::Nakamura::World( \$authn, $nakamura->{'Verbose'},
                    $nakamura->{'Log'} );
                $user->add_from_file( ${ $config->{'additions'} },
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
        $authn->login_user();
        my $world = new Sakai::Nakamura::World( \$authn, $nakamura->{'Verbose'},
            $nakamura->{'Log'} );
        if ( defined ${ $config->{'add'} } ) {
            $world->add(
                ${ $config->{'add'} },
                ${ $config->{'title'} },
                ${ $config->{'description'} },
                ${ $config->{'tags'} },
                ${ $config->{'visibility'} },
                ${ $config->{'joinability'} },
                ${ $config->{'world_template'} }
            );
            Apache::Sling::Print::print_result($world);
        }
    }
    return 1;
}

#}}}

1;
__END__

=head1 NAME

Sakai::Nakamura - Perl library for interacting with the sakai nakamura web framework

=head1 SYNOPSIS

  use Sakai::Nakamura

=head1 DESCRIPTION

The Sakai::Nakamura perl library is designed to provide a perl based interface on
to the Sakai::Nakamura web framework. 

=head1 METHODS

=head2 new

Return a new Nakamura object which provides all the configuration and run methods.

=head2 content_run

Given a content configuration object, executes the content functionality required.

=head2 user_config

Returns a link to a hash of configuration for use in manipulating content.

=head2 user_run

Given a user configuration object, executes the user functionality required.

=head2 world_config

Returns a link to a hash of configuration for use in manipulating worlds.

=head2 world_run

Given a world configuration object, executes the world functionality required.

=head2 EXPORT

None by default.

=head1 SEE ALSO

http://groups.google.co.uk/group/sakai-kernel

=head1 AUTHOR

D. D. Parry, E<lt>perl@ddp.me.ukE<gt>

=head1 LICENSE AND COPYRIGHT

LICENSE: http://dev.perl.org/licenses/artistic.html

COPYRIGHT: Daniel David Parry <perl@ddp.me.uk>
