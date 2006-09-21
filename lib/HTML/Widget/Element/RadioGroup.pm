package HTML::Widget::Element::RadioGroup;

use warnings;
use strict;
use base 'HTML::Widget::Element';

*value = \&checked;

__PACKAGE__->mk_accessors(
    qw/
        comment label values labels comments checked _current_subelement
        constrain_values/
);

=head1 NAME

HTML::Widget::Element::RadioGroup - Radio Element grouping

=head1 SYNOPSIS

    my $e = $widget->element( 'RadioGroup', 'foo', [qw/choice1 choice2/] );
    $e->comment('(Required)');
    $e->label('Foo'); # label for the whole thing
    $e->values([qw/foo bar gorch/]);
    $e->labels([qw/Fu Bur Garch/]); # defaults to ucfirst of values
    $e->comments([qw/funky/]); # defaults to empty
    $e->value("foo"); # the currently selected value
    $e->constrain_values(1);

=head1 DESCRIPTION

RadioGroup Element.

As of version 1.09, an L<In constraint|HTML::Widget::Constraint::In> is no 
longer automatically added to RadioGroup elements. Use L</constrain_values> 
to provide this functionality.

=head1 METHODS

=head2 comment

Add a comment to this Element.

=head2 label

This label will be placed next to your Element.

=head2 values

List of form values for radio checks. 
Will also be used as labels if not otherwise specified via L<labels>.

=head2 checked

=head2 value

Set which radio element will be pre-set to "checked".

L</value> is provided as an alias for L</checked>.

=head2 labels

The labels for corresponding l</values>.

=head2 constrain_values

If true, an L<In constraint|HTML::Widget::Constraint::In> will 
automatically be added to the widget, using the values from L</values>.

=head2 new

=cut

sub new {
    my ( $class, $opts ) = @_;

    my $self = $class->NEXT::new($opts);

    my $values = $opts->{values};

    $self->values($values);

    $self;
}

=head2 prepare

=cut

sub prepare {
    my ( $self, $w, $value ) = @_;

    if ( $self->constrain_values ) {
        my $name = $self->name;

        my %seen;
        my @uniq = grep { !$seen{$_}++ } @{ $self->values };

        $w->constraint( 'In', $name )->in(@uniq)
            if @uniq;
    }

    return;
}

=head2 containerize

=cut

sub containerize {
    my ( $self, $w, $value, $errors, $args ) = @_;

    $value = $self->value if ( not defined $value ) and not $args->{submitted};
    $value = '' if not defined $value;

    my $name   = $self->name;
    my @values = @{ $self->values || [] };
    my @labels = @{ $self->labels || [] };
    @labels = map {ucfirst} @values unless @labels;
    my @comments = @{ $self->comments || [] };

    my $i;
    my @radios = map {
        $self->_current_subelement( ++$i );    # yucky hack

        my $radio = $self->mk_input(
            $w,
            {   type => 'radio',
                ( $_ eq $value ? ( checked => "checked" ) : () ),
                value => $_,
            } );

        $radio->attr( class => "radio" );

        my $label = $self->mk_label( $w, shift @labels, shift @comments );
        $label->unshift_content($radio);

        $label;
    } @values;

    $self->_current_subelement(undef);

    #my $error = $self->mk_error( $w, $errors );

    # this should really be a legend attr for field
    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );
    $l->attr( for => undef ) if $l;

    return $self->container( {
            element => HTML::Element->new('span')->push_content(@radios),
            error   => scalar $self->mk_error( $w, $errors ),
            label   => $l
        } );
}

=head2 id

=cut

sub id {
    my ( $self, $w ) = @_;
    my $id      = $self->SUPER::id($w);
    my $subelem = $self->_current_subelement;

    return $subelem
        ? "${id}_$subelem"
        : $id;
}

=head1 SEE ALSO

L<HTML::Widget::Element>

=head1 AUTHOR

Jess Robinson

Yuval Kogman

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
