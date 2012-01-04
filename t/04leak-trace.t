use strict;
use warnings;
use Test::More;
use Test::Weaken qw( leaks );
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "t/lib";
use DateTime;
use TestSchema;
my $lib_dir = $FindBin::Bin;
my @dirs = split '/', $lib_dir;
pop @dirs;
$lib_dir = join( '/', @dirs );
chomp $lib_dir;
use Form::Sensible;
use Form::Sensible::Reflector::DBIC;
use Data::Dumper;

my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;

## start out basic
my $test = sub {
  my $reflector = Form::Sensible::Reflector::DBIC->new();
  my $form      = $reflector->reflect_from( $schema->resultset("Test"),
  { form => { name => 'test' }, with_trigger => 1 } );
  my $renderer = Form::Sensible->get_renderer('HTML');
};

ok !leaks( $test ), "no leaks found in insantiation";
done_testing();
