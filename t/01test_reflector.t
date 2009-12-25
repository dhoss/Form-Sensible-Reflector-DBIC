use Test::More;
use FindBin;
use lib "/Users/dhoss/web-devel/FormSensible/lib";
use lib "$FindBin::Bin/../lib";
use lib "t/lib";
use TestSchema;
my $lib_dir = $FindBin::Bin;
my @dirs = split '/', $lib_dir;
pop @dirs;
$lib_dir = join( '/', @dirs );

my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;
use Form::Sensible::Form::Reflector::DBIC;
use Form::Sensible;
use Form::Sensible::Form;
## name must reflect the table which we are reflecting
my $form  = Form::Sensible::Form::Reflector::DBIC->new(
    name   => 'test',
	schema => $schema
);


my $renderer = Form::Sensible->get_renderer(
    'HTML',
    {
        tt_config => {
            INCLUDE_PATH => [
                $lib_dir
                  . '/share/templates
'
            ]
        }
    }
);

my $output = $renderer->render($form->create_form)->complete;

my $form = Form::Sensible->create_form(
    {
        name   => 'test',
        fields => [
            {
                field_class => 'Text',
                name        => 'username',
                validation  => { regex => '^[0-9a-z]*$' }
            },
            {
                field_class  => 'Text',
                name         => 'password',
                render_hints => { field_type => 'password' }
            },
            {
                field_class => 'Trigger',
                name        => 'submit'
            }
        ],
    }
);

my $renderer2 = Form::Sensible->get_renderer(
    'HTML',
    {
        tt_config => {
            INCLUDE_PATH => [
                $lib_dir
                  . '/share/template
s'
            ]
        }
    }
);
my $output_2 = $renderer2->render($form)->complete;

ok( $output eq $output_2,
    "flat creation and programmatic creation produce the same results" );
done_testing();
