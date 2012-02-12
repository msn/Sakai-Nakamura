#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 8;

my $sling_host = 'http://localhost:8080';
my $super_user = 'admin';
my $super_pass = 'admin';
my $verbose    = 0;
my $log;

use File::Temp;
BEGIN { use_ok( 'Sakai::Nakamura' ); }
BEGIN { use_ok( 'Sakai::Nakamura::Authn' ); }
BEGIN { use_ok( 'Sakai::Nakamura::Content' ); }

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
# content object:
my $content = Sakai::Nakamura::Content->new( \$authn, $verbose, $log );
isa_ok $content, 'Sakai::Nakamura::Content', 'content';

# Run tests:
ok( defined $content,
    "Content Test: Sling Content Object successfully created." );

my ( $tmp_content_handle, $tmp_content_name ) = File::Temp::tempfile();
print {$tmp_content_handle} "Test file\n";
ok( $content->upload_file($tmp_content_name), 'Check upload_file function' );
unlink($tmp_content_name);
