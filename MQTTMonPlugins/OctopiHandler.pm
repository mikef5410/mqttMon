#
# A Generic class for handling mqtt events
#
# perltidy -i=2 -ce -l=100
#
package MQTTMonPlugins::OctopiHandler;
use Moose;
use Moose::Exporter;
use JSON;
use Try::Tiny;
use 5.010;
## no critic (ValuesAndExpressions::ProhibitAccessOfPrivateData)
#
##
extends(MQTTMonPlugins::MQTTHandler);
#
#
sub BUILD {
  my $self = shift;
  $self->topics( push( @{ $self->topics }, 'octoPrint/#' ) );
  $self->handlers( push( @{ self->handlers }, \&octohandler ) );
}

sub octohandler {
  my $self  = shift;
  my $topic = shift;
  my $val   = shift;
  my $json  = JSON->new->allow_nonref;
  my $v;
  try {
    $v = $json->decode($val);
  } catch {
  };
SW: {
    if ( $topic eq "octoPrint/event/PrinterStateChanged" ) {
      if ( $v->{state_id} eq "FINISHING" ) {
        notify( "Print Finished", sprintf( "%s is done printing.", $v->{name} ), sprintf( "%s %s", GRN, BRIGHT ), 10 );
        last SW;
      }
      if ( $v->{state_id} eq "PRINTING" ) {
        notify( "Print Started", sprintf( "%s is printing.", $v->{name} ), sprintf( "%s %s", YEL, BRIGHT ), 10 );
        last SW;
      }
      notify( "Printer state changed.", $v->{state_id}, "", 10 );
      last SW;
    }
    if ( $topic eq "octoPrint/event/ClientOpened" ) {
      notify( "Client connect to printer", $v->{remoteAddress}, "", 10 );
      last SW;
    }
    if ( $topic eq "octoPrint/event/ClientClosed" ) {
      notify( "Client disconnect from printer", $v->{remoteAddress}, "", 10 );
      last SW;
    }
    if ( $topic =~ m|octoPrint/temperature/| ) {

      #notify( "Temperature", "Temp report",  sprintf( "%s %s", YEL, SLOW_BLINK ), 10 );
      last SW;
    }

    #Default
    Info("$topic - $val");    #Log it
  }
}
