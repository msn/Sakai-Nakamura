# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Apache-Sling.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 2;
BEGIN { use_ok( 'Sakai::Nakamura::GroupUtil' ); }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
my @properties = '';
ok( Sakai::Nakamura::GroupUtil::role_member_add_setup( 'http://localhost:8080', 'group', 'role', 'member' ) eq
  "post http://localhost:8080/system/userManager/group/group-role.update.json \$post_variables = [':member','member',':viewer','member']", 'Check role_member_add_setup function' );
