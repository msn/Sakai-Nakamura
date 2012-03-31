#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Exception;
use Test::More tests => 11;

my $sling_host = 'http://localhost:8080';
my $super_user = 'admin';
my $super_pass = 'admin';
my $verbose    = 0;
my $log;

BEGIN { use_ok( 'Sakai::Nakamura' ); }
BEGIN { use_ok( 'Sakai::Nakamura::Authn' ); }
BEGIN { use_ok( 'Sakai::Nakamura::World' ); }

# test user name:
my $test_world = "world_test_world_$$";

# sling object:
my $sling = Sakai::Nakamura->new();
isa_ok $sling, 'Sakai::Nakamura', 'sling';
$sling->{'URL'}     = $sling_host;
$sling->{'User'}    = $super_user;
$sling->{'Pass'}    = $super_pass;
$sling->{'Verbose'} = $verbose;
$sling->{'Log'}     = $log;
# authn object:
my $authn = Sakai::Nakamura::Authn->new( \$sling );
isa_ok $authn, 'Sakai::Nakamura::Authn', 'authentication';
ok( $authn->login_user(), "Log in successful" );
# world object:
my $world = Sakai::Nakamura::World->new( \$authn, $verbose, $log );
isa_ok $world, 'Sakai::Nakamura::World', 'world';

ok( defined $world,
    "World Test: Sling World Object successfully created." );

# add world:
ok( $world->add( $test_world ),
    "World Test: World \"$test_world\" added successfully." );

my $upload = "id\nworld_test2_world_$$";
ok( $world->add_from_file(\$upload,0,1), 'Check add_from_file function' );
$upload = "id\nworld_test3_world_$$\nworld_test4_world_$$\nworld_test5_world_$$";
ok( $world->add_from_file(\$upload,0,3), 'Check add_from_file function with three forks' );

# TODO: Test why creation is fine with a non-existent template.
# ok( $world->add( $test_world, 'title', 'description', 'tags', 'public', 'yes', '__bad__world__template__' ),
  #  "World Test: World \"$test_world\" added successfully." );
