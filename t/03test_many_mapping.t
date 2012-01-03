use strict;
use warnings;

use Test::More;
use Test::Deep;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "t/lib";

use Form::Sensible;
use Form::Sensible::Reflector::DBIC;
use TestSchema;

my $schema = TestSchema->connect('dbi:SQLite::memory:');
$schema->deploy;

for (qw/Russia USA Germany Panama France/) {
    $schema->resultset("Country")->create({
        country => $_
    });
}

my $reflector = Form::Sensible::Reflector::DBIC->new();
my $form      = $reflector->reflect_from(
    $schema->resultset("Test"),
    {
        form   => { name => 'test' },
    }
);

my $expected_options = [
    {
        'value' => 1,
        'name' => 'Russia'
    },
    {
        'value' => 2,
        'name' => 'USA'
    },
    {
        'value' => 3,
        'name' => 'Germany'
    },
    {
        'value' => 4,
        'name' => 'Panama'
    },
    {
        'value' => 5,
        'name' => 'France'
    }
];

cmp_deeply( $form->fields->{country_id}->{options}, bag(@$expected_options), 'Expecting 5 countries as Select options' );

done_testing;
