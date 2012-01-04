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
use English qw( -no_match_vars );

my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;

## start out basic
my $instantiation = sub {
  my $reflector = Form::Sensible::Reflector::DBIC->new();
  my $form      = $reflector->reflect_from( $schema->resultset("Test"),
  { form => { name => 'test' }, with_trigger => 1 } );
  my $renderer = Form::Sensible->get_renderer('HTML');
  [ $reflector, $form, $renderer, $renderer->render($form)->complete ]
};

my $create_a_bunch = sub {
 
  my @things;
  my ( $reflector, $form, $renderer );
  for ( 0..100 ) {
   
   $reflector = Form::Sensible::Reflector::DBIC->new();
   $form      = $reflector->reflect_from( $schema->resultset("Test"),
    { form => { name => 'test' }, with_trigger => 1 } );
   $renderer = Form::Sensible->get_renderer('HTML');
   push @things, [ $reflector, $form, $renderer, $renderer->render($form)->complete ];
   
  }

  return \@things;
};

my $mangle_things = sub {

   my ( $reflector, $form, $renderer );

   $reflector = Form::Sensible::Reflector::DBIC->new();
   $form      = $reflector->reflect_from( $schema->resultset("Test"),
    { form => { name => 'test' }, with_trigger => 1 } );
   $renderer = Form::Sensible->get_renderer('HTML');
   my $rendered1 = $renderer->render($form)->complete;
   $form->name('derp');
   my $rendered2 = $renderer->render($form)->complete;
   return [ $reflector, $form, $renderer, $rendered1, $rendered2 ];
   
};



ok !( my $inst_leaks = leaks( $instantiation ) ), "no leaks found in insantiation";
if ( $inst_leaks) {
  display_leaks($inst_leaks, 'instantiation');
}
  
ok !( my $create_leaks = leaks( $create_a_bunch ) ), "no leaks found in creating a bunch of objects";
if ( $create_leaks ) {
  display_leaks($create_leaks, 'create');
}
ok !( my $mangle_leaks = leaks( $mangle_things )), "no leaks when screwing with form name";
if ( $mangle_leaks ) {
  display_leaks($mangle_leaks, "mangle");
}

sub display_leaks {
  my ($tester, $name) = @_;
  print "RESULTS FROM $name\n";
   my $unfreed_proberefs = $tester->unfreed_proberefs();
    my $unfreed_count     = @{$unfreed_proberefs};
    printf "Test 2: %d of %d original references were not freed\n",
        $tester->unfreed_count(), $tester->probe_count()
        or Carp::croak("Cannot print to STDOUT: $ERRNO");
    print "These are the probe references to the unfreed objects:\n"
        or Carp::croak("Cannot print to STDOUT: $ERRNO");
    for my $ix ( 0 .. $#{$unfreed_proberefs} ) {
        print Data::Dumper->Dump( [ $unfreed_proberefs->[$ix] ],
            ["unfreed_$ix"] )
            or Carp::croak("Cannot print to STDOUT: $ERRNO");
    }
  }
done_testing();
