use Test::More tests => 7;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'Integer', 'foo' );

# Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => 23 };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="23" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'yada' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /></span><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}

# Multiple Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => [ 123, 321, 111 ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( $f->valid('foo'), 1, "Valid" );
    my @results = $f->param('foo');
    is( $results[0], 123, "Multiple valid values" );
    is( $results[2], 111, "Multiple valid values" );
}

# Multiple Invalid
{
    my $query = Test::MockObject->new;
    my $data = { foo => [ 123, 'foo', 321 ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( $f->valid('foo'), 0, "Invalid" );
}
