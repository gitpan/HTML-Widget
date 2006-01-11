use Test::More tests => 7;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'Email', 'foo' );

# Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'sri@oook.de' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="sri\@oook.de" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'invalid' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="invalid" /></span><span class="error_messages" id="widget_foo_errors"><span class="email_errors" id="widget_foo_error_email">Invalid Input</span></span></fieldset></form>
EOF
}

# Multiple Valid
{
    my $query = Test::MockObject->new;
    my $data = { foo => [ 'sri@oook.de', 'sri@oook.de' ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( $f->valid('foo'), 1, "Valid" );
    my @results = $f->param('foo');
    is( $results[0], 'sri@oook.de', "Multiple valid values" );
    is( $results[1], 'sri@oook.de', "Multiple valid values" );
}

# Multiple Invalid
{
    my $query = Test::MockObject->new;
    my $data = { foo => [ 'yada', 'bar' ] };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( $f->valid('foo'), 0, "Invalid" );
}
