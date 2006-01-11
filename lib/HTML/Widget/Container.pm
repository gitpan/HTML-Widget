package HTML::Widget::Container;

use warnings;
use strict;
use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw/element error javascript/);

use overload '""' => sub { return shift->as_xml }, fallback => 1;

*js        = \&javascript;
*js_xml    = \&javascript_xml;
*field     = \&element;
*field_xml = \&element_xml;

=head1 NAME

HTML::Widget::Container - Container

=head1 SYNOPSIS

    my $container  = $form->element('foo');
    
    my $field = $container->field;
    my $error = $container->error;

    my $field_xml      = $container->field_xml;
    my $error_xml      = $container->error_xml;
    my $javascript_xml = $container->javascript_xml;

    my $xml = $container->as_xml;

    my $javascript = $container->javascript;

=head1 DESCRIPTION

Container.

=head1 METHODS

=head2 $self->as_xml

Returns xml.

=cut

sub as_xml {
    my $self = shift;
    my $xml  = '';
    $xml .= $self->javascript_xml if $self->javascript;
    $xml .= $self->element_xml    if $self->element;
    $xml .= $self->error_xml      if $self->error;
    return $xml;
}

=head2 $self->as_list

Returns a list of L<HTML::Element> objects.

=cut

sub as_list {
    my $self = shift;
    my @list;
    push @list, $self->javascript_element if $self->javascript;
    push @list, $self->element            if $self->element;
    push @list, $self->error              if $self->error;
    return @list;
}

=head2 $self->element($element)

=head2 $self->field_xml
=head2 $self->element_xml

Returns xml for element.

=cut

sub element_xml {
    my $self = shift;
    return $self->element ? $self->element->as_XML : '';
}

=head2 $self->error($error)

=head2 $self->error_xml

Returns xml for error.

=cut

sub error_xml {
    my $self = shift;
    return $self->error ? $self->error->as_XML : '';
}

=head2 $self->javascript

=head2 $self->javascript_element

Returns javascript in a script L<HTML::Element>.

=cut

sub javascript_element {
    my $self    = shift;
    my $script  = HTML::Element->new( 'script', type => 'text/javascript' );
    my $content = "\n<!--\n" . $self->javascript . "\n//-->\n";
    $script->push_content($content);
    return $script;
}

=head2 $self->js_xml
=head2 $self->javascript_xml

Returns javascript in a script block.

=cut

sub javascript_xml {
    my $self = shift;
    return $self->javascript_element->as_HTML('<>&');
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
