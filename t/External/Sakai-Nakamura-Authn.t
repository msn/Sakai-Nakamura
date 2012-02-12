#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 34;
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

# Set password to something that won't work to start with:
$authn->{'Username'}    = $super_user;
$authn->{'Password'}    = '__bad__password__';

# Test basic login fail:
throws_ok { $authn->login_user() } qr{Basic Auth log in for user "admin" at URL "http://localhost:8080" was unsuccessful}, 'Check login_user function (basic) croaks with invalid password';
$authn->{'Verbose'} = '1';
throws_ok { $authn->login_user() } qr{Basic Auth log in for user "admin" at URL "http://localhost:8080" was unsuccessful}, 'Check login_user function (basic) croaks with invalid password';

# Test form login fail:
$authn->{'Type'} = 'form';
throws_ok { $authn->login_user() } qr{Form Auth log in for user "admin" at URL "http://localhost:8080" was unsuccessful}, 'Check login_user function (form) croaks with invalid password';
$authn->{'Verbose'} = '0';
throws_ok { $authn->login_user() } qr{Form Auth log in for user "admin" at URL "http://localhost:8080" was unsuccessful}, 'Check login_user function (form) croaks with invalid password';

# Test unsupported login type:
$authn->{'Type'} = '__bad__type__';
throws_ok { $authn->login_user() } qr{Unsupported auth type: "__bad__type__"}, 'Check login_user function croaks with invalid login type';

$authn->{'Password'} = undef;
$authn->{'Type'} = 'basic';

# Check no login is attempted with base url undefined:
$authn->{'BaseURL'} = undef;
ok( $authn->login_user(), 'Check login_user function skips successfully with undefined base url' );
$authn->{'BaseURL'} = $sling_host;

# Check no login is attempted with password undefined:
ok( $authn->login_user(), 'Check login_user function skips successfully with undefined password' );
$authn->{'Password'}= $super_pass;

$authn->{'BaseURL'} = undef;
ok( $authn->login_user(), 'Check login_user function skips successfully with undefined base url' );
$authn->{'BaseURL'} = $sling_host;


$authn->{'Verbose'} = '2';
ok( $authn->form_login(), 'Check form_login function works successfully' );

$authn->{'Verbose'} = '0';
ok( $user->add( $test_user, $test_pass ),
    "User Test: User \"$test_user\" added successfully." );
ok( $user->check_exists( $test_user ),
    "User Test: User \"$test_user\" exists." );

$authn->{'Verbose'} = '1';
ok( $authn->form_logout(), 'Check form_logout function works successfully' );

$authn->{'Verbose'} = '2';
$authn->{'Type'} = 'form';
ok( $authn->login_user(), 'Check login_user function with form auth, verbose > 1 works successfully' );
ok( $authn->form_logout(), 'Check form_logout function works successfully' );

$authn->{'Verbose'} = '0';
$authn->{'Type'} = 'form';
ok( $authn->login_user(), 'Check login_user function with form auth works successfully' );
ok( $authn->form_logout(), 'Check form_logout function works successfully' );

$authn->{'Verbose'} = '2';
throws_ok { $authn->switch_user() } qr{New username to switch to not defined}, 'Check switch_user croaks without username';
throws_ok { $authn->switch_user($super_user) } qr{New password to use in switch not defined}, 'Check switch_user croaks without password';
ok( $authn->switch_user($super_user, $super_pass), 'Check switch_user function to same user works successfully' );
ok( $authn->switch_user($test_user, $test_pass,'form'), 'Check switch_user function to test user works successfully' );
ok( $authn->switch_user($super_user, $super_pass,'form'), 'Check switch_user function to super user works successfully' );
ok( $authn->form_logout(), 'Check form_logout function works successfully' );
ok( $authn->switch_user($test_user, $test_pass,'basic',1), 'Check switch_user function to test user with basic and check basic works successfully' );
$authn->{'Username'} = $super_user;
ok( $authn->switch_user($super_user, $super_pass,'basic',1), 'Check switch_user function to super user with basic and check basic works successfully' );
throws_ok { $authn->switch_user($test_user, $test_pass, '__bad__auth__type__') } qr{Unsupported auth type: "__bad__auth__type__"}, 'Check switch_user croaks with bad auth type';

$authn->{'Verbose'} = '0';
$authn->{'Type'} = 'basic';
ok( $authn->login_user(), 'Check login_user function with basic auth works successfully' );

# Check user deletion:
$authn->{'Verbose'} = '2';
ok( $user->del( $test_user ),
    "User Test: User \"$test_user\" deleted successfully." );
ok( ! $user->check_exists( $test_user ),
    "User Test: User \"$test_user\" should no longer exist." );

# throws_ok { $content->upload_from_file() } qr/Problem opening file: ''/, 'Check upload_from_file function croaks without file specified';
# ok( $content->upload_from_file('/dev/null'), 'Check upload_from_file function with blank file' );
