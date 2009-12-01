package Form::Sensible::Reflector::DBIC::HasPostgres;
use Moose::Role;
use Regexp::Common;

sub get_types {
	my ($self) = shift;
	
	## this is going to be ugly
	##  type          [class, constraints(optional)]
	return {
		
		'bool'      => ['Toggle'],
		'bigint'    => ['Text', '1024'], # bogus size, fix when i look it up
		'date'      => ['Date', 'ymd'],
		'float8'    => ['Number', { lower_bound => '-100', upper_bound => '100' }],
		'integer'   => ['Number', { lower_bound => '0',    upper_bound => '100' }],
		'macaddr'   => ['Text',   { regex => $RE{'mac'} }], # once again, bogus until i look it up
		'money'     => ['Text',   { regex => $RE{'currency'}{'usd'}   }],
		'numeric'   => ['Number', { regex => $RE{'number'}{'decimal'} }],
		'real'      => ['Number', { regex => $RE{'number'}{'decimal'} }],
		'smallint'  => ['Number', { regex => ''                       }],
		'text'      => ['Text',   { max_length => '4096'              }],
		'timestamp' => ['Date', 'ymdhs'],
		'uuid'      => ['Text',   { regex => $RE{'uuid'}              }],
		'enum'      => ['Select', undef],
		
	}
}