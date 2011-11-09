#!/usr/bin/perl

#{{{imports
use warnings;
use strict;
use Carp;
use version; our $VERSION = qv('0.0.1');
use Getopt::Long qw(:config bundling);
use Pod::Usage;
use Sakai::Nakamura;

#}}}

#{{{options parsing
my $sling  = Sakai::Nakamura->new;
my $config = $sling->user_config;

GetOptions(
    $config,
    'help|?',              'man|M',
    'pass|p=s',            'url|U=s',
    'user|u=s',            'additions|A=s'
) or pod2usage(2);

if ( $sling->{'Help'} ) { pod2usage( -exitstatus => 0, -verbose => 1 ); }
if ( $sling->{'Man'} )  { pod2usage( -exitstatus => 0, -verbose => 2 ); }

#}}}

$sling->user_run($config);

1;

__END__

#{{{Documentation
=head1 SYNOPSIS

user perl script. Provides a means of managing users in sling from the command
line.

=head1 OPTIONS

Usage: perl user.pl [-OPTIONS [-MORE_OPTIONS]] [--] [PROGRAM_ARG1 ...]
The following options are accepted:

 --additions or -A (file)            - file containing list of users to be added.
 --help or -?                        - view the script synopsis and options.
 --man or -M                         - view the full script documentation.
 --pass or -p (password)             - Password of user performing actions.
 --url or -U (URL)                   - URL for system being tested against.
 --user or -u (username)             - Name of user to perform any actions as.

Options may be merged together. -- stops processing of options.
Space is not required between options and their arguments.
For full details run: perl user.pl --man

=head1 Example Usage

=over

=item Bulk add users from file users.txt

 perl user.pl -U http://localhost:8080 -u admin -p admin users.txt

=back

=cut

=head1 LICENSE AND COPYRIGHT

LICENSE: http://dev.perl.org/licenses/artistic.html

COPYRIGHT: Daniel David Parry <perl@ddp.me.uk>
#}}}
