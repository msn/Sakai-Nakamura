#!/usr/bin/perl -w

package Sakai::Nakamura::World;

use 5.008008;
use strict;
use warnings;
use Carp;
use Sakai::Nakamura::WorldUtil;

require Exporter;

use base qw(Exporter);

our @EXPORT_OK = ();

our $VERSION = '0.09';

#{{{sub new

sub new {
    my ( $class, $authn, $verbose, $log ) = @_;
    if ( !defined $authn ) { croak 'no authn provided!'; }
    my $response;
    $verbose = ( defined $verbose ? $verbose : 0 );
    my $world = {
        BaseURL  => ${$authn}->{'BaseURL'},
        Authn    => $authn,
        Message  => q{},
        Response => \$response,
        Verbose  => $verbose,
        Log      => $log
    };
    bless $world, $class;
    return $world;
}

#}}}

#{{{sub set_results
sub set_results {
    my ( $world, $message, $response ) = @_;
    $world->{'Message'}  = $message;
    $world->{'Response'} = $response;
    return 1;
}

#}}}

#{{{sub add
sub add {
    my ( $world, $id, $title, $description, $tags, $visibility, $joinability, $world_template ) = @_;
    my $res = Apache::Sling::Request::request(
        \$world,
        Sakai::Nakamura::WorldUtil::add_setup(
            $world->{'BaseURL'}, $id, ${$world->{'Authn'}}->{'Username'}, $title, $description, $tags, $visibility, $joinability, $world_template
        )
    );
    my $success = Sakai::Nakamura::WorldUtil::add_eval($res);
    my $message = "World: \"$id\" ";
    $message .= ( $success ? 'added!' : 'was not added!' );
    $world->set_results( "$message", $res );
    return $success;
}

#}}}

#{{{sub add_from_file
sub add_from_file {
    my ( $world, $file, $fork_id, $number_of_forks ) = @_;
    my $csv               = Text::CSV->new();
    my $count             = 0;
    my $number_of_columns = 0;
    my @column_headings;
    if ( defined $file && open my ($input), '<', $file ) {
        while (<$input>) {
            if ( $count++ == 0 ) {

                # Parse file column headings first to determine field names:
                if ( $csv->parse($_) ) {
                    @column_headings = $csv->fields();

                    # First field must be world:
                    if ( $column_headings[0] !~ /^[Ii][Dd]$/msx ) {
                        croak
'First CSV column must be the world ID, column heading must be "id". Found: "'
                          . $column_headings[0] . "\".\n";
                    }
                    $number_of_columns = @column_headings;
                }
                else {
                    croak 'CSV broken, failed to parse line: '
                      . $csv->error_input;
                }
            }
            elsif ( $fork_id == ( $count++ % $number_of_forks ) ) {
                my @properties;
                if ( $csv->parse($_) ) {
                    my @columns      = $csv->fields();
                    my $columns_size = @columns;

           # Check row has same number of columns as there were column headings:
                    if ( $columns_size != $number_of_columns ) {
                        croak
"Found \"$columns_size\" columns. There should have been \"$number_of_columns\".\nRow contents was: $_";
                    }
                    my $id       = $columns[0];
                    my $title;
                    my $description;
                    my $tags;
                    my $visibility;
                    my $joinability;
                    my $world_template;
                    for ( my $i = 2 ; $i < $number_of_columns ; $i++ ) {
                        my $heading = $column_headings[$i];
                        if ( $heading =~ /^[Tt][Ii][Tt][Ll][Ee]$/msx ) {
                            $title = $columns[$i];
                        }
                        elsif ( $heading =~ /^[Dd][Ee][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]$/msx ) {
                            $description = $columns[$i];
                        }
                        elsif ( $heading =~ /^[Tt][Aa][Gg][Ss]$/msx ) {
                            $tags = $columns[$i];
                        }
                        elsif ( $heading =~ /^[Vv][Ii][Ss][Ii][Bb][Ii][Ll][Ii][Tt][Yy]$/msx ) {
                            $visibility = $columns[$i];
                        }
                        elsif ( $heading =~ /^[Jj][Oo][Ii][Nn][Aa][Bb][Ii][Ll][Ii][Tt][Yy]$/msx ) {
                            $joinability = $columns[$i];
                        }
                        elsif ( $heading =~ /^[Ww][Oo][Rr][Ll][Dd][Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee]$/msx ) {
                            $world_template = $columns[$i];
                        }
                        else {
                           croak "Unsupported column heading \"$heading\" - please use: \"id\", \"title\", \"description\", \"tags\", \"visibility\", \"joinability\", \"world_template\"";
                        }
                    }
                    $world->add( $id, $title, $description, $tags, $visibility, $joinability, $world_template );
                    Apache::Sling::Print::print_result($world);
                }
                else {
                    croak q{CSV broken, failed to parse line: }
                      . $csv->error_input;
                }
            }
        }
        close $input or croak q{Problem closing input};
    }
    else {
        croak 'Problem adding from file!';
    }
    return 1;
}

#}}}

1;

__END__

=head1 NAME

Sakai::Nakamura::World - Manipulate Worlds in a Sakai Nakamura instance.

=head1 ABSTRACT

world related functionality for Sling implemented over rest APIs.

=head1 METHODS

=head2 new

Create, set up, and return a World Object.

=head2 set_results

Update the world object with the message and respsonse from the last method call.

=head2 add

Add a new world to the Sakai Nakamura System.

=head2 add_from_file

Add new worlds to the Sakai Nakamura System, based on entries in a specified file.

=head1 USAGE

use Sakai::Nakamura::World;

=head1 DESCRIPTION

Perl library providing a layer of abstraction to the REST world methods

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
