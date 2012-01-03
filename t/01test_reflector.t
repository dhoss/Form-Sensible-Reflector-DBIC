use strict;
use warnings;
use Test::More;
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

# Try to use Test::Differences if possible
BEGIN {
  if ( !eval q{ use Test::Differences; unified_diff; 1 } ) {
    *eq_or_diff = \&is_deeply;
  }
}
my $dt = DateTime->now;

my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;

for (qw/Russia USA Germany Panama France/) {
    $schema->resultset("Country")->create({
        country => $_
    });
}

# reflector WITH a submit button;
my $reflector = Form::Sensible::Reflector::DBIC->new();
my $form      = $reflector->reflect_from( $schema->resultset("Test"),
  { form => { name => 'test' }, with_trigger => 1 } );
my $renderer = Form::Sensible->get_renderer('HTML');

my $form2 = Form::Sensible->create_form(
  {
    name   => 'test',
    fields => [
      {
        name         => 'id',
        field_class  => 'Number',
        integer_only => 1,
        render_hints => { 'field_type' => 'hidden' },
        validation   => { required => 1, },
      },
      {
        field_class => 'Text',
        name        => 'username',
        validation  => {
          regex    => qr/^(.+){3,}$/,
          required => 1,
        },
      },
      {
        field_class => 'FileSelector',
        name        => 'file_upload',
        validation  => { required => 1, },    # wtf do we validate here?
      },
      {
        field_class        => 'Text',
        name               => 'date',
        default_form_value => $dt,
        validation         => {
          regex    => qr/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/,
          required => 1,
        },
      },
      {
        field_class => 'LongText',
        name        => 'big_text',
        validation  => {
          regex    => qr/^(.+){3,}$/,
          required => 1,
        },
      },
      {
        field_class  => 'Number',
        name         => 'number',
        integer_only => 1,
        validation   => {
          regex    => qr/^[0-9]+$/,
          required => 1,
        },
      },
      {
        field_class => 'Number',
        name        => 'decimal',
        validation  => {
          regex    => qr/^(\d.+)\.(\d.+)$/,
          required => 1,
        },

      },
      {
        field_class  => 'Number',
        name         => 'big_number',
        integer_only => 1,
        validation   => {
          regex    => qr/^[0-9]+$/,
          required => 1,
        },
      },
      {
        field_class => 'Text',
        name        => 'password',
        validation  => {
          regex    => qr/^(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*$/,
          required => 1,
        },
      },
      {
        field_class => 'Select',
        name        => 'country_id',
        options     => [
          {
            'value' => 1,
            'name'  => 'Russia'
          },
          {
            'value' => 2,
            'name'  => 'USA'
          },
          {
            'value' => 3,
            'name'  => 'Germany'
          },
          {
            'value' => 4,
            'name'  => 'Panama'
          },
          {
            'value' => 5,
            'name'  => 'France'
          }
        ],
      },
      {
        field_class => 'Trigger',
        name        => 'submit',
      },
    ],
  }
);

my $good_values = {
  username    => "dhoss",
  file_upload => 'these are the contents of a file',
  date        => "2008-09-01 12:35:45",
  big_text    => "asdflkjawofij24fj2i3f4j 2903 dfnqe2fw f",
  number      => 123,
  decimal     => 12.34,
  big_number  => 1243567,
  password    => "mMMmm123",
  country_id  => 1
};

my $bad_values = {
  username   => "1",
  date       => "Today",
  big_text   => "1",
  number     => "three",
  decimal    => 1,
  big_number => 2,
  password   => "a",
};

my $row = $schema->resultset('Test')->create($good_values);
isa_ok( $row, 'TestSchema::Result::Test' );

my $form_from_row =
  $reflector->reflect_from( $row,
  { form => { name => 'test' }, with_trigger => 1 } );

$form->set_values($good_values);
$form2->set_values($good_values);
$form_from_row->set_values($good_values);
my $v1 = $form->validate;
my $v2 = $form2->validate;
my $v3 = $form_from_row->validate;
TODO: {
  local $TODO = "These need fixing";
  ok( $v1->is_valid, "form 1 valid" );
  ok( $v2->is_valid, "form 2 valid" );
  ok( $v3->is_valid, "form from row is valid" );
  $form->set_values($bad_values);
  $form2->set_values($bad_values);
  $form_from_row->set_values($bad_values);
  my $bv1 = $form->validate;
  my $bv2 = $form2->validate;
  my $bv3 = $form_from_row->validate;

  ok( !$bv1->is_valid, "form 1 invalid" );
  ok( !$bv2->is_valid, "form 2 invalid" );
  ok( !$bv3->is_valid, "form from row invalid" );
  $form->set_values($good_values);
  $form2->set_values($good_values);
  $form_from_row->set_values($good_values);
}
my $renderer2 = Form::Sensible->get_renderer('HTML');
my $output    = $renderer->render($form)->complete;
my $output_2  = $renderer2->render($form2)->complete;
my $output_3  = $renderer2->render($form_from_row)->complete;
is_deeply( $form->flatten, $form2->flatten,
  "form one hash matches form two hash" );
is_deeply( $form_from_row->flatten, $form->flatten,
  "flattened form from row matches flattened original form" );

eq_or_diff( $output, $output_2, "Output from flat eq to pulled from DBIC" );
eq_or_diff( $output_2, $output_3,
  "Output from flat eq to output from form from row" );

done_testing;
