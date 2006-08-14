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

=head2 $self->containerize( $widget, $value, $errors )

=cut

sub containerize {
    my ( $self, $w, $value, $errors ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    my $name = $self->name;

    # Search for multiple checkboxes with the same name
    my $multi = 0;
    my @elements;
    push @elements, [ $w, $w->{_elements} ] if $w->{_elements};
    if ( $w->{_embedded} ) {
        for my $embedded ( @{ $w->{_embedded} } ) {
            push @elements, [ $embedded, $embedded->{_elements} ]
              if $embedded->{_elements};
        }
    }
    for my $e (@elements) {
        my $widget   = $e->[0];
        my $elements = $e->[1];
        for my $element (@$elements) {
            next if $element eq $self;
            if ( $element->isa('HTML::Widget::Element::Checkbox') ) {
                if ( $element->name eq $name ) {
                    $multi++;
                }
            }
        }
    }

    # Generate unique id
    if ($multi) {
        $w->{_shash}          ||= {};
        $w->{_stash}->{checkbox} ||= {};
        my $num = ++$w->{_stash}->{checkbox}->{$name};
        my $id = $self->id( $w, "$name\_$num" );
        $self->attributes( {} ) unless $self->attributes;
        $self->attributes->{id} ||= $id;
    }

    my $checked = ( defined $value && $value eq $self->value ) ? 'checked' : undef;
    $checked = 'checked' if ( !defined $value && $self->checked );
    $value   = $self->value;

    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );
    my $i =
      $self->mk_input( $w,
        { checked => $checked, type => 'checkbox', value => $value }, $errors );
    my $e = $self->mk_error( $w, $errors );

    return $self->container( { element => $i, error => $e, label => $l } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
