use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Select', 'foo' )->label('Foo')
  ->options( foo => 'Foo', bar => 'Bar' )->selected(qw/foo bar/);
$w->element( 'Select', 'bar' )->options( 23 => 'Baz', yada => 'Yada' )
  ->selected('yada');

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label for="widget_foo" id="widget_foo_label">Foo<select class="select" id="widget_foo" name="foo"><option selected="selected" value="bar">Bar</option><option selected="selected" value="foo">Foo</option></select></label><select class="select" id="widget_bar" name="bar"><option value="23">Baz</option><option selected="selected" value="yada">Yada</option></select></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'foo', bar => [ 'yada', 23 ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label class="labels_with_errors" for="widget_foo" id="widget_foo_label">Foo<select class="select" id="widget_foo" name="foo"><option value="bar">Bar</option><option selected="selected" value="foo">Foo</option></select></label><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span><select class="select" id="widget_bar" name="bar"><option selected="selected" value="23">Baz</option><option selected="selected" value="yada">Yada</option></select><span class="error_messages" id="widget_bar_errors"><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}
