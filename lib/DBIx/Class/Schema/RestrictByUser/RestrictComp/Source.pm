package DBIx::Class::Schema::RestrictByUser::RestrictComp::Source;

use strict;
use warnings;

=head1 DESCRIPTION

For general usage please see L<DBIx::Class::Schema::RestrictByUser>, the information
provided here is not meant for general use and is subject to change. In the interest
of transparency the functionality presented is documented, but all methods should be
considered private and, as such, subject to incompatible changes and removal.

=head1 PRIVATE METHODS

=head2 resultset

Intercept call to C<resultset> and return restricted resultset

=cut
  
sub resultset {
  my $self = shift;
  my $rs = $self->next::method(@_);
  if (my $user = $self->schema->user) {
    my $s = $self->source_name;
    $s =~ s/::/_/g;
    my $pre = $self->schema->restricted_prefix;
    my $meth = "restrict_${s}_resultset";
    
    if($pre){
      my $meth_pre = "restrict_${pre}_${s}_resultset";
      return $user->$meth_pre($rs) if $user->can($meth_pre);
    }    
    $rs = $user->$meth($rs) if $user->can($meth);
  }
  return $rs;
}

1;

=head1 SEE ALSO

L<DBIx::Class::Schema::RestrictByUser>,

=cut
