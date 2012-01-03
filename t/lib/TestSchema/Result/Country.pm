package TestSchema::Result::Country;
use base qw/DBIx::Class/;
use DateTime;

__PACKAGE__->load_components(qw/ Core  /);
__PACKAGE__->table('country');
__PACKAGE__->add_columns(
    'id',
    {
        data_type   => 'int',
    },
    'country',
    {
        data_type   => 'varchar',
        size        => '40',
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(users => 'TestSchema::Result::Test', 'country_id');

1;
