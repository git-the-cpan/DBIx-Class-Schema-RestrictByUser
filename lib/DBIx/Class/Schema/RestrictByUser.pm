package DBIx::Class::Schema::RestrictByUser;

our $VERSION = '0.0001_01';

use DBIx::Class::Schema::RestrictByUser::RestrictComp::Schema;
use DBIx::Class::Schema::RestrictByUser::RestrictComp::Source;

# (c) Matt S Trout 2006, all rights reserved
# this is free software under the same license as perl itself

=head1 NAME

DBIx::Class::Schema::RestrictByUser - Automatically restrict resultsets by user

=head1 SYNOPSYS

In your L<DBIx::Class::Schema> class:

   __PACKAGE__->load_components(qw/Schema::RestrictByUser/);

In the L<DBIx::Class> table class for your users:

   #let's pretend a user has_many notes, which are in ResultSet 'Notes'
  sub restrict_Notes_resultset {
    my $self = shift; #the User object
    my $unrestricted_rs = shift;
    
    #restrict the notes viewable to only those that belong to this user
    #this will, in effect make the following 2 equivalent
    # $user->notes $schema->resultset('Notes')
    return $self->related_resultset('notes');
  }

   #it could also be written like this
  sub restrict_Notes_resultset {
    my $self = shift; #the User object
    my $unrestricted_rs = shift;
    return $unrestricted_rs->search_rs( { user_id => $self->id } );
  }

Wherever you connect to your database

  my $schema = MyApp::Schema->connect(...);
  my $user = $schema->resultset('User')->find( { id => $user_id } );
  $resticted_schema = $schema->restrict_by_user( $user, $optional_prefix);

=cut

=head1 DESCRIPTION

This L<DBIx::Class::Schema> component can be used to restrict all resultsets through
an appropriately-named method in a user's result_class. This can be done to 
automatically prevent data from being accessed by a user, effectively enforcing 
security by limiting any access to the data store.

=head1 PUBLIC METHODS

=head2 restrict_by_user $user_obj, $optional_prefix

Will restrict resultsets according to the methods available in $user_obj and 
return a restricted copy of itself. ResultSets will be restricted if methods 
in the form  of C<restrict_${ResultSet_Name}_resultset> are found in $user_obj. 
If the optional prefix is included it will attempt to use 
C<restrict_${prefix}_${ResultSet_Name}_resultset>, if that does not exist, it 
will try again without the prefix, and if that's not available the resultset 
will not be restricted.

=cut

sub restrict_by_user {
  my ($self, $user, $prefix) = @_;
  my $copy = $self->clone;
  $copy->make_restricted;
  $copy->user($user);
  $copy->restricted_prefix($prefix) if $prefix;
  return $copy;
}

=head1 PRIVATE METHODS

=head2 make_restricted

Restrict the Schema class and ResultSources associated with this Schema

=cut

sub make_restricted {
  my ($self) = @_;
  my $class = ref($self);
  my $r_class = $self->_get_restricted_schema_class($class);
  bless($self, $r_class);
  foreach my $moniker ($self->sources) {
    my $source = $self->source($moniker);
    my $class = ref($source);
    my $r_class = $self->_get_restricted_source_class($class);
    bless($source, $r_class);
  }
}

=head2 _get_restricted_schema_class $target_schema

Return the class name for the restricted schema class;

=cut

sub _get_restricted_schema_class {
  my ($self, $target) = @_;
  return $self->_get_restricted_class(Schema => $target);
}

=head2 _get_restricted_source_class $target_source

Return the class name for the restricted ResultSource class;

=cut

sub _get_restricted_source_class {
  my ($self, $target) = @_;
  return $self->_get_restricted_class(Source => $target);
}

=head2 _get_restrictedclass $type, $target

Return an appropriate class name for a restricted class of type $type.

=cut

sub _get_restricted_class {
  my ($self, $type, $target) = @_;
  my $r_class = join('::', $target, '__RestrictedByUser');
  unless (eval { $r_class->can('can') }) {
    my $r_comp = join(
      '::', 'DBIx::Class::Schema::RestrictByUser::RestrictComp', $type
    );
    $self->inject_base($r_class, $r_comp, $target);
  }
  return $r_class;
}

1;

__END__;

=head1 SEE ALSO 

L<DBIx::Class>, L<DBIx::Class::Schema::RestrictByUser::RestrictComp::Schema>,
L<DBIx::Class::Schema::RestrictByUser::RestrictComp::Source>,

=head1 AUTHORS

Matt S Trout (mst) <mst@shadowcatsystems.co.uk>

With contributions from
Guillermo Roditi (groditi) <groditi@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
