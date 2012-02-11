#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 16;
use Test::Exception;

my $sling_host = 'http://localhost:8080';
my $super_user = 'admin';
my $super_pass = 'admin';
my $verbose    = 0;
my $log;

BEGIN { use_ok( 'Sakai::Nakamura' ); }
BEGIN { use_ok( 'Sakai::Nakamura::Authn' ); }
BEGIN { use_ok( 'Sakai::Nakamura::User' ); }

# test user name and pass:
my $test_user = "user_test_user_$$";
my $test_pass = "pass";

# sling object:
my $sling = Sakai::Nakamura->new();
isa_ok $sling, 'Sakai::Nakamura', 'sling';
$sling->{'URL'}     = $sling_host;
$sling->{'Verbose'} = $verbose;
$sling->{'Log'}     = $log;
# authn object:
my $authn = Sakai::Nakamura::Authn->new( \$sling );
isa_ok $authn, 'Sakai::Nakamura::Authn', 'authentication';
# user object:
my $user = Sakai::Nakamura::User->new( \$authn, $verbose, $log );
isa_ok $user, 'Sakai::Nakamura::User', 'user';

$authn->{'Username'}    = $super_user;
$authn->{'Password'}    = $super_pass;

ok( $authn->form_login(), 'Check form_login function works successfully' );

ok( $user->add( $test_user, $test_pass ),
    "User Test: User \"$test_user\" added successfully." );
ok( $user->check_exists( $test_user ),
    "User Test: User \"$test_user\" exists." );

ok( $authn->form_logout(), 'Check form_logout function works successfully' );

$authn->{'Type'} = 'form';
ok( $authn->login_user(), 'Check login_user function with form auth works successfully' );
ok( $authn->form_logout(), 'Check form_logout function works successfully' );

$authn->{'Type'} = 'basic';
ok( $authn->login_user(), 'Check login_user function with basic auth works successfully' );

ok( $authn->switch_user($super_user, $super_pass), 'Check switch_user function to same user works successfully' );

# Check user deletion:
ok( $user->del( $test_user ),
    "User Test: User \"$test_user\" deleted successfully." );
ok( ! $user->check_exists( $test_user ),
    "User Test: User \"$test_user\" should no longer exist." );

# throws_ok { $content->upload_from_file() } qr/Problem opening file: ''/, 'Check upload_from_file function croaks without file specified';
# ok( $content->upload_from_file('/dev/null'), 'Check upload_from_file function with blank file' );
