# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sakai-Nakamura.t'

#########################

use Test::More tests => 11;
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

my $content_config = $nakamura->content_config;
ok( defined $content_config );
throws_ok { $nakamura->content_run } qr/No content config supplied!/, 'Check content_run function croaks without config';
ok( $nakamura->content_run( $content_config ) );

my $world_config = $nakamura->world_config;
ok( defined $world_config );
throws_ok { $nakamura->world_run } qr/No world config supplied!/, 'Check world_run function croaks without config';
ok( $nakamura->world_run( $world_config ) );
