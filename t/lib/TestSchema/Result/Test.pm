package TestSchema::Result::Test;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ Core  /);
__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    'username',
    {
        data_type   => 'varchar',
        size        => '40',
        is_nullable => 0,

    },
    'password',
    {
        data_type   => 'varchar',
        size        => '40',
        is_nullable => 0,
    },
);

1;
