package HTML::Widget::Element::Select;

use warnings;
use strict;
use base 'HTML::Widget::Element';

__PACKAGE__->mk_accessors(qw/comment label options selected/);
__PACKAGE__->mk_attr_accessors(qw/size/);

=head1 NAME

HTML::Widget::Element::Select - Select Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Select', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->size(23);
    $e->options( foo => 'Foo', bar => 'Bar' );
    $e->selected(qw/foo bar/);

=head1 DESCRIPTION

Select Element.

=head1 METHODS

=head2 $self->render( $widget, $value, $errors )

=cut

sub render {
    my ( $self, $w, $value, $errors ) = @_;

    my $options = $self->options;
    my @options = ref $options eq 'ARRAY' ? @$options : ();
    my %options = (@options);
    my @o;
    my @values;
    if ($value) {
        @values = ref $value eq 'ARRAY' ? @$value : ($value);
    }
    else {
        @values =
          ref $self->selected eq 'ARRAY'
          ? @{ $self->selected }
          : ( $self->selected );
    }
    for my $key ( keys %options ) {
        my $value = $options{$key};
        my $option = HTML::Element->new( 'option', value => $key );
        for my $val (@values) {
            if ( defined $val && $val eq $key ) {
                $option->attr( selected => 'selected' );
                last;
            }
        }
        $option->push_content($value);
        push @o, $option;
    }

    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );

    $self->attributes->{class} ||= 'select';
    my $i = HTML::Element->new('select');
    $i->push_content(@o);
    $l ? ( $l->push_content($i) ) : ( $l = $i );
    my $id = $self->id($w);
    $i->attr( id   => $id );
    $i->attr( name => $self->name );

    $i->attr( $_ => ${ $self->attributes }{$_} )
      for ( keys %{ $self->attributes } );
    $l->push_content($i);

    my $e = $self->mk_error( $w, $errors );

    return $self->container( { element => $l, error => $e } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
