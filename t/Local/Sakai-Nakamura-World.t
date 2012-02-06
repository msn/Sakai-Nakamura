# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Apache-Sling.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 17;
use Test::Exception;
BEGIN { use_ok( 'Sakai::Nakamura' ); }
BEGIN { use_ok( 'Sakai::Nakamura::Authn' ); }
BEGIN { use_ok( 'Sakai::Nakamura::World' ); }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# nakamura object:
my $nakamura = Sakai::Nakamura->new();
isa_ok $nakamura, 'Sakai::Nakamura', 'nakamura';
$nakamura->{'Verbose'} = 1;
$nakamura->{'Log'} = 'log.txt';

my $authn = new Sakai::Nakamura::Authn(\$nakamura);
throws_ok { my $world = new Sakai::Nakamura::World() } qr/no authn provided!/, 'Check new function croaks without authn';

my $world = new Sakai::Nakamura::World(\$authn,'1','log.txt');
isa_ok $world, 'Sakai::Nakamura::World', 'world';
ok( $world->{ 'BaseURL' } eq 'http://localhost:8080', 'Check BaseURL set' );
ok( $world->{ 'Log' }     eq 'log.txt',               'Check Log set' );
ok( $world->{ 'Message' } eq '',                      'Check Message set' );
ok( $world->{ 'Verbose' } == 1,                       'Check Verbosity set' );
ok( defined $world->{ 'Authn' },                      'Check authn defined' );
ok( defined $world->{ 'Response' },                   'Check response defined' );

$world->set_results( 'Test Message', undef );
ok( $world->{ 'Message' } eq 'Test Message', 'Message now set' );
ok( ! defined $world->{ 'Response' }, 'Check response no longer defined' );

throws_ok { $world->add() } qr/No id defined to add!/, 'Check add function croaks without id';
throws_ok { $world->add_from_file() } qr/Problem adding from file!/, 'Check add_from_file function croaks without id';
ok( $world->add_from_file('/dev/null'), 'Check add_from_file function with blank file' );
