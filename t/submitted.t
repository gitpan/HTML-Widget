use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Select', 'foo' )->label('Foo')
  ->options( foo => 'Foo', bar => 'Bar' );

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process();
print "Submitted: ", $f->submitted, "\n";
    is($f->submitted, 0, 'Form was not submitted');
}
# With mocked basic query
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'foo', bar => [ 'yada', 23 ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is($f->submitted, 1, 'Form was submitted');
}
