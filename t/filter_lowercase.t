use Test::More tests => 4;

use Test::MockObject;

use_ok("HTML::Widget");

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' )->value('foo')->size(30)->label('Foo');
$w->element( 'Textfield', 'bar' );

$w->constraint( 'ASCII', 'foo' );
$w->constraint( 'Integer', 'bar' );

$w->filter( 'LowerCase', 'foo' );

# With mocked basic query
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'Foo', bar => 'Bar' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label for="widget_foo" id="widget_foo_label">Foo<input class="textfield" id="widget_foo" name="foo" size="30" type="text" value="foo" /></label><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" value="Bar" /></span><span class="error_messages" id="widget_bar_errors"><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}

my $w2 = HTML::Widget->new;

$w2->element( 'Textfield', 'foo' )->value('foo')->size(30)->label('Foo');
$w2->element( 'Textfield', 'bar' );

$w2->constraint( 'ASCII', 'foo' );
$w2->constraint( 'Integer', 'bar' );

$w2->filter('LowerCase');

# With mocked basic query
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'Foo', bar => 'Bar' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w2->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label for="widget_foo" id="widget_foo_label">Foo<input class="textfield" id="widget_foo" name="foo" size="30" type="text" value="foo" /></label><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" value="bar" /></span><span class="error_messages" id="widget_bar_errors"><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}

my $w3 = HTML::Widget->new;

$w3->element( 'Textfield', 'foo' )->value('foo')->size(30)->label('Foo');
$w3->element( 'Textfield', 'bar' );

$w3->constraint( 'ASCII',   'foo' );
$w3->constraint( 'Integer', 'bar' );

$w3->filter('LowerCase');

# With mocked basic query
{
    my $query = Test::MockObject->new;
    my $data  = {
        foo => [ 'Foo', 'fOO' ],
        bar => [ 'Bar', 'bAR' ]
    };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w3->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label for="widget_foo" id="widget_foo_label">Foo<input class="textfield" id="widget_foo" name="foo" size="30" type="text" value="foo" /></label><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" value="bar" /></span><span class="error_messages" id="widget_bar_errors"><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}
