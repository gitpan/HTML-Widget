use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );
$w->element( 'Textfield', 'bar' );

$w->constraint( 'Any', 'foo', 'bar' );

# Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'yada' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_bar" name="bar" type="text" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = Test::MockObject->new;
    my $data = { baz => 23 };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" /></span><span class="error_messages" id="widget_foo_errors"><span class="any_errors" id="widget_foo_error_any">Alternative Missing</span></span><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" /></span><span class="error_messages" id="widget_bar_errors"><span class="any_errors" id="widget_bar_error_any">Alternative Missing</span></span></fieldset></form>
EOF
}
