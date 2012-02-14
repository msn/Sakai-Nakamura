#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 11;
use Test::Exception;

my $sling_host = 'http://localhost:8080';
my $super_user = 'admin';
my $super_pass = 'admin';
my $verbose    = 0;
my $log;

BEGIN { use_ok( 'Sakai::Nakamura' ); }

my $nakamura = Sakai::Nakamura->new();
isa_ok $nakamura, 'Sakai::Nakamura', 'nakamura';

$nakamura->{'URL'}     = $sling_host;
$nakamura->{'Verbose'} = $verbose;
$nakamura->{'Log'}     = $log;
$nakamura->{'User'}    = $super_user;
$nakamura->{'Pass'}    = $super_pass;

my $user_config = $nakamura->user_config;
ok( defined $user_config );
throws_ok { $nakamura->user_run } qr/No user config supplied!/, 'Check user_run function croaks without config';
ok( $nakamura->user_run( $user_config ) );
my $me = 1;
$user_config->{'me'} = \$me;
ok( $nakamura->user_run( $user_config ) );
$user_config->{'me'} = undef;
my $profile_update = $super_user;
$user_config->{'profile-update'} = \$profile_update;
throws_ok { $nakamura->user_run( $user_config ) } qr/No profile field to update specified!/, 'Check user_run function croaks for profile_update without sufficient values.';

# my $content_config = $nakamura->content_config;
# ok( defined $content_config );
# throws_ok { $nakamura->content_run } qr/No content config supplied!/, 'Check content_run function croaks without config';
# ok( $nakamura->content_run( $content_config ) );

my $world_config = $nakamura->world_config;
ok( defined $world_config );
throws_ok { $nakamura->world_run } qr/No world config supplied!/, 'Check world_run function croaks without config';
ok( $nakamura->world_run( $world_config ) );
my $world = "nakamura_test_world_$$";
$world_config->{'add'} = \$world;
ok( $nakamura->world_run( $world_config ) );
