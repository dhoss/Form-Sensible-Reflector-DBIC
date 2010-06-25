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
                validation  => {
                    regex => qr/^(.+){3,}$/
                }, 
            },
            {
                field_class => 'FileSelector',
                name        => 'file_upload',
                validation  => {}, # wtf do we validate here?
            },
            {
                field_class => 'Text',
                name        => 'date',
                default_form_value => $dt,
                validation  => {
                    regex => qr/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/,
                }, 
            },
            {
                field_class => 'LongText',
                name        => 'big_text',
                validation  => {
                    regex => qr/^(.+){3,}$/
                }, 
            },
            {
                field_class => 'Number',
                name        => 'number',
                integer_only => 1,
                validation  => {
                    regex => qr/^[0-9]+$/,    
                }, 
            },
            {
                field_class => 'Number',
                name        => 'decimal',
                validation  => {
                    regex => qr/^[0-9]\.[0-9]+$/,
                }, 

            },
            {
                field_class => 'Number',
                name        => 'big_number',
                integer_only => 1,
                validation  => {
                    regex =>  qr/^[0-9]+$/,    
                }, 
            },

            {
                field_class  => 'Text',
                name         => 'password',
                render_hints => { field_type => 'password' },
                validation  => {
                    regex => qr/^(?=.+\d)(?=.+[a-z])(?=.+[A-Z]).{8,}$/    
                }, 
            },
            {
                field_class => 'Trigger',
                name        => 'submit',
            }
        ],
    }
);

my $renderer2 = Form::Sensible->get_renderer('HTML');
my $output_2  = $renderer2->render($form2)->complete;
warn "hand made: " . Dumper $form2;
is_deeply( $form->flatten, $form2->flatten, "form one hash matches form two hash" );
cmp_ok( $output, 'eq', $output_2, "Flat eq to pulled from DBIC" );

done_testing;
