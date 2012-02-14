#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Exception;
use Test::More tests => 23;

my $sling_host = 'http://localhost:8080';
my $super_user = 'admin';
my $super_pass = 'admin';
my $verbose    = 0;
my $log;

BEGIN { use_ok( 'Sakai::Nakamura' ); }
BEGIN { use_ok( 'Sakai::Nakamura::Authn' ); }
BEGIN { use_ok( 'Sakai::Nakamura::Group' ); }
BEGIN { use_ok( 'Sakai::Nakamura::User' ); }

# test user name:
my $test_user = "user_test_user_$$";
# test user pass:
my $test_pass = "pass";
# test group name:
my $test_group = "g-user_test_group_$$";

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
# group object:
my $group = Sakai::Nakamura::Group->new( \$authn, $verbose, $log );
isa_ok $group, 'Sakai::Nakamura::Group', 'group';
# user object:
my $user = Sakai::Nakamura::User->new( \$authn, $verbose, $log );
isa_ok $user, 'Sakai::Nakamura::User', 'user';

ok( defined $group,
    "Group Test: Sling Group Object successfully created." );
ok( defined $user,
    "Group Test: Sling User Object successfully created." );

# add user:
ok( $user->add( $test_user, $test_pass ),
    "Group Test: User \"$test_user\" added successfully." );

# Check can update properties after addition of user to group:
# http://jira.sakaiproject.org/browse/KERN-270
# create group:
ok( $group->add( $test_group ),
    "Group Test: Group \"$test_group\" added successfully." );
ok( $group->check_exists( $test_group ),
    "Group Test: Group \"$test_group\" exists." );

ok( $group->role_member_add_from_file(),
    "Test role_member_add_from_file function completes successfully." );
ok( $group->role_member_delete(),
    "Test role_member_delete function completes successfully." );
ok( $group->role_member_exists(),
    "Test role_member_exists function completes successfully." );
ok( $group->role_member_view(),
    "Test role_member_view function completes successfully." );

throws_ok { $group->role_member_add() } qr{No group name defined to add to!}, 'Check role_member_add function croaks with no values specified';
ok( $group->role_member_add( $test_group, 'manager', $test_user ),
    "Test role_member_add function completes successfully." );
# TODO: investigate why this returns success status:
ok( $group->role_member_add( '__bad__group__', '__bad__role__', '__bad__user__' ),
    "Test role_member_add function with non-existent group and role." );

# Cleanup Group:
ok( $group->del( $test_group ),
    "Group Test: Group \"$test_group\" deleted successfully." );
ok( ! $group->check_exists( $test_group ),
    "Group Test: Group \"$test_group\" should no longer exist." );

# Check user deletion:
ok( $user->del( $test_user ),
    "Group Test: User \"$test_user\" deleted successfully." );
