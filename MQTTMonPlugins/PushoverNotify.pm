#
# A Simple plugin class for Pushover notifications
#
# perltidy -i=2 -ce -l=100
#
package MQTTMonPlugins::PushoverNotify;
use Moose;
use Moose::Exporter;
use Net::Pushover;
use Try::Tiny;
has 'recipients' => ( is => 'rw', isa => 'ref', default => undef );

# $obj->registerRecipient($name, $pushoverUser, $pushoverToken);
sub registerRecipient {
  my $self          = shift;
  my $name          = shift;
  my $pushoverUser  = shift;
  my $pushoverToken = shift;
  $self->recipients->{$name} = [ $pushoverUser, $pushoverToken ];
}

# $obj->pushoverSend($recipient_or_arrayOfrecipientsRef, title, text, html_boolean);
sub pushoverSend {
  my $self       = shift;
  my $recipients = shift;
  my $title      = shift;
  my $text       = shift;
  my $html       = shift || 0;
  if ( !ref($recipients) ) {
    $recipients = [$recipients];    #Now, it's an array ref...
  }
  foreach my $recip ( @{$recipients} ) {
    my $pUser  = $self->recipients->{$recip}->[0] || undef;
    my $pToken = $self->recipients->{$recip}->[1] || undef;
    if ( defined($pUser) && defined($pToken) ) {
      my $p = Net::Pushover->new( token => $pToken, user => $pUser );
      $p->message( title => $title, text => $text, html => $html );
    }
  }
}
