package MooseX::Semantic::Role::Resource;
use Moose::Role;
use Data::UUID;
use MooseX::Semantic::Types qw(TrineBlankOrUndef TrineNode TrineResource );
use URI;
# use MooseX::InstanceTracking;

=head1 NAME

MooseX::Semantic::Role::Resource - Handle Moose objects as RDF resources

=head1 SYNOPSIS

    package My::Model::Person;
    with qw(MooseX::Semantic::Role::Resource);
    1;

    package main;
    my $p = My::Model::Person->new(
        rdf_about => 'http://someone.org/#me'
    );

=cut

=head1 ATTRIBUTES

=cut

=head2 C<rdf_about>

The URI of the resource this object represents. When not specified, this defaults to a
random urn:UUID URI.

=cut

has rdf_about => (
    is => 'rw',
    isa => TrineNode,
    coerce => 1,
    required => 0,
    lazy => 1,
    builder => '_build_rdf_about',
    handles => [qw( is_blank is_resource )],
);
sub _build_rdf_about {
    # XXX should Resources be by default blank nodes or have a UUID URI?
    TrineResource->coerce(sprintf('urn:uuid:%s', Data::UUID->new->create_str));
}

1;

=head1 METHODS

=head2 C<is_blank>

Delegation to C<RDF::Trine::Node>. Returns a true value if the C<rdf_about> node is a blank node.

=cut

=head2 C<is_resource>

Delegation to C<RDF::Trine::Node>. Returns a true value if the C<rdf_about> node is a resource node.

=cut

=head1 AUTHOR

Konstantin Baierer (<kba@cpan.org>)

=head1 SEE ALSO

=over 4

=item L<MooseX::Semantic|MooseX::Semantic>

=back

=cut

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See perldoc perlartistic.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

