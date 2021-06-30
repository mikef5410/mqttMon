#
# A Simple plugin class for Dbus notifications
#
# perltidy -i=2 -ce -l=100
#
package MQTTMonPlugins::DBusNotify;
use Moose;
use Moose::Exporter;
use Net::DBus;
use Net::DBus::Reactor;
use Try::Tiny;
## no critic (ProhibitTwoArgOpen)
has 'session_Dbus' => ( is => 'rw', isa => 'Net::DBus', default => undef );

#Find the session bus for logged in user.
# returns (-1,-1) if not found, otherwise it returns (uid,bus_address)
sub find_session_bus {
  my $self = shift;
  my $user;
  my $pid;
  my $busaddr;
  open( my $PS, "ps -ef |" );
  while (<$PS>) {
    if (/dbus-daemon.+--session/) {
      my (@parms) = split(" ");
      $user = $parms[0];
      $pid  = $parms[1];
      last;
    }
  }
  return ( -1, -1 ) if ( !length($user) );
  close($PS);
  open( my $ENV, "/proc/$pid/environ" );
  my $env = <$ENV>;
  close($ENV);
  my @vars = split( "\000", $env );

  #print(join("\n",@vars));
  foreach my $var (@vars) {
    if ( $var =~ /DBUS_SESSION_BUS_ADDRESS=/ ) {
      $busaddr = substr( $var, 25 );
      last;
    }
  }
  return ( scalar( getpwnam($user) ), $busaddr );
}

#Check to see if the session bus is still alive
sub check_session_bus {
  my $self = shift;
  if ( defined( $self->session_Dbus ) ) {
    try {
      my $obj  = $self->session_Dbus->get_bus_object()->get_child_object("Peer");
      my $rval = $obj->Ping();
      return (0);    #OK
    } catch {
      return (1);    #Not there
    };
  }
  return (1);
}

sub get_session_bus {
  my $self = shift;
  if ( $self->check_session_bus() ) {
    $self->session_Dbus(undef);
    my ( $uid, $busaddr ) = $self->find_session_bus();
    if ( length($busaddr) ) {
      try {
        $self->session_Dbus( Net::DBus->new($busaddr) );
      } catch {
        $self->session_Dbus(undef);
      };
    }
  }
  return ( $self->session_Dbus );
}

# dbusNotifyObj->notify($summary,$body,$timeout_sec);
sub notify {
  my $self    = shift;
  my $summary = shift;
  my $body    = shift;
  my $timeout = shift || 30;                #sec
  my $bus     = $self->get_session_bus();
  if ( defined($bus) ) {
    my $svc      = $bus->get_service("org.freedesktop.Notifications");
    my $obj      = $svc->get_object("/org/freedesktop/Notifications");
    my $notifyID = $obj->Notify( "mqttMon", 0, "", $summary, $body, [], {}, 1000 * $timeout );
  }
  return;
}
