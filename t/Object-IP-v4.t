# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl MooseX-Objects-IPv4.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 10;
use Test::Exception;


BEGIN { use_ok( 'Object::IP::v4' ); }
require_ok( 'Object::IP::v4' );

use Object::IP::v4;

my $local = new Object::IP::v4(ip => "127.0.0.1", netmask => "8");
my $classd = new Object::IP::v4(ip => "224.0.0.18", netmask => "4");
my $classe = new Object::IP::v4(ip => "240.0.0.18", netmask => "4");
my $llocal = new Object::IP::v4(ip => "169.254.8.8", netmask => "16");
my $r3330 = new Object::IP::v4(ip => "128.0.0.16", netmask => "16");
my $r1918 = new Object::IP::v4(ip => "192.168.99.33", netmask => "24");
my $r2544 = new Object::IP::v4(ip => "198.18.24.24", netmask => "15");
my $tnet = new Object::IP::v4(ip => "192.0.2.254", netmask => "24");


ok ( $local->is_localhost() == 1, 'is_localhost()' );
ok ( $classd->is_class_d() == 1, 'is_class_d()' );
ok ( $classe->is_class_e() == 1, 'is_class_e()' );
ok ( $llocal->is_linklocal() == 1, 'is_linklocal' );
ok ( $r3330->is_reserved() == 1, 'is_reserved()' );
ok ( $r1918->is_rfc1918() == 1, 'is_rfc1918()' );
ok ( $r2544->is_rfc2544() == 1, 'is_rfc2544()' );
ok ( $tnet->is_testnet() == 1, 'is_testnet()' );



#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
