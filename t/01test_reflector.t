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
my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;
use Form::Sensible;
use Form::Sensible::Reflector::DBIC;
use Data::Dumper;
my $dt        = DateTime->now;
my $reflector = Form::Sensible::Reflector::DBIC->new;
my $form      = $reflector->reflect_from( $schema->resultset("Test"),
    { form => { name => 'test' } } );
my $submit_button = Form::Sensible::Field::Trigger->new( name => 'submit' );
my $renderer = Form::Sensible->get_renderer('HTML');

$form->add_field($submit_button);
my $output = $renderer->render($form)->complete;
warn "reflector form: " . Dumper $form;
my $form2 = Form::Sensible->create_form(
    {
        name   => 'test',
        fields => [
            {
                field_class => 'Text',
                name        => 'username',
            },
            {
                field_class => 'FileSelector',
                name        => 'file_upload',
            },
            {
                field_class => 'Text',
                name        => 'date',
                default_form_value => $dt
            },
            {
                field_class => 'LongText',
                name        => 'big_text',
            },
            {
                field_class => 'Number',
                name        => 'number',
            },
            {
                field_class => 'Number',
                name        => 'decimal',
            },
            {
                field_class => 'Number',
                name        => 'big_number',
            },

            {
                field_class  => 'Text',
                name         => 'password',
                render_hints => { field_type => 'password' },
            },
            {
                field_class => 'Trigger',
                name        => 'submit'
            }
        ],
    }
);

warn "hand made form: " . Dumper $form2;
my $renderer2 = Form::Sensible->get_renderer('HTML');
my $output_2  = $renderer2->render($form2)->complete;
is_deeply( $form, $form2, "form one hash matches form two hash" );
cmp_ok( $output, 'eq', $output_2, "Flat eq to pulled from DBIC" );

done_testing;
