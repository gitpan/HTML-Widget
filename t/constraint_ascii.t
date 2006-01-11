use Test::More tests => 7;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'ASCII', 'foo' );

# Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'yada' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = Test::MockObject->new;
    my $data = { foo => '日本語' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="&#230;&#151;&#165;&#230;&#156;&#172;&#232;&#170;&#158;" /></span><span class="error_messages" id="widget_foo_errors"><span class="ascii_errors" id="widget_foo_error_ascii">Invalid Input</span></span></fieldset></form>
EOF
}

# Multiple Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => [ 'bar', 'yada' ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( $f->valid('foo'), 1, "Valid" );
    my @results = $f->param('foo');
    is( $results[0], 'bar',  "Multiple valid values" );
    is( $results[1], 'yada', "Multiple valid values" );
}

# Multiple Invalid
{
    my $query = Test::MockObject->new;
    my $data = { foo => [ 'yada', '日本語' ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( $f->valid('foo'), 0, "Invalid" );
}
