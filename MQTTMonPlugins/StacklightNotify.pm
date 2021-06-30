#
# A Simple plugin class for Stacklight notifications
#
# perltidy -i=2 -ce -l=100
#
package MQTTMonPlugins::StacklightNotify;
use Moose;
use Moose::Exporter;
use AnyEvent;
use Try::Tiny;
use 5.010;
#
## no critic (ProhibitTwoArgOpen)
#
use constant {
  DIM        => " 4 10 0",
  BRIGHT     => " 0 0 0",
  FAST_BLINK => " 20 300 0",
  SLOW_BLINK => " 20 2000 0",
  RED        => "R",
  YEL        => "Y",
  GRN        => "G",
};
#
#
Moose::Exporter->setup_import_methods( as_is => [ \&DIM, \&BRIGHT, \&FAST_BLINK, \&SLOW_BLINK, \&RED, \&YEL, \&GRN, ] );
has 'stacklightSem' => ( is => 'rw', isa => 'String', default => "/tmp/stacklight" );
has 'recipients'    => ( is => 'rw', isa => 'ref',    default => undef );

# $obj->registerRecipient($name, $pushbulletAPIKey, $pushbulletDeviceID);
sub ensureStacklightd {
  my $self = shift;
  #
  my $ok = 0;
  #
  open( my $PS, "ps -ef |" );
  while (<$PS>) {
    if (/stacklightd/) {
      $ok = 1;
      last;
    }
  }
  close($PS);
  if ( !$ok ) {
    system("systemctl start stacklightd");
  }
}

# $obj->stacklightSend($color, $blinkArgs, timeout_sec);
sub stacklightSend {
  my $self    = shift;
  my $color   = shift;
  my $light   = shift;
  my $timeout = shift || 0;
  #
  open( my $STACKLIGHT, '>', $self->stacklightSem );
  printf( {$STACKLIGHT} "%s %s\n", $color, $light );
  close($STACKLIGHT);
  if ($timeout) {
    AnyEvent->timer( after => $timeout, cb => sub { $self->stacklightClear(); } );
  }
}

# $obj->stacklightClear();
sub stacklightClear {
  my $self = shift;
  #
  unlink( $self->stacklightSem );
}
