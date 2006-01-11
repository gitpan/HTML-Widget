package HTML::Widget::Element::Textfield;

use warnings;
use strict;
use base 'HTML::Widget::Element';

__PACKAGE__->mk_accessors(qw/comment label value/);
__PACKAGE__->mk_attr_accessors(qw/size/);

=head1 NAME

HTML::Widget::Element::Textfield - Textfield Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Textfield', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->size(23);
    $e->value('bar');

=head1 DESCRIPTION

Textfield Element.

=head1 METHODS

=head2 $self->render( $widget, $value, $errors )

=cut

sub render {
    my ( $self, $w, $value, $errors ) = @_;

    $value ||= $self->value;

    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );
    my $i = $self->mk_input( $w, { type => 'text', value => $value }, $errors );
    $l ? ( $l->push_content($i) ) : ( $l = $i );
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
