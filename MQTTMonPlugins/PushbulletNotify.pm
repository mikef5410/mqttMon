#
# A Simple plugin class for Pushbullet notifications
#
# perltidy -i=2 -ce -l=100
#
package MQTTMonPlugins::PushbulletNotify;
use Moose;
use Moose::Exporter;
use WWW::PushBullet;
use Try::Tiny;
has 'recipients' => ( is => 'rw', isa => 'ref', default => undef );

# $obj->registerRecipient($name, $pushbulletAPIKey, $pushbulletDeviceID);
sub registerRecipient {
  my $self               = shift;
  my $name               = shift;
  my $pushbulletAPIKey   = shift;
  my $pushbulletDeviceID = shift;
  $self->recipients->{$name} = [ $pushbulletAPIKey, $pushbulletDeviceID ];
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
    my $pKey    = $self->recipients->{$recip}->[0] || undef;
    my $pDevice = $self->recipients->{$recip}->[1] || undef;
    if ( defined($pKey) && defined($pDevice) ) {
      my $p = WWW::PushBullet->new( apikey => $pKey );
      $p->push_note( device_iden => $pDevice, title => $title, text => $text );
    }
  }
}
