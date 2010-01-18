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
print $lib_dir . "\n";
my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;
use Form::Sensible;
use Form::Sensible::Form::Reflector::DBIC;
## name must reflect the table which we are reflecting

my $form = Form::Sensible::Form::Reflector::DBIC->create_form({
    name      => 'test',
    options   => { schema => $schema }
});

my $submit_button = Form::Sensible::Field::Trigger->new( name => 'submit' );
my $renderer =
  Form::Sensible->get_renderer( 'HTML',
    { tt_config => { INCLUDE_PATH => [ $lib_dir . '/share/templates' ] } } );

my $output = $renderer->render( $form )->complete;
use Data::Dumper;
warn "Form: " . Dumper $form; 
my $form2 = Form::Sensible->create_form(
    {
        name   => 'test',
        fields => [
            {
                field_class => 'Text',
                name        => 'username',
            },
            {
                field_class  => 'Text',
                name         => 'password',
                render_hints => { field_type => 'password' },
            },
            {
                field_class => 'FileSelector',
                name        => 'file_upload',
            },
            {
                field_class => 'Text',
                name        => 'date',
            },
            {
                field_class => 'Number',
                name        => 'number',
            },
            {
                field_class => 'Number',
                name        => 'big_number',
            },
            {
                field_class => 'LongText',
                name        => 'big_text',
            },

            {
                field_class => 'Trigger',
                name        => 'Submit'
            }
        ],
    }
);
$form2->set_values( { date => DateTime->now } );
my $renderer2 =
  Form::Sensible->get_renderer( 'HTML',
    { tt_config => { INCLUDE_PATH => [ $lib_dir . '/share/templates' ] } } );
my $output_2 = $renderer2->render($form2)->complete;

ok( $output eq $output_2, "Flat eq to pulled from DBIC" );

done_testing;
