#!/usr/bin/perl -w

package Sakai::Nakamura::Authn;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Apache::Sling::Authn);

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.06';

#{{{sub new
sub new {
    my ( $class, @args ) = @_;
    my $authn = $class->SUPER::new(@args);
    bless $authn, $class;
    return $authn;
}

#}}}

#{{{sub form_login
sub form_login {
    my ($authn)  = @_;
    my $username = $authn->{'Username'};
    my $password = $authn->{'Password'};
    my $res      = Apache::Sling::Request::request(
        \$authn,
        Sakai::Nakamura::AuthnUtil::form_login_setup(
            $authn->{'BaseURL'}, $username, $password
        )
    );
    my $success = Sakai::Nakamura::AuthnUtil::form_login_eval($res);
    my $message = "Form log in as user \"$username\" ";
    $message .= ( $success ? 'succeeded!' : 'failed!' );
    $authn->set_results( "$message", $res );
    return $success;
}

#}}}

#{{{sub form_logout
sub form_logout {
    my ($authn) = @_;
    my $res =
      Apache::Sling::Request::request( \$authn,
        Sakai::Nakamura::AuthnUtil::form_logout_setup( $authn->{'BaseURL'} ) );
    my $success = Sakai::Nakamura::AuthnUtil::form_logout_eval($res);
    my $message = 'Form log out ';
    $message .= ( $success ? 'succeeded!' : 'failed!' );
    $authn->set_results( "$message", $res );
    return $success;
}

#}}}

#{{{sub switch_user
sub switch_user {
    my ( $authn, $new_username, $new_password, $type, $check_basic ) = @_;
    if ( !defined $new_username ) {
        croak 'New username to switch to not defined';
    }
    if ( !defined $new_password ) {
        croak 'New password to use in switch not defined';
    }
    if (   ( $authn->{'Username'} !~ /^$new_username$/msx )
        || ( $authn->{'Password'} !~ /^$new_password$/msx ) )
    {
        $authn->{'Username'} = $new_username;
        $authn->{'Password'} = $new_password;
        if ( $authn->{'Type'} eq 'form' ) {

            # If we were previously using form auth then we must log
            # out with form auth, even if we are switching to basic auth.
            my $success = $authn->form_logout();
            if ( !$success ) {
                croak 'Form Auth log out for user "'
                  . $authn->{'Username'}
                  . '" at URL "'
                  . $authn->{'BaseURL'}
                  . "\" was unsuccessful\n";
            }
        }
        if ( defined $type ) {
            $authn->{'Type'} = $type;
        }
        $check_basic = ( defined $check_basic ? $check_basic : 0 );
        if ( $authn->{'Type'} eq 'basic' ) {
            if ($check_basic) {
                my $success = $authn->basic_login();
                if ( !$success ) {
                    croak
                      "Basic Auth log in for user \"$new_username\" at URL \""
                      . $authn->{'BaseURL'}
                      . "\" was unsuccessful\n";
                }
            }
            else {
                $authn->{'Message'} = 'Fast User Switch completed!';
            }
        }
        elsif ( $authn->{'Type'} eq 'form' ) {
            my $success = $authn->form_login();
            if ( !$success ) {
                croak "Form Auth log in for user \"$new_username\" at URL \""
                  . $authn->{'BaseURL'}
                  . "\" was unsuccessful\n";
            }
        }
        else {
            croak "Unsupported auth type: \"$type\"\n";
        }
    }
    else {
        $authn->{'Message'} = 'User already active, no need to switch!';
    }
    if ( $authn->{'Verbose'} >= 1 ) {
        Apache::Sling::Print::print_result($authn);
    }
    return 1;
}

#}}}

#{{{sub login_user
sub login_user {
    my ($authn) = @_;

    # Apply basic authentication to the user agent if url, username and
    # password are supplied:
    if (   defined $authn->{'BaseURL'}
        && defined $authn->{'Username'}
        && defined $authn->{'Password'} )
    {
        if ( $authn->{'Type'} eq 'basic' ) {
            my $success = $authn->basic_login();
            if ( !$success ) {
                if ( $authn->{'Verbose'} >= 1 ) {
                    Apache::Sling::Print::print_result($authn);
                }
                croak 'Basic Auth log in for user "'
                  . $authn->{'Username'}
                  . '" at URL "'
                  . $authn->{'BaseURL'}
                  . "\" was unsuccessful\n";
            }
        }
        elsif ( $authn->{'Type'} eq 'form' ) {
            my $success = $authn->form_login();
            if ( !$success ) {
                if ( $authn->{'Verbose'} >= 1 ) {
                    Apache::Sling::Print::print_result($authn);
                }
                croak 'Form Auth log in for user "'
                  . $authn->{'Username'}
                  . '" at URL "'
                  . $authn->{'BaseURL'}
                  . "\" was unsuccessful\n";
            }
        }
        else {
            croak 'Unsupported auth type: "' . $authn->{'Type'} . "\"\n";
        }
        if ( $authn->{'Verbose'} >= 1 ) {
            Apache::Sling::Print::print_result($authn);
        }
    }
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::Authn - Authenticate to a Sakai::Nakamura instance.

=head1 ABSTRACT

Useful utility functions for general Authn functionality.

=head1 USAGE

use Sakai::Nakamura::Authn;

=head1 DESCRIPTION

Library providing useful utility functions for general Authn functionality.

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

LWP::UserAgent

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

None known.

=head1 AUTHOR

Daniel David Parry <perl@ddp.me.uk>

=head1 LICENSE AND COPYRIGHT

LICENSE: http://dev.perl.org/licenses/artistic.html

COPYRIGHT: (c) 2011 Daniel David Parry <perl@ddp.me.uk>
