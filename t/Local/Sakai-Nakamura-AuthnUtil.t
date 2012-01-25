# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Apache-Sling.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 3;
BEGIN { use_ok( 'Sakai::Nakamura::AuthnUtil' ); }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
ok( Sakai::Nakamura::AuthnUtil::form_login_setup( 'http://localhost:8080', 'admin', 'admin') eq
  q(post http://localhost:8080/system/sling/formlogin $post_variables = ['sakaiauth:un','admin','sakaiauth:pw','admin','sakaiauth:login','1']),
  'Check form_login_setup function' );

ok( Sakai::Nakamura::AuthnUtil::form_logout_setup( 'http://localhost:8080' ) eq
  q(post http://localhost:8080/system/sling/formlogin $post_variables = ['sakaiauth:logout','1']), 'Check form_logout_setup function' );

