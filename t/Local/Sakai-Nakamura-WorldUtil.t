# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Apache-Sling.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
use Test::Exception;
BEGIN { use_ok( 'Sakai::Nakamura::WorldUtil' ); }
BEGIN { use_ok( 'HTTP::Response' ); }

my $res = HTTP::Response->new( '200' );

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
my @properties = '';
throws_ok { Sakai::Nakamura::WorldUtil::add_setup() } qr/No base url defined to add against!/, 'Check add_setup function croaks without base url';
throws_ok { Sakai::Nakamura::WorldUtil::add_setup( 'http://localhost:8080' ) } qr/No id defined to add!/, 'Check add_setup function croaks without id';
