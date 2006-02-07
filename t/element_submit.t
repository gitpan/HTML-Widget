use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Submit', 'foo' )->value('foo');
$w->element( 'Submit', 'bar' );

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="submit" id="widget_foo" name="foo" type="submit" value="foo" /><input class="submit" id="widget_bar" name="bar" type="submit" value="1" /></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = Test::MockObject->new;
    my $data = { foo => 'yada', bar => '23' };
    $query->mock( 'param',
       sub {
           my ( $self, $param ) = @_;
           if ( @_ == 1 ) { return keys %$data }
           else {
               unless ( exists $data->{$param} ) {
                   return wantarray ? () : undef;
               }
               if ( ref $data->{$param} eq 'ARRAY' ) {
                   return (wantarray)
                     ? @{ $data->{$param} }
                     : $data->{$param}->[0];
               }
               else {
                   return (wantarray)
                     ? ( $data->{$param} )
                     : $data->{$param};
               }
           }
       } 
    );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="submit" id="widget_foo" name="foo" type="submit" value="yada" /><input class="submit" id="widget_bar" name="bar" type="submit" value="23" /></fieldset></form>
EOF
}
