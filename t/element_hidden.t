use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Hidden', 'foo' )->value('foo');
$w->element( 'Hidden', 'bar' );

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="hidden" id="widget_foo" name="foo" type="hidden" value="foo" /><input class="hidden" id="widget_bar" name="bar" type="hidden" value="1" /></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'yada', bar => '23' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="hidden" id="widget_foo" name="foo" type="hidden" value="yada" /><input class="hidden" id="widget_bar" name="bar" type="hidden" value="23" /></fieldset></form>
EOF
}
