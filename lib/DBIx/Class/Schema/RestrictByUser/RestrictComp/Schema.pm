package DBIx::Class::Schema::RestrictByUser::RestrictComp::Schema;

use strict;
use warnings;
use base qw/DBIx::Class::AccessorGroup/;

=head1 DESCRIPTION

For general usage please see L<DBIx::Class::Schema::RestrictByUser>, the information
provided here is not meant for general use and is subject to change. In the interest
of transparency the functionality presented is documented, but all methods should be
considered private and, as such, subject to incompatible changes and removal.

=head1 ADDITIONAL ACCESSORS 

=head2 user

Store the user object used to restict resultsets

=head2 restricted_prefix

Store the prefix, if any, to use when looking for the appropriate resstrict
methods in the user object

=cut

__PACKAGE__->mk_group_accessors('simple' => 'user');
__PACKAGE__->mk_group_accessors('simple' => 'restricted_prefix');

1;

=head1 SEE ALSO

L<DBIx::Class::Schema::RestrictByUser>,

=cut
