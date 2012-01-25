#!/usr/bin/perl -w
package Sakai::Nakamura;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Apache::Sling);
use Sakai::Nakamura::Authn;
use Sakai::Nakamura::User;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.07';

#{{{sub new
sub new {
    my ( $class, @args ) = @_;
    my $authn = $class->SUPER::new(@args);

    # Set the Referer to /dev/integrationtests in order to be
    # allowed to post to the Sakai Nakamura instance:
    $authn->{'Referer'} = "/dev/integrationtests";
    bless $authn, $class;
    return $authn;
}

#}}}

#{{{sub user_config

sub user_config {
    my ($class) = @_;
    my $profile_field;
    my $profile_section;
    my $profile_update;
    my $profile_value;
    my $user_config = $class->SUPER::user_config();
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
    if ( defined ${ $config->{'profile-update'} } ) {
        my $authn = new Sakai::Nakamura::Authn( \$nakamura );
        my $user  = new Sakai::Nakamura::User( \$authn, $nakamura->{'Verbose'},
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

=head1 VERSION

0.07

=head1 LICENSE AND COPYRIGHT

LICENSE: http://dev.perl.org/licenses/artistic.html

COPYRIGHT: Daniel David Parry <perl@ddp.me.uk>
