#!/usr/bin/perl

package HTML::Widget::Constraint::In;
use base 'HTML::Widget::Constraint';

use strict;
use warnings;

__PACKAGE__->mk_accessors(qw/_in _in_hash/);

=head1 NAME

HTML::Widget::Constraint::In - Check that a value is one of a current set.

=head1 SYNOPSIS

    $widget->constraint( In => "foo" )->in(qw/possible values/);

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=cut

sub new {
    my $self = shift->SUPER::new(@_);

    $self->_in_hash({});

    $self;
}

=head2 validate

=cut

sub validate {
    my ( $self, $value ) = @_;
    
    return 1 if keys %{ $self->_in_hash } == 0;
    
    exists $self->_in_hash->{$value};
}

=head2 in

A list of valid values for that element.

If the list is empty, the constraint will always pass.

=cut

sub in {
    my ( $self, @values ) = @_;

    if ( @values ) {
        $self->_in_hash( { map { $_ => undef } @values } );
        $self->_in( @values );
    };
    
    return $self->_in();
}

1;

