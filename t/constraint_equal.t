use Test::More tests => 5;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );
$w->element( 'Textfield', 'bar' );

$w->constraint( 'Equal', 'foo', 'bar' );

# Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'yada', bar => 'yada' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_bar" name="bar" type="text" value="yada" /></fieldset></form>
EOF
}

# Valid (blank 1)
{
    my $query = Test::MockObject->new;
    my $data = { foo => '', bar => 'yada' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" /><input class="textfield" id="widget_bar" name="bar" type="text" value="yada" /></fieldset></form>
EOF
}

# Valid (blank 2)
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'yada', bar => '' };
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
    my $data = { foo => 'yada', 'bar' => 'nada' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" value="nada" /></span><span class="error_messages" id="widget_bar_errors"><span class="equal_errors" id="widget_bar_error_equal">Invalid Input</span></span></fieldset></form>
EOF
}
