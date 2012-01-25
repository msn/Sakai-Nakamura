# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sakai-Nakamura.t'

#########################

use Test::More tests => 5;
use Test::Exception;
BEGIN { use_ok('Sakai::Nakamura') };

#########################
# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $nakamura = Sakai::Nakamura->new();
isa_ok $nakamura, 'Sakai::Nakamura', 'nakamura';
my $user_config = $nakamura->user_config;
ok( defined $user_config );
throws_ok { $nakamura->user_run } qr/No user config supplied!/, 'Check user_run function croaks without config';
ok( $nakamura->user_run( $user_config ) );
