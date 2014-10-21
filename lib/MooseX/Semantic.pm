package MooseX::Semantic;
BEGIN { $MooseX::Semantic::AUTHORITY = 'cpan:KBA'; }
our $VERSION = '0.005';

1;

# perlpod

=head1 NAME

MooseX::Semantic - Adding RDF semantics to the Moose framework

=head1 DESCRIPTION

MooseX::Semantic is a set of modules that adds a semantic layer to
L<Moose|Moose>-powered objects. Moose classes that consume the various roles
MooseX::Semantic offers are interoperable with the L<RDF::Trine|RDF::Trine> RDF
framework.

=head1 DOCUMENTATION OVERVIEW

MooseX::Semantic can be used on multiple levels of integration into RDF.

=head2 Basic semantics

For basic semantic additions, the following roles are necessary:

=over 4

=item L<MooseX::Semantic::Meta::Attribute::Trait>

Add URIs, datatype and language to your attributes, turning them into RDF
properties.

=item L<MooseX::Semantic::Role::WithRdfType>

Adds a class attribute C<rdf_type> representing the RDF is-a relationship.

=item L<MooseX::Semantic::Role::Resource> 

Adds an 'rdf_about' attribute to Moose objects turning them into RDF resources.

=back

=head2 From Moose to RDF and back

The following classes make round-tripping to/from RDF/Moose possible:

=over 4

=item L<MooseX::Semantic::Role::RdfExport>

Role for exporting a Moose object to RDF, including serialization and exporting
to SPARQL/U endpoints.

=item L<MooseX::Semantic::Role::RdfImport>

Creating instances of MooseX::Semantic-flavored Moose classes from RDF data.

=item L<MooseX::Semantic::Role::RdfImportAll>

Bulk import of multiple RDF resources.

=back

=head2 Persistence

These modules make MooseX::Semantic-enabled classes storable in a
L<RDF::Trine::Store> and handle statement obsolescence.

=over 4

=item L<MooseX::Semantic::Role::RdfBackend>

Assignment a L<RDF::Trine::Store> object to a class, so objects of the class
can be stored and re-imported from that store.

=item L<MooseX::Semantic::Role::RdfObsolescence>

Role that keeps track of changes within an object's set of statements and helps
keeping the statements accurate.

=back

=head2 Schema introspection

=over 4

=item L<MooseX::Semantic::Util::SchemaExport>

Extract the schema/ontology that a MooseX::Semantic class represents.

=item L<MooseX::Semantic::Util::SchemaImport>

Dynamically adding L<MooseX::Semantic::Meta::Attribute::Trait>-enabled
attributes to existing classes or creating MooseX::Semantic classes directly
from a schema such as FOAF.

=back

=head2 Utility Modules

=over 4 

=item L<MooseX::Semantic::Types>

Defines subtypes and coercions for various RDF-related data structures

=item L<MooseX::Semantic::Util::TypeConstraintWalker>

Convenient way to loop through the attributes of a Moose class with regards
to their RDF semantics.

=back

=head1 TODO BUGS

Documentation is lacking, the tests would be a good starting point right now.

Context isn't properly handled right now.

Performance hasn't been considered yet.

Schema introspection without at least RDFS reasoning can only get you so far.

Recursive import is buggy.

=head1 AUTHOR

=over 4

=item Konstantin Baierer (<kba@cpan.org>)

=item Toby Inkster (<tobyink@cpan.org>)

=back

=head1 SEE ALSO

=over 4

=item L<RDF::Trine>

=back

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See perldoc perlartistic.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
