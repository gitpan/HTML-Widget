package HTML::Widget::Constraint::Equal;

use warnings;
use strict;
use base 'HTML::Widget::Constraint';

=head1 NAME

HTML::Widget::Constraint::Equal - Equal Constraint

=head1 SYNOPSIS

    my $c = $widget->constraint( 'Equal', 'foo', 'bar' );

=head1 DESCRIPTION

Equal Constraint. All elements must be the same.

=head1 METHODS

=head2 $self->process( $widget, $params )

=cut

sub process {
    my ( $self, $w, $params ) = @_;
    my $results = [];
    my $equal=$params->{${$self->names}[0]};
    for my $name ( @{ $self->names } ) {

        # Return valid if we encounter a blank param
        return [] if $params->{$name} eq '';

        push @$results,
          HTML::Widget::Error->new(
            { name => $name, message => $self->mk_message } )
          if $params->{$name} ne $equal;
    }
    return $results;
}

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
