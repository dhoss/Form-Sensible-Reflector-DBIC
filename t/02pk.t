use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "t/lib";
use TestSchema;
my $lib_dir = $FindBin::Bin;
my @dirs = split '/', $lib_dir;
pop @dirs;
$lib_dir = join( '/', @dirs );
chomp $lib_dir;
my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;
use Form::Sensible;
use Form::Sensible::Reflector::DBIC;

my $reflector = Form::Sensible::Reflector::DBIC->new();
my $form      = $reflector->reflect_from( $schema->resultset("TextPK"),
  { form => { name => 'pk' } } );

my $form2     = $reflector->reflect_from( $schema->resultset("Test"),
  { form => { name => 'test' } } );

isnt($form->field('pk')->{render_hints}->{field_type}, 'hidden', 'Text pk is not hidden');
is($form2->field('id')->{render_hints}->{field_type}, 'hidden', 'auto_increment pk is hidden');

done_testing;
