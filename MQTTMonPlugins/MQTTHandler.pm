#
# A Generic class for handling mqtt events
#
# perltidy -i=2 -ce -l=100
#
package MQTTMonPlugins::MQTTHandler;
use Moose;
use Moose::Exporter;
use JSON;
use Try::Tiny;
use 5.010;
#
#
has 'recipients' => ( is => 'rw', isa => 'ref', default => undef );    #hash ref of recipient classes,
                                                                       #each is an array ref of names
has 'handlers'   => ( is => 'rw', isa => 'ref', default => undef );    #Array ref of mqtt handler function refs
has 'topics'     => ( is => 'rw', isa => 'ref', default => undef );    #Array ref of topics to bind to

#$obj->register_recipient($name, $class);
sub register_recipient {
  my $self  = shift;
  my $name  = shift;
  my $class = shift || "main";
  #
  $self->recipients( unshift( @{ $self->recipients->{$class} }, $name ) );
}

sub register_handler {
  my $self       = shift;
  my $handlerRef = shift;
  $self->handlers( unshift( @{ $self->handlers }, $handlerRef ) );
}

#Called by mqtt receiver as handle($topic,$val);
sub handler {
  my $self  = shift;
  my $topic = shift;
  my $val   = shift;
  foreach my $handler ( @{ $self->handlers } ) {
    $handler->( $self, $topic, $val );
  }
}

sub getSubs {
  my $self = shift;
  my @subs = ();
  foreach my $topic ( @{ $self->topics } ) {
    push( @subs, $topic, \&{ $self->handler } );
  }
  return (@subs);
}
