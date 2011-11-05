package TestSchema::Result::TextPK;
use base qw/DBIx::Class/;
use DateTime;

__PACKAGE__->load_components(qw/ Core  /);
__PACKAGE__->table('text_pk');
__PACKAGE__->add_columns(
    'pk',
    {
        data_type         => 'varchar',
        size              => 20,
        is_primary_key    => 1,
    },
);
__PACKAGE__->set_primary_key('pk');

1;
