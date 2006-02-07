use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textarea', 'foo' )->value('foo')->cols(20)->rows(40)->wrap('off')
  ->label('Foo');
$w->element( 'Textarea', 'bar' )->label('Bar')->comment('Baz');

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label for="widget_foo" id="widget_foo_label">Foo<textarea class="textarea" cols="20" id="widget_foo" name="foo" rows="40" wrap="off">foo</textarea></label><label for="widget_bar" id="widget_bar_label">Bar<span class="label_comments" id="widget_bar_comment">Baz</span><textarea class="textarea" cols="40" id="widget_bar" name="bar" rows="20"></textarea></label></fieldset></form>
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
<form action="/" id="widget" method="post"><fieldset><label class="labels_with_errors" for="widget_foo" id="widget_foo_label">Foo</label><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span><label for="widget_bar" id="widget_bar_label">Bar<span class="label_comments" id="widget_bar_comment">Baz</span><textarea class="textarea" cols="40" id="widget_bar" name="bar" rows="20">23</textarea></label></fieldset></form>
EOF
}
