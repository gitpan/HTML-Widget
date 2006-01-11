package HTML::Widget::Element::Checkbox;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/checked comment label value/);

=head1 NAME

HTML::Widget::Element::Checkbox - Checkbox Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Checkbox', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->checked('checked');
    $e->value('bar');

=head1 DESCRIPTION

Checkbox Element.

=head1 METHODS

=head2 new

=cut

sub new {
    shift->NEXT::new(@_)->value(1);
}

=head2 $self->render( $widget, $value, $errors )

=cut

sub render {
    my ( $self, $w, $value, $errors ) = @_;

    my $checked = ( defined $value && $value eq $self->value ) ? 'checked' : 0;
    $checked = 'checked' if ( !defined $value && $self->checked );
    $value   = $self->value;

    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );
    my $i =
      $self->mk_input( $w,
        { checked => $checked, type => 'checkbox', value => $value }, $errors );
    $l ? ( $l->unshift_content($i) ) : ( $l = $i );
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
